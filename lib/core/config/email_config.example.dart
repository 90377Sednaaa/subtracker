/// Example configuration template for Brevo email delivery.
///
/// To set up:
/// 1. Copy this file to `lib/core/config/email_config.dart` (which is git-ignored).
/// 2. Paste your Brevo API key into [localApiKey] or pass it via:
///      flutter run --dart-define=BREVO_API_KEY=your_key_here
/// 3. Set [senderEmail] to your verified sender email in Brevo.
class BrevoConfig {
  BrevoConfig._();

  /// Reads from compile-time environment variable:
  ///   flutter run --dart-define=BREVO_API_KEY=xkeysib-...
  /// Or falls back to [localApiKey] if defined.
  static const String _envApiKey = String.fromEnvironment('BREVO_API_KEY');

  /// Local key for development. NEVER commit your real key to public Git!
  static const String localApiKey = '';

  /// Active API key used by the email verification service.
  static String get apiKey =>
      _envApiKey.isNotEmpty ? _envApiKey : localApiKey;

  /// The verified sender email address in your Brevo account.
  static const String senderEmail = 'you@example.com';

  /// The display name for outgoing verification emails.
  static const String senderName = 'Subly';

  /// Brevo SMTP Relay host.
  static const String smtpServer = 'smtp-relay.brevo.com';

  /// Brevo SMTP Relay port (587 STARTTLS).
  static const int smtpPort = 587;

  /// Brevo SMTP Relay login.
  static const String smtpLogin = 'your_login@smtp-brevo.com';
}
