import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/animal.dart';
import '../../data/hive_boxes.dart';
import '../animal/animal_detail_screen.dart';
import '../animal/add_animal_screen.dart';
import 'package:printing/printing.dart';
import '../../utils/pdf_generator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchById = true; // Controla si se busca por ID o por nombre

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalesBox = Hive.box<Animal>(HiveBoxes.animales);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animales registrados'),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // <-- Esto hará visibles los íconos
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar a PDF',
            onPressed: () async {
              final animales =
                  Hive.box<Animal>(HiveBoxes.animales).values.toList();
              if (animales.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No hay animales para exportar'),
                  ),
                );
                return;
              }

              final file = await PdfGenerator.exportAnimales(animales);
              await Printing.sharePdf(
                bytes: await file.readAsBytes(),
                filename: 'reporte_ganado.pdf',
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        _isSearchById
                            ? 'Buscar por ID...'
                            : 'Buscar por nombre...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Selector de tipo de búsqueda
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Buscar por:'),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('ID'),
                      selected: _isSearchById,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isSearchById = true;
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Nombre'),
                      selected: !_isSearchById,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isSearchById = false;
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de animales
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: animalesBox.listenable(),
              builder: (context, Box<Animal> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.pets, size: 80, color: Colors.black26),
                        const SizedBox(height: 16),
                        Text(
                          'No hay animales registrados',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _navegarARegistro(context),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Registrar animal'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar animales según la búsqueda
                final filteredAnimals =
                    _searchQuery.isEmpty
                        ? box.values.toList()
                        : box.values.where((animal) {
                          if (_isSearchById) {
                            return animal.id.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                          } else {
                            return (animal.nombre ?? '').toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                          }
                        }).toList();

                if (filteredAnimals.isEmpty) {
                  return Center(
                    child: Text(
                      'No se encontraron animales con $_searchQuery',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    return;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 88,
                    ), // Espacio para el FAB
                    itemCount: filteredAnimals.length,
                    itemBuilder: (context, index) {
                      final animal = filteredAnimals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Card(
                          elevation: 2,
                          child: Dismissible(
                            key: Key(animal.key.toString()),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text(
                                        'Confirmar eliminación',
                                      ),
                                      content: Text(
                                        '¿Estás seguro de eliminar el animal ${animal.id}${animal.nombre != null ? " - ${animal.nombre}" : ""}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('CANCELAR'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
                                          child: const Text('ELIMINAR'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            onDismissed: (_) {
                              animal.delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Animal ${animal.id} eliminado',
                                  ),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  animal.id,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                animal.nombre ?? 'Sin nombre asignado',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  const Icon(
                                    Icons.tag,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('ID: ${animal.id}'),
                                  if (animal.historial.isNotEmpty) ...[
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.monitor_weight_outlined,
                                      size: 14,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${animal.historial.length} registros',
                                    ),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => AnimalDetailScreen(
                                            animal: animal,
                                          ),
                                    ),
                                  ),
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navegarARegistro(context),
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
        tooltip: 'Registrar nuevo animal',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _navegarARegistro(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
    );

    if (result == true) {
      // Si se añadió un animal, limpiamos la búsqueda
      setState(() {
        _searchController.clear();
        _searchQuery = '';
      });
    }
  }
}
