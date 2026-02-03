import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ai_mls/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

/// Helper class for generating and displaying QR codes
///
/// This class provides a centralized way to create QR codes using pretty_qr_code
/// library, following the project's coding standards.
class QrHelper {
  /// Build a pretty QR code widget with default styling
  ///
  /// [data] - The data to encode in the QR code
  /// [size] - The size of the QR code (default: 200.0)
  /// [decoration] - Optional custom decoration for the QR code
  ///
  /// Returns a Widget displaying the QR code
  static Widget buildPrettyQr(
    String data, {
    double size = 200.0,
    PrettyQrDecoration? decoration,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: PrettyQrView.data(
        data: data,
        decoration: decoration ?? const PrettyQrDecoration(),
      ),
    );
  }

  /// Build a QR code with embedded logo/image
  ///
  /// [data] - The data to encode in the QR code
  /// [image] - The image to embed in the center of the QR code
  /// [size] - The size of the QR code (default: 200.0)
  ///
  /// Returns a Widget displaying the QR code with embedded image
  ///
  /// Uses error correction level H (High - 30%) to ensure QR code remains
  /// scannable even when logo covers part of the code.
  /// Note: If QR code still cannot be scanned, consider using buildPrettyQr()
  /// without logo, or reduce the logo size in the image asset itself.
  static Widget buildQrWithLogo(
    String data,
    ImageProvider image, {
    double size = 200.0,
  }) {
    // Create QR code with High error correction level (30% recovery)
    // This ensures the QR code can still be scanned even with logo overlay
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    return SizedBox(
      width: size,
      height: size,
      child: PrettyQrView(
        qrImage: QrImage(qrCode),
        decoration: PrettyQrDecoration(
          image: PrettyQrDecorationImage(
            image: image,
            position: PrettyQrDecorationImagePosition.embedded,
          ),
        ),
      ),
    );
  }

  /// Export QR code as image bytes
  ///
  /// [data] - The data to encode in the QR code
  /// [size] - The size of the exported image (default: 512.0)
  /// [decoration] - Optional custom decoration for the QR code
  ///
  /// Returns Uint8List containing PNG image bytes, or null if export fails
  static Future<Uint8List?> exportQrImage(
    String data, {
    double size = 512.0,
    PrettyQrDecoration? decoration,
  }) async {
    try {
      final qrCode = QrCode.fromData(
        data: data,
        errorCorrectLevel: QrErrorCorrectLevel.H,
      );
      final qrImage = QrImage(qrCode);
      final byteData = await qrImage.toImageAsBytes(
        size: size.toInt(),
        format: ui.ImageByteFormat.png,
        decoration: decoration ?? const PrettyQrDecoration(),
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      // Log error using AppLogger
      AppLogger.error('Error exporting QR code: $e', error: e);
      return null;
    }
  }

  /// Build a QR code with custom theme colors
  ///
  /// [data] - The data to encode in the QR code
  /// [foregroundColor] - Color of the QR code pattern (not supported in current API)
  /// [backgroundColor] - Background color of the QR code (not supported in current API)
  /// [size] - The size of the QR code (default: 200.0)
  ///
  /// Returns a Widget displaying the themed QR code
  /// Note: Color customization may not be available in the current version of pretty_qr_code
  static Widget buildThemedQr(
    String data, {
    Color? foregroundColor,
    Color? backgroundColor,
    double size = 200.0,
  }) {
    // Note: Color parameters are not currently supported by the API
    // Using default decoration for now
    return SizedBox(
      width: size,
      height: size,
      child: PrettyQrView.data(
        data: data,
        decoration: const PrettyQrDecoration(),
      ),
    );
  }
}
