import 'package:flutter_test/flutter_test.dart';
import 'package:subtracker/core/config/email_config.dart';
import 'package:subtracker/features/auth/data/email_service.dart';

void main() {
  test('BrevoEmailVerificationService runs safely in demo mode when apiKey is empty',
      () async {
    final service = BrevoEmailVerificationService();
    final result = await service.sendOtpEmail(
      recipientEmail: 'test@subly.app',
      code: '123456',
    );
    expect(result, isTrue);
  });

  test('BrevoConfig default sender matches user configuration', () {
    expect(BrevoConfig.senderEmail, equals('leanmurillo0201@gmail.com'));
    expect(BrevoConfig.senderName, equals('Subly'));
    expect(BrevoConfig.smtpServer, equals('smtp-relay.brevo.com'));
    expect(BrevoConfig.smtpPort, equals(587));
  });
}
