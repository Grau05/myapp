import 'package:hive/hive.dart';

part 'peso.g.dart';

@HiveType(typeId: 1)
class Peso {
  @HiveField(0)
  DateTime fecha;

  @HiveField(1)
  double peso;

  Peso({required this.fecha, required this.peso});
}
