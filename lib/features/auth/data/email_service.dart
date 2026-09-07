import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/core/config/email_config.dart';

abstract class EmailVerificationService {
  Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String code,
  });
}

class BrevoEmailVerificationService implements EmailVerificationService {
  BrevoEmailVerificationService({HttpClient? client})
      : _client = client ?? HttpClient();

  final HttpClient _client;

  @override
  Future<bool> sendOtpEmail({
    required String recipientEmail,
    required String code,
  }) async {
    // If no API key is configured, log code to console for safe demo/development.
    if (BrevoConfig.apiKey.trim().isEmpty) {
      developer.log(
        '=== [BrevoEmailService (Demo Mode)] ===\n'
        'Recipient: $recipientEmail\n'
        'Verification Code: $code\n'
        'To send real emails, paste your Brevo API key in lib/core/config/email_config.dart.\n'
        '========================================',
        name: 'BrevoEmailService',
      );
      return true;
    }

    final url = Uri.parse('https://api.brevo.com/v3/smtp/email');
    final htmlBody = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; background-color: #0A0A0C; color: #F2F0EB; margin: 0; padding: 40px 20px; }
    .container { max-width: 480px; margin: 0 auto; background-color: #131317; border-radius: 16px; border: 1px solid rgba(255, 255, 255, 0.08); padding: 36px 28px; text-align: center; }
    .logo { display: inline-block; width: 48px; height: 48px; background-color: #FFFFFF; border-radius: 4px; line-height: 48px; font-weight: 800; font-size: 26px; color: #0A0A0C; margin-bottom: 20px; }
    h1 { font-size: 22px; font-weight: 600; color: #F2F0EB; margin: 0 0 10px 0; }
    p { font-size: 14px; line-height: 1.5; color: rgba(242, 240, 235, 0.65); margin: 0 0 24px 0; }
    .code-box { display: inline-block; background-color: #1A1A20; border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 8px; padding: 14px 28px; font-size: 32px; font-weight: 700; letter-spacing: 8px; color: #FFFFFF; font-family: monospace; margin-bottom: 24px; }
    .footer { font-size: 12px; color: rgba(242, 240, 235, 0.4); margin-top: 24px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="logo">S</div>
    <h1>Verify your email</h1>
    <p>Use the 6-digit verification code below to complete your Subly account registration. This code expires in 10 minutes.</p>
    <div class="code-box">$code</div>
    <p>If you didn't request this code, you can safely ignore this email.</p>
    <div class="footer">&copy; Subly. Know where your money recurs.</div>
  </div>
</body>
</html>
''';

    final payload = jsonEncode({
      'sender': {
        'name': BrevoConfig.senderName,
        'email': BrevoConfig.senderEmail,
      },
      'to': [
        {'email': recipientEmail.trim()},
      ],
      'subject': '$code is your Subly verification code',
      'htmlContent': htmlBody,
    });

    try {
      final request = await _client.postUrl(url);
      request.headers.set('api-key', BrevoConfig.apiKey.trim());
      request.headers.set('content-type', 'application/json');
      request.headers.set('accept', 'application/json');
      request.add(utf8.encode(payload));

      final response = await request.close();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final respBody = await response.transform(utf8.decoder).join();
        developer.log('Brevo API error (${response.statusCode}): $respBody');
        throw StateError('Brevo email sending failed: $respBody');
      }
    } catch (e) {
      developer.log('Failed to send verification email: $e');
      rethrow;
    }
  }
}

final emailServiceProvider = Provider<EmailVerificationService>(
  (ref) => BrevoEmailVerificationService(),
);
