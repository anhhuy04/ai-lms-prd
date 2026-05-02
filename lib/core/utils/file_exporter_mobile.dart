import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> platformExportFile(Uint8List bytes, String fileName) async {
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'xlsx';
  final title = switch (ext) {
    'docx' => 'Lưu file Word',
    'xlsx' => 'Lưu file Excel',
    _ => 'Lưu file',
  };
  final outputPath = await FilePicker.saveFile(
    dialogTitle: title,
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: [ext],
    bytes: bytes,
  );
  return outputPath != null;
}
