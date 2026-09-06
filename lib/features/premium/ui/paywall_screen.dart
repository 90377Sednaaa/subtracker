import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sublyColors;
    // SIMULATED billing: writes the entitlement straight to Firestore.
    // Sandbox Play Billing is a stretch goal and replaces only this screen.
    Future<void> choose(String plan) async {
      HapticFeedback.mediumImpact();
      await ref
          .read(profileRepositoryProvider)
          .setPremium(premium: true, plan: plan);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    final features = [
      (LucideIcons.infinity, 'Unlimited subscriptions'),
      (LucideIcons.file_down, 'CSV export of your ledger'),
      (LucideIcons.timer, 'Custom reminder lead times'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Subly Premium')),
      body: ListView(
        padding: const EdgeInsets.all(SublySpace.screenMargin),
        children: [
          // The premium badge: the mark + wordmark, swept once by light.
          Center(
            child: Container(
              key: const Key('premium-badge'),
              padding: const EdgeInsets.symmetric(
                  horizontal: SublySpace.s16, vertical: SublySpace.s8),
              decoration: BoxDecoration(
                color: colors.step2,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.hairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SublyMark(size: 18),
                  const SizedBox(width: SublySpace.s8),
                  Text('S U B L Y   P R E M I U M',
                      style: SublyTypography.label
                          .copyWith(color: colors.inkPrimary)),
                ],
              ),
            )
                .animate(delay: 500.ms)
                .shimmer(
                  duration: 600.ms,
                  colors: [colors.hairline, colors.inkPrimary, colors.hairline],
                ),
          ),
          const SizedBox(height: SublySpace.s24),
          Text('Everything, unlocked.',
                  style:
                      SublyTypography.titleL.copyWith(color: colors.inkPrimary))
              .animate()
              .fade(duration: SublyMotion.durSlow, curve: SublyMotion.curveStandard),
          const SizedBox(height: SublySpace.s16),
          for (var i = 0; i < features.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: SublySpace.s8),
              child: Row(
                children: [
                  Icon(features[i].$1,
                      size: 20, color: colors.inkSecondary),
                  const SizedBox(width: SublySpace.s12),
                  Expanded(
                    child: Text(features[i].$2,
                        style: SublyTypography.body
                            .copyWith(color: colors.inkPrimary)),
                  ),
                ],
              )
                  .animate(delay: (150 + 60 * i).ms)
                  .fade(duration: SublyMotion.durBase)
                  .slideY(begin: 0.1, end: 0, duration: SublyMotion.durBase),
            ),
          const SizedBox(height: SublySpace.s24),
          _PlanTile(
            key: const Key('plan-monthly'),
            title: 'Monthly',
            subtitle: r'$1.99 / month',
            onTap: () => choose('monthly'),
            colors: colors,
          )
              .animate(delay: 700.ms)
              .fade(duration: SublyMotion.durBase, curve: SublyMotion.curveStandard),
          const SizedBox(height: SublySpace.s12),
          _PlanTile(
            key: const Key('plan-annual'),
            title: 'Annual',
            subtitle: r'$14.99 / year — save 37%',
            badge: 'BEST VALUE',
            onTap: () => choose('annual'),
            colors: colors,
          )
              .animate(delay: 760.ms)
              .fade(duration: SublyMotion.durBase, curve: SublyMotion.curveStandard),
          const SizedBox(height: SublySpace.s16),
          Text(
            'Simulated billing for this build — no real charge occurs.',
            style: SublyTypography.caption.copyWith(color: colors.inkTertiary),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.colors,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;
  final SublyColors colors;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colors.step2,
      child: InkWell(
        borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SublySpace.s16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: SublyTypography.titleM
                                .copyWith(color: colors.inkPrimary)),
                        if (badge != null) ...[
                          const SizedBox(width: SublySpace.s8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: SublySpace.s8, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.ctaFill,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(badge!,
                                style: SublyTypography.caption.copyWith(
                                    color: colors.inkInverse,
                                    fontSize: 9,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: SublyTypography.body
                            .copyWith(color: colors.inkSecondary)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevron_right,
                  size: 20, color: colors.inkTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
