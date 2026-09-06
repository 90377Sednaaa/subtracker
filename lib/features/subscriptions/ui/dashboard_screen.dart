import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/subscriptions/logic/subscriptions_provider.dart';
import 'hero_spend_header.dart';
import 'renewal_strip.dart';
import 'subscription_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    // The router inflates this route for one frame before the first auth
    // event lands; never touch repositories until a signed-in user exists.
    if (!auth.hasValue || auth.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final subs = ref.watch(subscriptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subly'), actions: [
        IconButton(
          icon: const Icon(Icons.link),
          tooltip: 'Cancellation directory',
          onPressed: () => context.push('/directory'),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/subs/new'),
        child: const Icon(Icons.add),
      ),
      body: subs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const _EmptyState()
            : ListView(
                children: [
                  HeroSpendHeader(
                    totals: ref.watch(totalsProvider),
                    subCount: list.where((s) => s.active).length,
                    now: DateTime.now(),
                  ),
                  RenewalStrip(
                    upcoming: ref.watch(next7DaysProvider),
                    now: DateTime.now(),
                  ),
                  const SizedBox(height: SublySpace.s8),
                  for (var i = 0; i < list.length; i++)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        SublySpace.screenMargin,
                        SublySpace.s8,
                        SublySpace.screenMargin,
                        SublySpace.s8,
                      ),
                      child: SubscriptionCard(
                        subscription: list[i],
                        dateFormat: DateFormat.yMMMd(),
                      )
                          .animate(
                            delay: (SublyMotion.stagger.inMilliseconds * i)
                                .ms,
                          )
                          .fade(duration: SublyMotion.durBase)
                          .slideY(
                            begin: 0.04,
                            end: 0,
                            duration: SublyMotion.durBase,
                            curve: SublyMotion.curveStandard,
                          ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('empty-state'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.subscriptions, size: 48),
          const SizedBox(height: 12),
          Text('No subscriptions yet',
              style: Theme.of(context).textTheme.titleMedium),
          const Text('Tap + to add your first one'),
        ],
      ),
    );
  }
}
