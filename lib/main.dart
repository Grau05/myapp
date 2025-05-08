import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/animal.dart';
import 'models/peso.dart';
import 'data/hive_boxes.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(AnimalAdapter());
  Hive.registerAdapter(PesoAdapter());
  await Hive.openBox<Animal>(HiveBoxes.animales);
  runApp(const MyApp());
}
