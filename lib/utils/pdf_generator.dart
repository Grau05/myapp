import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/animal.dart';

class PdfGenerator {
  static Future<File> exportAnimales(List<Animal> animales) async {
    final pdf = pw.Document();
    final formatter = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Reporte de Pesos de Animales')),
          ...animales.map((animal) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ID: ${animal.id}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              if (animal.nombre != null)
                pw.Text('Nombre: ${animal.nombre!}'),
              pw.Text('Historial de pesos:'),
              if (animal.historial.isEmpty)
                pw.Text('  - Sin registros.'),
              ...animal.historial.map(
                (peso) => pw.Text('  - ${formatter.format(peso.fecha)} → ${peso.peso} kg'),
              ),
              pw.SizedBox(height: 12),
            ],
          )),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/reporte_ganado.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
