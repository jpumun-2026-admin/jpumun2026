import 'razorpay_checkout_platform_stub.dart'
    if (dart.library.html) 'razorpay_checkout_platform_web.dart'
    as platform;
import 'razorpay_checkout_types.dart';

bool get isRazorpayCheckoutSupported => platform.isRazorpayCheckoutSupported;

bool get isRazorpayCheckoutReady => platform.isRazorpayCheckoutReady;

Future<bool> waitForRazorpayCheckout({
  Duration timeout = const Duration(seconds: 6),
}) {
  return platform.waitForRazorpayCheckout(timeout: timeout);
}

Future<RazorpayCheckoutResult> openRazorpayCheckout(
  RazorpayCheckoutOptions options,
) {
  return platform.openRazorpayCheckout(options);
}
