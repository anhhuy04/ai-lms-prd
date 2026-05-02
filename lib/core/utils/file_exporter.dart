import 'dart:typed_data';

import 'file_exporter_stub.dart'
    if (dart.library.html) 'file_exporter_web.dart'
    if (dart.library.io) 'file_exporter_mobile.dart';

/// Xuất bất kỳ file nào (xlsx, docx...): chọn thư mục trên mobile, download thẳng trên web.
/// Extension được detect tự động từ [fileName].
/// Trả về true nếu người dùng đã lưu, false nếu huỷ.
Future<bool> exportFile(Uint8List bytes, String fileName) =>
    platformExportFile(bytes, fileName);

/// Backward-compat alias cho Excel export.
Future<bool> exportExcelFile(List<int> bytes, String fileName) =>
    platformExportFile(Uint8List.fromList(bytes), fileName);
