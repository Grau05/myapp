import 'package:hive/hive.dart';
import 'peso.dart';

part 'animal.g.dart';

@HiveType(typeId: 0)
class Animal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? nombre;

  @HiveField(2)
  List<Peso> historial;

  Animal({required this.id, this.nombre, List<Peso>? historial})
    : historial = historial ?? [];
}
