import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:subtracker/core/brand/brand.dart';
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
    final subsAsync = ref.watch(subscriptionsStreamProvider);
    final isPremium = profile.value?.premium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SublyLogoBadge(size: 24, radius: 2.0),
            SizedBox(width: SublySpace.s8),
            Flexible(
              child: Text(
                'Settings',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const SublyLogoBadge(size: 36, radius: 2.0),
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
              onTap: () async {
                HapticFeedback.lightImpact();
                final subs = subsAsync.value;
                if (subs == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Still loading, try again')));
                  return;
                }
                if (subs.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No subscriptions to export')));
                  return;
                }
                try {
                  await ref
                      .read(csvShareServiceProvider)
                      .shareSubscriptionsCsv(subscriptions: subs);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')));
                  }
                }
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
            onTap: () async {
              HapticFeedback.lightImpact();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: colors.step2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SublySpace.radiusCard),
                    side: BorderSide(color: colors.hairline),
                  ),
                  title: Text(
                    'Sign Out',
                    style: SublyTypography.titleM
                        .copyWith(color: colors.inkPrimary),
                  ),
                  content: Text(
                    'Are you sure you want to sign out of your account?',
                    style: SublyTypography.body
                        .copyWith(color: colors.inkSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: colors.inkSecondary),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.ctaFill,
                        foregroundColor: colors.inkInverse,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SublySpace.radiusField),
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authRepositoryProvider).signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
