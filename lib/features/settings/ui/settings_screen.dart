import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/premium/logic/csv_export.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';
import 'package:subtracker/features/subscriptions/logic/subscriptions_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sublyColors;
    final profile = ref.watch(profileStreamProvider);
    final isPremium = profile.value?.premium ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text(isPremium
                ? 'Premium active'
                : 'Free plan (5 subscription limit)'),
            subtitle: Text(profile.value?.email ?? ''),
          ),
          if (!isPremium)
            ListTile(
              leading:
                  Icon(LucideIcons.gem, size: 20, color: colors.inkSecondary),
              title: const Text('Upgrade to Premium'),
              onTap: () => context.push('/paywall'),
            ),
          if (isPremium)
            ListTile(
              leading: Icon(LucideIcons.file_down,
                  size: 20, color: colors.inkSecondary),
              title: const Text('Export subscriptions (CSV)'),
              onTap: () {
                // Read the already-loaded stream state — .future would hang
                // on Firestore's never-completing snapshots stream (riverpod 3).
                final subs = ref.read(subscriptionsStreamProvider).value;
                if (subs == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Still loading, try again')));
                  return;
                }
                Clipboard.setData(
                    ClipboardData(text: subscriptionsToCsv(subs)));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV copied to clipboard')));
              },
            ),
          SwitchListTile(
            title: const Text('Dark theme'),
            value: ref.watch(themeModeProvider) == ThemeMode.dark,
            onChanged: (dark) => ref
                .read(themeModeProvider.notifier)
                .set(dark ? ThemeMode.dark : ThemeMode.light),
          ),
          ListTile(
            leading:
                Icon(LucideIcons.log_out, size: 20, color: colors.inkSecondary),
            title: const Text('Sign out'),
            onTap: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
    );
  }
}
