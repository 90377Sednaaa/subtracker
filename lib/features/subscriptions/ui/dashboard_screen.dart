import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/features/subscriptions/logic/subscriptions_provider.dart';
import 'subscription_card.dart';
import 'totals_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(subscriptionsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subly')),
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
                  TotalsHeader(totals: ref.watch(totalsProvider)),
                  for (final s in list)
                    SubscriptionCard(
                      subscription: s,
                      dateFormat: DateFormat.yMMMd(),
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
