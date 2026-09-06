import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/profile/data/user_profile_repository.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SIMULATED billing: writes the entitlement straight to Firestore.
    // Sandbox Play Billing is a stretch goal and replaces only this screen.
    Future<void> choose(String plan) async {
      await ref
          .read(profileRepositoryProvider)
          .setPremium(premium: true, plan: plan);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Subly Premium')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Unlimited subscriptions, CSV export, custom reminders'),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              key: const Key('plan-monthly'),
              title: const Text('Monthly'),
              subtitle: const Text(r'$1.99 / month'),
              onTap: () => choose('monthly'),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('plan-annual'),
              title: const Text('Annual'),
              subtitle: const Text(r'$14.99 / year — save 37%'),
              onTap: () => choose('annual'),
            ),
          ),
        ],
      ),
    );
  }
}
