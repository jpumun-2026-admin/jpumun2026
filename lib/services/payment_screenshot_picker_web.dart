// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'payment_screenshot_picker.dart';

Future<PickedScreenshot?> pickPaymentScreenshot() async {
  final input = html.FileUploadInputElement()
    ..accept = '.jpg,.jpeg,.png,.webp'
    ..multiple = false
    ..style.display = 'none';

  html.document.body?.append(input);

  final completer = Completer<PickedScreenshot?>();

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      input.remove();
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();

    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      input.remove();
      if (result is! String || !result.contains(',')) {
        completer.complete(null);
        return;
      }

      final base64Data = result.split(',').last;
      final bytes = base64Decode(base64Data);
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
      input.remove();
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Could not read the selected screenshot.'),
        );
      }
    });

    reader.readAsDataUrl(file);
  });

  input.click();
  return completer.future;
}
