import 'razorpay_checkout_types.dart';

const bool isRazorpayCheckoutSupported = false;
const bool isRazorpayCheckoutReady = false;

Future<bool> waitForRazorpayCheckout({
  Duration timeout = const Duration(seconds: 6),
}) async {
  return false;
}

Future<RazorpayCheckoutResult> openRazorpayCheckout(
  RazorpayCheckoutOptions options,
) async {
  return const RazorpayCheckoutResult.failed(
    'Razorpay checkout is only available on Flutter web.',
  );
}
