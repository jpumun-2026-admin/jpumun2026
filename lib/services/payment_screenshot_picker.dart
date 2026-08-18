import 'payment_screenshot_picker_stub.dart'
    if (dart.library.html) 'payment_screenshot_picker_web.dart'
    as platform;

class PickedScreenshot {
  const PickedScreenshot({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.sizeInBytes,
  });

  final List<int> bytes;
  final String fileName;
  final String mimeType;
  final int sizeInBytes;
}

Future<PickedScreenshot?> pickPaymentScreenshot() {
  return platform.pickPaymentScreenshot();
}
