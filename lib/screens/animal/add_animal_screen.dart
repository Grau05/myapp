import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../models/animal.dart';
import '../../data/hive_boxes.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardarAnimal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final box = Hive.box<Animal>(HiveBoxes.animales);
        final id = _idController.text; // Ya no es necesario convertir a int
        final nombre = _nombreController.text.trim();

        final existe = box.values.any((a) => a.id == id);
        if (existe) {
          _mostrarError('El ID $id ya está registrado en la base de datos');
          return;
        }

        final animal = Animal(
          id: id,
          nombre: nombre.isNotEmpty ? nombre : null,
        );
        await box.add(animal);

        if (mounted) {
          // Muestra mensaje de éxito y navega de vuelta
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Animal $id registrado correctamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Devuelve true para indicar que se agregó un animal
        }
      } catch (e) {
        _mostrarError('Error al guardar: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _generarIdUnico() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final box = Hive.box<Animal>(HiveBoxes.animales);
      final existingIds = box.values.map((a) => a.id).toSet();

      // Genera un ID de 4 dígitos que no exista
      String newId;
      do {
        // Genera un número entre 1000 y 9999
        int randomNum = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
        newId = randomNum.toString();
      } while (existingIds.contains(newId));

      setState(() {
        _idController.text = newId;
      });
    } catch (e) {
      _mostrarError('Error al generar ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusScope.of(
                context,
              ).unfocus(), // Cierra el teclado al tocar fuera
      child: Scaffold(
        appBar: AppBar(title: const Text('Registro de Animal'), elevation: 2),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del animal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Campo ID con botón para generar ID único
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _idController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'ID del animal',
                                  hintText: '4 dígitos',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.tag),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingrese un ID';
                                  }
                                  if (value.length != 4) {
                                    return 'El ID debe tener exactamente 4 dígitos';
                                  }
                                  // Verifica que sean solo dígitos
                                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                                    return 'Por favor ingrese solo números';
                                  }
                                  return null;
                                },
                                // Sin formateo automático para permitir que el usuario ingrese exactamente lo que desea
                              ),
                            ),
                            const SizedBox(width: 8),
                            Tooltip(
                              message: 'Generar ID único',
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _generarIdUnico,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(15),
                                ),
                                child: const Icon(Icons.autorenew),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del animal (opcional)',
                            hintText: 'Ej: Luna, Torito, etc.',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.pets),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _guardarAnimal,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(_isLoading ? 'Guardando...' : 'Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Nota informativa
                const Card(
                  elevation: 0,
                  color: Color(0xFFE8F5E9),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El ID es un número único de 4 dígitos que identifica al animal. '
                            'No podrá modificarse después de creado.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
