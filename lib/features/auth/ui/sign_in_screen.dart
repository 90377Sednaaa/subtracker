import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: const Key('signin-screen'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Subly', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  ref.read(authRepositoryProvider).signInWithGoogle(),
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
