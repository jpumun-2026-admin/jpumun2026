import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jpumun_website/app_config.dart';

class RegistrationApiException implements Exception {
  const RegistrationApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RegistrationApi {
  static Future<Map<String, dynamic>> submitRegistration(
    Map<String, dynamic> payload,
  ) {
    return _post(payload);
  }

  static Future<Map<String, dynamic>> uploadPaymentProof({
    required String registrationType,
    required String registrationId,
    required String utr,
    required String fileName,
    required String mimeType,
    required String fileData,
  }) {
    return _post({
      'action': 'upload_payment',
      'registration_type': registrationType,
      'registration_id': registrationId,
      'utr': utr,
      'file_name': fileName,
      'mime_type': mimeType,
      'file_data': fileData,
    });
  }

  static Future<Map<String, dynamic>> _post(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse(kRegistrationApiUrl),
      headers: const {'Content-Type': 'text/plain;charset=utf-8'},
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RegistrationApiException(
        'Server returned HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const RegistrationApiException(
        'Unexpected response from registration server.',
      );
    }

    if (decoded['success'] != true) {
      throw RegistrationApiException(
        decoded['message']?.toString() ?? 'Request failed.',
      );
    }

    return decoded;
  }
}
