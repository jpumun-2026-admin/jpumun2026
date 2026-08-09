import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'razorpay_checkout_types.dart';

@JS('jpumunRazorpay')
external _RazorpayBridge? get _jsBridge;

extension type _RazorpayBridge(JSObject _) implements JSObject {
  external JSBoolean isReady();
  external void openCheckout(
    JSString optionsJson,
    JSFunction onSuccess,
    JSFunction onFailure,
    JSFunction onDismiss,
  );
}

bool get isRazorpayCheckoutSupported => kIsWeb;

bool get isRazorpayCheckoutReady {
  final bridge = _jsBridge;
  if (bridge == null) {
    return false;
  }

  return bridge.isReady().toDart;
}

Future<bool> waitForRazorpayCheckout({
  Duration timeout = const Duration(seconds: 6),
}) async {
  if (isRazorpayCheckoutReady) {
    return true;
  }

  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < timeout) {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (isRazorpayCheckoutReady) {
      return true;
    }
  }

  return isRazorpayCheckoutReady;
}

Future<RazorpayCheckoutResult> openRazorpayCheckout(
  RazorpayCheckoutOptions options,
) {
  final bridge = _jsBridge;
  if (bridge == null) {
    return Future.value(
      const RazorpayCheckoutResult.failed(
        'Razorpay checkout bridge is not available.',
      ),
    );
  }

  final completer = Completer<RazorpayCheckoutResult>();

  void complete(RazorpayCheckoutResult result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  bridge.openCheckout(
    jsonEncode(options.toJson()).toJS,
    ((JSString payload) {
      final response = jsonDecode(payload.toDart) as Map<String, dynamic>;
      complete(
        RazorpayCheckoutResult.success(
          paymentId: response['razorpay_payment_id'] as String,
          orderId: response['razorpay_order_id'] as String,
          signature: response['razorpay_signature'] as String,
        ),
      );
    }).toJS,
    ((JSString payload) {
      complete(
        RazorpayCheckoutResult.failed(_messageFromPayload(payload.toDart)),
      );
    }).toJS,
    (() {
      complete(const RazorpayCheckoutResult.dismissed());
    }).toJS,
  );

  return completer.future;
}

String _messageFromPayload(String payload) {
  try {
    final decoded = jsonDecode(payload);

    if (decoded is Map<String, dynamic>) {
      final description = decoded['description'];
      if (description is String && description.isNotEmpty) {
        return description;
      }

      final reason = decoded['reason'];
      if (reason is String && reason.isNotEmpty) {
        return reason;
      }

      final message = decoded['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
  } catch (_) {
    if (payload.isNotEmpty) {
      return payload;
    }
  }

  return 'Payment failed.';
}
