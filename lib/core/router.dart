import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(firebaseAuthProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(firebaseAuthProvider);
      // Wait for the first auth event before deciding — avoids a
      // sign-in-flash for already-signed-in users.
      if (auth.isLoading && !auth.hasValue) return null;
      final loggedIn = auth.value != null;
      final signingIn = state.matchedLocation == '/signin';
      if (!loggedIn) return signingIn ? null : '/signin';
      if (signingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        pageBuilder: (_, _) => const NoTransitionPage(
            child: SizedBox.shrink(key: Key('signin-screen'))),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (_, _) => const NoTransitionPage(child: SizedBox.shrink()),
      ),
    ],
  );
});

class SubtrackerApp extends ConsumerWidget {
  const SubtrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Subly',
      theme: ref.watch(appThemeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
