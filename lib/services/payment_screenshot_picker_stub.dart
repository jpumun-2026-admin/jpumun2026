import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'payment_screenshot_picker.dart';

Future<PickedScreenshot?> pickPaymentScreenshot() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowMultiple: false,
    withData: true,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
  );

  if (result == null || result.files.isEmpty) {
    return null;
  }

  final file = result.files.single;
  final bytes = file.bytes;
  if (bytes == null || bytes.isEmpty) {
    return null;
  }

  final mimeType = file.extension == null
      ? ''
      : _mimeTypeFromExtension(file.extension!.toLowerCase());

  return PickedScreenshot(
    bytes: Uint8List.fromList(bytes),
    fileName: file.name,
    mimeType: mimeType,
    sizeInBytes: bytes.length,
  );
}

String _mimeTypeFromExtension(String extension) {
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      return '';
  }
}
