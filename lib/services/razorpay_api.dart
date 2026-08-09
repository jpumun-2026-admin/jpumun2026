import 'dart:convert';

import 'package:http/http.dart' as http;

class RazorpayOrderResponse {
  const RazorpayOrderResponse({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  final String orderId;
  final int amount;
  final String currency;
  final String keyId;
}

class RazorpayApi {
  static Uri _endpoint(String path) => Uri.base.resolve(path);

  static Future<RazorpayOrderResponse> createOrder({
    required int amount,
    String currency = 'INR',
    required String receipt,
  }) async {
    final response = await http.post(
      _endpoint('/api/create-order'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
        'receipt': receipt,
      }),
    );

    final payload = _decodeJson(response.body);
    if (response.statusCode != 200) {
      throw RazorpayApiException(
        _errorMessage(payload, fallback: 'Unable to create Razorpay order.'),
      );
    }

    return RazorpayOrderResponse(
      orderId: payload['order_id'] as String,
      amount: payload['amount'] as int,
      currency: payload['currency'] as String,
      keyId: payload['key_id'] as String,
    );
  }

  static Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await http.post(
      _endpoint('/api/verify-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    final payload = _decodeJson(response.body);
    if (response.statusCode != 200) {
      throw RazorpayApiException(
        _errorMessage(payload, fallback: 'Unable to verify payment.'),
      );
    }
  }

  static Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  static String _errorMessage(
    Map<String, dynamic> payload, {
    required String fallback,
  }) {
    final error = payload['error'];
    if (error is String && error.isNotEmpty) {
      return error;
    }

    final message = payload['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return fallback;
  }
}

class RazorpayApiException implements Exception {
  const RazorpayApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
