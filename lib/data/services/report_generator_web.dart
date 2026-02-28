import 'dart:typed_data';

Future<String?> saveReportToFile(Uint8List bytes, String fileName) async {
  // On web, we don't save to file system - handled via printing package
  return null;
}
