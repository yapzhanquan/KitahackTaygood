import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String?> saveReportToFile(Uint8List bytes, String fileName) async {
  final output = await getApplicationDocumentsDirectory();
  final file = File('${output.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
