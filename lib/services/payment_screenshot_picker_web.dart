// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'payment_screenshot_picker.dart';

Future<PickedScreenshot?> pickPaymentScreenshot() async {
  final input = html.FileUploadInputElement()
    ..accept = '.jpg,.jpeg,.png,.webp'
    ..multiple = false;

  final completer = Completer<PickedScreenshot?>();

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();

    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      if (result is! ByteBuffer) {
        completer.complete(null);
        return;
      }

      final bytes = Uint8List.view(result);
      completer.complete(
        PickedScreenshot(
          bytes: bytes,
          fileName: file.name,
          mimeType: file.type,
          sizeInBytes: bytes.length,
        ),
      );
    });

    reader.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Could not read the selected screenshot.'),
        );
      }
    });

    reader.readAsArrayBuffer(file);
  });

  input.click();
  return completer.future;
}
