class RazorpayCheckoutOptions {
  const RazorpayCheckoutOptions({
    required this.keyId,
    required this.amount,
    required this.currency,
    required this.name,
    required this.description,
    required this.orderId,
    this.image,
    this.contact,
    this.email,
    this.themeColor = '#C9A86A',
  });

  final String keyId;
  final int amount;
  final String currency;
  final String name;
  final String description;
  final String orderId;
  final String? image;
  final String? contact;
  final String? email;
  final String themeColor;

  Map<String, Object?> toJson() {
    return {
      'key': keyId,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'image': image,
      'prefill': {
        if (contact != null && contact!.isNotEmpty) 'contact': contact,
        if (email != null && email!.isNotEmpty) 'email': email,
      },
      'theme': {'color': themeColor},
    };
  }
}

enum RazorpayCheckoutStatus { success, failed, dismissed }

class RazorpayCheckoutResult {
  const RazorpayCheckoutResult._({
    required this.status,
    this.paymentId,
    this.orderId,
    this.signature,
    this.errorMessage,
  });

  const RazorpayCheckoutResult.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) : this._(
         status: RazorpayCheckoutStatus.success,
         paymentId: paymentId,
         orderId: orderId,
         signature: signature,
       );

  const RazorpayCheckoutResult.failed(String errorMessage)
    : this._(status: RazorpayCheckoutStatus.failed, errorMessage: errorMessage);

  const RazorpayCheckoutResult.dismissed()
    : this._(status: RazorpayCheckoutStatus.dismissed);

  final RazorpayCheckoutStatus status;
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorMessage;
}
