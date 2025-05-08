import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/animal.dart';
import '../../models/peso.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;

  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  final _nombreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.animal.nombre ?? '';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  double get _promedioPeso {
    if (widget.animal.historial.isEmpty) return 0.0;
    final total = widget.animal.historial.fold<double>(
      0.0,
      (sum, p) => sum + p.peso,
    );
    return total / widget.animal.historial.length;
  }

  double? get _ultimoPeso {
    if (widget.animal.historial.isEmpty) return null;
    return widget.animal.historial.last.peso;
  }

  double? get _pesoDiferencia {
    if (widget.animal.historial.length < 2) return null;
    final ultimo = widget.animal.historial.last.peso;
    final penultimo =
        widget.animal.historial[widget.animal.historial.length - 2].peso;
    return ultimo - penultimo;
  }

  void _agregarPesaje() {
    final _pesoController = TextEditingController();
    final _pesoFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Nuevo Pesaje'),
            content: Form(
              key: _pesoFormKey,
              child: TextFormField(
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese el peso en kilogramos',
                ),
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un peso';
                  }
                  final peso = double.tryParse(value);
                  if (peso == null) {
                    return 'Ingrese un número válido';
                  }
                  if (peso <= 0) {
                    return 'El peso debe ser mayor a 0';
                  }
                  if (peso > 2000) {
                    return 'El peso no puede ser mayor a 2000 kg';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_pesoFormKey.currentState?.validate() ?? false) {
                    final peso = double.parse(_pesoController.text);
                    setState(() {
                      widget.animal.historial.add(
                        Peso(fecha: DateTime.now(), peso: peso),
                      );
                      widget.animal.save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pesaje registrado correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _guardarNombre() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        widget.animal.nombre = _nombreController.text.trim();
        widget.animal.save();
        _isEditing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  void _eliminarPesaje(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Está seguro que desea eliminar este registro de peso?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.animal.historial.removeAt(index);
                    widget.animal.save();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registro eliminado'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.animal.nombre?.isNotEmpty == true
              ? widget.animal.nombre!
              : 'Animal ${widget.animal.id}',
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _guardarNombre();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            tooltip: _isEditing ? 'Guardar cambios' : 'Editar información',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del animal
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${widget.animal.id}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          border:
                              _isEditing
                                  ? const OutlineInputBorder()
                                  : InputBorder.none,
                          enabled: _isEditing,
                          suffixIcon:
                              _isEditing
                                  ? IconButton(
                                    icon: const Icon(Icons.check),
                                    onPressed: _guardarNombre,
                                  )
                                  : null,
                        ),
                        onFieldSubmitted: (_) => _guardarNombre(),
                        validator: (value) {
                          if (_isEditing &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Por favor ingrese un nombre';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Estadísticas de peso
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Peso',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Promedio',
                            value: '${_promedioPeso.toStringAsFixed(2)} kg',
                            icon: Icons.bar_chart,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            title: 'Último peso',
                            value:
                                _ultimoPeso != null
                                    ? '${_ultimoPeso!.toStringAsFixed(2)} kg'
                                    : 'N/A',
                            icon: Icons.monitor_weight,
                          ),
                        ),
                      ],
                    ),
                    if (_pesoDiferencia != null) ...[
                      const SizedBox(height: 8),
                      _StatCard(
                        title: 'Cambio de peso',
                        value: '${_pesoDiferencia!.toStringAsFixed(2)} kg',
                        icon:
                            _pesoDiferencia! > 0
                                ? Icons.arrow_upward
                                : (_pesoDiferencia! < 0
                                    ? Icons.arrow_downward
                                    : Icons.drag_handle),
                        color:
                            _pesoDiferencia! > 0
                                ? Colors.green
                                : (_pesoDiferencia! < 0 ? Colors.red : null),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de pesajes (${widget.animal.historial.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _agregarPesaje,
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (widget.animal.historial.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay registros de peso',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight,
                    ),
                    child: ListView.builder(
                      itemCount: widget.animal.historial.length,
                      itemBuilder: (_, index) {
                        final reversedIndex =
                            widget.animal.historial.length - 1 - index;
                        final p = widget.animal.historial[reversedIndex];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.monitor_weight),
                            title: Text(
                              '${p.peso.toStringAsFixed(2)} kg',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(_getFormattedDate(p.fecha)),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _eliminarPesaje(reversedIndex),
                              tooltip: 'Eliminar registro',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: color ?? Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
