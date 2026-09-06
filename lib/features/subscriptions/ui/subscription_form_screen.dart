import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({super.key, this.existingId});

  final String? existingId; // null = create

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cost = TextEditingController();
  BillingCycle _cycle = BillingCycle.monthly;
  String _currency = 'USD';
  DateTime _nextCharge = DateTime.now().add(const Duration(days: 30));
  DateTime? _trialEnds;
  int _reminderDays = 3;

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cost = double.tryParse(_cost.text.trim());
    if (cost == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid cost')));
      return;
    }
    final draft = SubscriptionDraft(
      name: _name.text.trim(),
      cost: cost,
      currency: _currency,
      billingCycle: _cycle,
      // While trialing, the first charge IS the trial end date.
      nextChargeDate: _trialEnds ?? _nextCharge,
      trialEndsAt: _trialEnds,
      reminderDaysBefore: _reminderDays,
    );
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      if (widget.existingId == null) {
        await repo.add(draft);
      } else {
        await repo.update(widget.existingId!, draft);
      }
      if (mounted) Navigator.of(context).pop();
    } on LimitReachedException {
      if (mounted) context.push('/paywall');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existingId == null
              ? 'Add subscription'
              : 'Edit subscription')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('name-field'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Service name'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a name' : null,
            ),
            TextFormField(
              key: const Key('cost-field'),
              controller: _cost,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cost per cycle',
                prefixText: '$_currency ',
              ),
            ),
            DropdownButtonFormField<BillingCycle>(
              key: const Key('cycle-field'),
              initialValue: _cycle,
              items: BillingCycle.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) => setState(() => _cycle = c ?? _cycle),
              decoration: const InputDecoration(labelText: 'Billing cycle'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              items: const ['USD', 'EUR', 'GBP', 'PHP', 'JPY']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (c) => setState(() => _currency = c ?? _currency),
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            SwitchListTile(
              key: const Key('trial-switch'),
              value: _trialEnds != null,
              onChanged: (on) => setState(() => _trialEnds =
                  on ? DateTime.now().add(const Duration(days: 30)) : null),
              title: const Text('Free trial'),
            ),
            if (_trialEnds != null)
              ListTile(
                title: const Text('Trial ends'),
                subtitle: Text(dateFormat.format(_trialEnds!)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _trialEnds!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) setState(() => _trialEnds = picked);
                },
              )
            else
              ListTile(
                title: const Text('Next charge'),
                subtitle: Text(dateFormat.format(_nextCharge)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _nextCharge,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) setState(() => _nextCharge = picked);
                },
              ),
            DropdownButtonFormField<int>(
              initialValue: _reminderDays,
              items: const [1, 3, 5, 7]
                  .map((d) => DropdownMenuItem(
                      value: d, child: Text('$d day(s) before')))
                  .toList(),
              onChanged: (d) => setState(() => _reminderDays = d ?? 3),
              decoration: const InputDecoration(labelText: 'Remind me'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('save-button'),
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
