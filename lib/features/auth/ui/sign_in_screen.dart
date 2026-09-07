import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/data/email_service.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/auth/ui/otp_input_row.dart';

enum AuthMode { signIn, createAccount, verifyOtp }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<OtpInputRowState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  AuthMode _mode = AuthMode.signIn;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  // OTP state
  String? _generatedOtp;
  DateTime? _otpExpiresAt;
  String _enteredOtp = '';
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    if (_mode == mode) return;
    _resendTimer?.cancel();
    setState(() {
      _mode = mode;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  String _generateOtp() {
    final rng = Random.secure();
    return (100000 + rng.nextInt(900000)).toString();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  String _cleanErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'Authentication failed.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  Future<void> _handlePrimarySubmit() async {
    if (_mode == AuthMode.signIn) {
      await _submitManualSignIn();
    } else if (_mode == AuthMode.createAccount) {
      await _sendVerificationOtp();
    } else if (_mode == AuthMode.verifyOtp) {
      await _verifyOtpAndCreateAccount();
    }
  }

  Future<void> _submitManualSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(authRepositoryProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await repo.signInWithEmailAndPassword(email, password);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _cleanErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendVerificationOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final otp = _generateOtp();

    try {
      final emailService = ref.read(emailServiceProvider);
      await emailService.sendOtpEmail(
        recipientEmail: email,
        code: otp,
      );

      if (mounted) {
        setState(() {
          _generatedOtp = otp;
          _otpExpiresAt = DateTime.now().add(const Duration(minutes: 10));
          _enteredOtp = '';
          _mode = AuthMode.verifyOtp;
          _isLoading = false;
        });
        _startResendCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not send verification email: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final otp = _generateOtp();

    try {
      final emailService = ref.read(emailServiceProvider);
      await emailService.sendOtpEmail(
        recipientEmail: email,
        code: otp,
      );

      if (mounted) {
        setState(() {
          _generatedOtp = otp;
          _otpExpiresAt = DateTime.now().add(const Duration(minutes: 10));
          _isLoading = false;
        });
        _otpKey.currentState?.clear();
        _startResendCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new verification code has been sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend code: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtpAndCreateAccount() async {
    if (_enteredOtp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the complete 6-digit code.';
      });
      return;
    }

    if (_otpExpiresAt != null && DateTime.now().isAfter(_otpExpiresAt!)) {
      setState(() {
        _errorMessage = 'Verification code has expired. Please resend code.';
      });
      return;
    }

    if (_enteredOtp != _generatedOtp) {
      setState(() {
        _errorMessage = 'Invalid verification code. Please try again.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _resendTimer?.cancel();
    final repo = ref.read(authRepositoryProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim().isEmpty
        ? null
        : _displayNameController.text.trim();

    try {
      await repo.createUserWithEmailAndPassword(
        email,
        password,
        displayName: displayName,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _cleanErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _cleanErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;

    return Scaffold(
      key: const Key('signin-screen'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: SublySpace.screenMargin,
              vertical: SublySpace.s24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: SublySpace.s12),
                  // App Brand Mark
                  const Center(
                    child: SublyLogoBadge(size: 64, radius: 2.0),
                  ),
                  const SizedBox(height: SublySpace.s24),

                  if (_mode == AuthMode.verifyOtp) ...[
                    // OTP Verification View
                    Text(
                      'Verify your email',
                      textAlign: TextAlign.center,
                      style: SublyTypography.titleL.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.5,
                        color: colors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: SublySpace.s8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: SublyTypography.body.copyWith(
                          color: colors.inkSecondary,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(text: 'We sent a 6-digit code to\n'),
                          TextSpan(
                            text: _emailController.text.trim(),
                            style: TextStyle(
                              color: colors.inkPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SublySpace.s32),

                    if (_errorMessage != null) ...[
                      _buildErrorBanner(colors),
                      const SizedBox(height: SublySpace.s16),
                    ],

                    OtpInputRow(
                      key: _otpKey,
                      onChanged: (code) => setState(() => _enteredOtp = code),
                      onCompleted: (code) {
                        _enteredOtp = code;
                        _verifyOtpAndCreateAccount();
                      },
                    ),
                    const SizedBox(height: SublySpace.s24),

                    // Resend Timer Row
                    Center(
                      child: _resendCountdown > 0
                          ? Text(
                              'Resend code in 0:${_resendCountdown.toString().padLeft(2, '0')}',
                              style: SublyTypography.caption.copyWith(
                                color: colors.inkTertiary,
                              ),
                            )
                          : TextButton(
                              key: const Key('btn-resend-otp'),
                              onPressed: _isLoading ? null : _resendOtp,
                              child: Text(
                                'Resend verification code',
                                style: SublyTypography.label.copyWith(
                                  color: colors.inkPrimary,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: SublySpace.s24),

                    // Verify Button
                    FilledButton(
                      key: const Key('auth-verify-submit'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: _isLoading ? null : _verifyOtpAndCreateAccount,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.inkInverse,
                              ),
                            )
                          : const Text('Verify & Create Account'),
                    ),
                    const SizedBox(height: SublySpace.s12),

                    // Back to edit email
                    TextButton.icon(
                      key: const Key('btn-change-email'),
                      icon: const Icon(LucideIcons.arrow_left, size: 16),
                      label: const Text('Change email address'),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.inkSecondary,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _switchMode(AuthMode.createAccount),
                    ),
                  ] else ...[
                    // Standard Sign In / Create Account Header
                    Text(
                      'Subly',
                      textAlign: TextAlign.center,
                      style: SublyTypography.titleL.copyWith(
                        fontSize: 32,
                        letterSpacing: -0.5,
                        color: colors.inkPrimary,
                      ),
                    ),
                    const SizedBox(height: SublySpace.s8),
                    Text(
                      'Know where your money recurs.',
                      textAlign: TextAlign.center,
                      style: SublyTypography.body.copyWith(
                        color: colors.inkSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: SublySpace.s32),

                    // Mode Toggle (Sign In / Create Account)
                    _AuthModeSwitch(
                      currentMode: _mode,
                      onModeChanged: _switchMode,
                    ),
                    const SizedBox(height: SublySpace.s24),

                    // Error Message banner
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(colors),
                      const SizedBox(height: SublySpace.s16),
                    ],

                    // Manual Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_mode == AuthMode.createAccount) ...[
                            TextFormField(
                              key: const Key('auth-display-name'),
                              controller: _displayNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Full name (optional)',
                                prefixIcon: Icon(
                                  LucideIcons.user,
                                  size: 18,
                                  color: colors.inkSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: SublySpace.s16),
                          ],
                          TextFormField(
                            key: const Key('auth-email'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(
                                LucideIcons.mail,
                                size: 18,
                                color: colors.inkSecondary,
                              ),
                            ),
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!text.contains('@') || !text.contains('.')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: SublySpace.s16),
                          TextFormField(
                            key: const Key('auth-password'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                LucideIcons.lock,
                                size: 18,
                                color: colors.inkSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? LucideIcons.eye_off
                                      : LucideIcons.eye,
                                  size: 18,
                                  color: colors.inkTertiary,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (value) {
                              final text = value ?? '';
                              if (text.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (text.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          if (_mode == AuthMode.createAccount) ...[
                            const SizedBox(height: SublySpace.s16),
                            TextFormField(
                              key: const Key('auth-confirm-password'),
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirm password',
                                prefixIcon: Icon(
                                  LucideIcons.lock,
                                  size: 18,
                                  color: colors.inkSecondary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? LucideIcons.eye_off
                                        : LucideIcons.eye,
                                    size: 18,
                                    color: colors.inkTertiary,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (_mode == AuthMode.createAccount) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: SublySpace.s24),
                          FilledButton(
                            key: const Key('auth-submit'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            onPressed: _isLoading ? null : _handlePrimarySubmit,
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.inkInverse,
                                    ),
                                  )
                                : Text(
                                    _mode == AuthMode.signIn
                                        ? 'Sign In'
                                        : 'Continue',
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SublySpace.s24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.hairline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: SublySpace.s16),
                          child: Text(
                            'or continue with',
                            style: SublyTypography.caption.copyWith(
                              color: colors.inkTertiary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: colors.hairline)),
                      ],
                    ),
                    const SizedBox(height: SublySpace.s24),

                    // Google Sign In Button
                    OutlinedButton(
                      key: const Key('google-sign-in'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: colors.step1,
                        side: BorderSide(color: colors.hairline),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SublySpace.radiusField),
                        ),
                      ),
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/brand/logos/google.svg',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: SublySpace.s12),
                          Flexible(
                            child: Text(
                              'Continue with Google',
                              style: SublyTypography.label.copyWith(
                                fontSize: 14,
                                color: colors.inkPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SublySpace.s16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(SublyColors colors) {
    return Container(
      padding: const EdgeInsets.all(SublySpace.s12),
      decoration: BoxDecoration(
        color: colors.step2,
        borderRadius: BorderRadius.circular(SublySpace.radiusField),
        border: Border.all(
          color: colors.statusTrial.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.circle_alert, size: 18, color: colors.statusTrial),
          const SizedBox(width: SublySpace.s8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: SublyTypography.caption.copyWith(
                color: colors.inkPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sleek segmented switch between Sign In and Create Account.
class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({
    required this.currentMode,
    required this.onModeChanged,
  });

  final AuthMode currentMode;
  final ValueChanged<AuthMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;

    Widget buildTab(String title, AuthMode mode, Key key) {
      final isSelected = currentMode == mode;
      return Expanded(
        child: GestureDetector(
          key: key,
          onTap: () => onModeChanged(mode),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: SublyMotion.durQuick,
            curve: SublyMotion.curveStandard,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? colors.step3 : Colors.transparent,
              borderRadius: BorderRadius.circular(SublySpace.radiusField - 4),
            ),
            child: Text(
              title,
              style: SublyTypography.label.copyWith(
                color: isSelected ? colors.inkPrimary : colors.inkSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.step1,
        borderRadius: BorderRadius.circular(SublySpace.radiusField),
        border: Border.all(color: colors.hairline),
      ),
      child: Row(
        children: [
          buildTab('Sign In', AuthMode.signIn, const Key('tab-sign-in')),
          buildTab('Create Account', AuthMode.createAccount,
              const Key('tab-create-account')),
        ],
      ),
    );
  }
}
