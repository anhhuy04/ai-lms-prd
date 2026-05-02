// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

Future<bool> platformExportFile(Uint8List bytes, String fileName) async {
  final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'xlsx';
  final mimeType = switch (ext) {
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    _ => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  };
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
  return true;
}
