import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sublyColors;
    return Scaffold(
      key: const Key('signin-screen'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SublySpace.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              const Center(child: SublyMark(size: 96)),
              const SizedBox(height: SublySpace.s24),
              Text('Subly',
                  textAlign: TextAlign.center,
                  style: SublyTypography.titleL.copyWith(
                    fontSize: 32,
                    color: colors.inkPrimary,
                  )),
              const SizedBox(height: SublySpace.s8),
              Text(
                'Know where your money recurs.',
                textAlign: TextAlign.center,
                style: SublyTypography.body.copyWith(color: colors.inkSecondary),
              ),
              const Spacer(flex: 4),
              FilledButton(
                key: const Key('google-sign-in'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref.read(authRepositoryProvider).signInWithGoogle();
                  } catch (e) {
                    // Config or account errors surface here instead of
                    // crashing — the message says what to fix.
                    messenger.showSnackBar(SnackBar(
                      content: Text('Sign-in failed: $e'),
                      duration: const Duration(seconds: 6),
                    ));
                  }
                },
                child: const Text('Continue with Google'),
              ),
              const SizedBox(height: SublySpace.s32),
            ],
          ),
        ),
      ),
    );
  }
}
