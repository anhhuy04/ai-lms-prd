# QR Code Usage Guide

This guide explains how to use QR code generation in the AI LMS project using `pretty_qr_code`.

## Overview

The project uses `pretty_qr_code` for generating beautiful, customizable QR codes. A helper class `QrHelper` is provided in `lib/core/utils/qr_helper.dart` to simplify usage.

## Basic Usage

### Simple QR Code

```dart
import 'package:ai_mls/core/utils/qr_helper.dart';

// Basic QR code
QrHelper.buildPrettyQr('https://example.com')
```

### QR Code with Custom Size

```dart
QrHelper.buildPrettyQr(
  'https://example.com',
  size: 300.0,
)
```

### QR Code with Logo

```dart
QrHelper.buildQrWithLogo(
  'https://example.com',
  AssetImage('assets/logo.png'),
  size: 250.0,
)
```

### Themed QR Code

```dart
QrHelper.buildThemedQr(
  'https://example.com',
  foregroundColor: Colors.blue,
  backgroundColor: Colors.white,
  size: 200.0,
)
```

## Advanced Usage

### Custom Decoration

```dart
import 'package:pretty_qr_code/pretty_qr_code.dart';

PrettyQrView.data(
  data: 'https://example.com',
  size: 200.0,
  decoration: const PrettyQrDecoration(
    shape: PrettyQrShape.smooth,
    quietZone: PrettyQrQuietZone.standart,
    color: Colors.blue,
    background: Colors.white,
  ),
)
```

### Export QR Code as Image

```dart
final bytes = await QrHelper.exportQrImage(
  'https://example.com',
  size: 512.0,
);

if (bytes != null) {
  // Save or share the image
  // Example: save to file, share via share_plus, etc.
}
```

## Best Practices

1. **Error Correction Level**: Use `QrErrorCorrectLevel.H` (High) when embedding logos/images
2. **Size Considerations**: 
   - Minimum 200x200 for good scanability
   - Larger sizes (512+) for export/sharing
3. **Contrast**: Ensure sufficient contrast between foreground and background colors
4. **Performance**: Pre-compute QR codes if used in lists to avoid rebuild overhead

## Use Cases in AI LMS

- **Class Join Codes**: Generate QR codes for students to join classes
- **Assignment Links**: Share assignment URLs via QR codes
- **Profile Sharing**: Generate QR codes for user profiles
- **Offline Access**: Generate QR codes for offline content access

## Related Documentation

- [pretty_qr_code Package](https://pub.dev/packages/pretty_qr_code)
- [QrHelper Source Code](../lib/core/utils/qr_helper.dart)
