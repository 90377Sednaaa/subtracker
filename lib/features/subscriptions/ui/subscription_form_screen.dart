import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
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
  String? _brandColor;
  bool _loaded = true;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  /// Edit mode: preload the stored subscription so the form opens filled.
  Future<void> _loadExisting() async {
    if (widget.existingId == null) return;
    setState(() => _loaded = false);
    final sub =
        await ref.read(subscriptionRepositoryProvider).get(widget.existingId!);
    if (!mounted || sub == null) return;
    setState(() {
      _name.text = sub.name;
      _cost.text = sub.cost.toStringAsFixed(2);
      _currency = sub.currency;
      _cycle = sub.billingCycle;
      _nextCharge = sub.nextChargeDate;
      _trialEnds = sub.trialEndsAt;
      _reminderDays = sub.reminderDaysBefore;
      _brandColor = sub.brandColor;
      _loaded = true;
    });
  }

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
      brandColor: _brandColor,
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
    final colors = context.sublyColors;
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: widget.existingId == null
              ? 'form-new'
              : 'sub-${widget.existingId}',
          child: Text(widget.existingId == null
              ? 'Add subscription'
              : _name.text.isEmpty
                  ? 'Edit subscription'
                  : _name.text),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(SublySpace.screenMargin),
                children: [
                  TextFormField(
                    key: const Key('name-field'),
                    controller: _name,
                    decoration:
                        const InputDecoration(labelText: 'Service name'),
                    style: SublyTypography.body
                        .copyWith(color: colors.inkPrimary),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter a name' : null,
                  ),
                  const SizedBox(height: SublySpace.s16),
                  TextFormField(
                    key: const Key('cost-field'),
                    controller: _cost,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: SublyTypography.moneyRow.copyWith(
                      fontSize: 15,
                      color: colors.inkPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Cost per cycle',
                      prefixText: '$_currency ',
                      labelStyle: SublyTypography.body
                          .copyWith(color: colors.inkSecondary),
                    ),
                  ),
                  const SizedBox(height: SublySpace.s16),
                  _SegmentedCycle(
                    value: _cycle,
                    onChanged: (c) => setState(() => _cycle = c),
                  ),
                  const SizedBox(height: SublySpace.s16),
                  DropdownButtonFormField<String>(
                    initialValue: _currency,
                    dropdownColor: colors.step2,
                    style: SublyTypography.body.copyWith(
                      color: colors.inkPrimary,
                    ),
                    items: const ['USD', 'EUR', 'GBP', 'PHP', 'JPY']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (c) => setState(() => _currency = c ?? _currency),
                    decoration: const InputDecoration(labelText: 'Currency'),
                  ),
                  const SizedBox(height: SublySpace.s16),
                  Text('Brand color',
                      style: SublyTypography.label
                          .copyWith(color: colors.inkTertiary)),
                  const SizedBox(height: SublySpace.s8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final choice in swatchChoices)
                        GestureDetector(
                          onTap: () => setState(
                              () => _brandColor = hexToStore(choice.hex)),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: choice.hex == null
                                  ? colors.step1
                                  : Color(choice.hex!),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _brandColor == hexToStore(choice.hex)
                                    ? colors.inkPrimary
                                    : colors.hairline,
                                width: 2,
                              ),
                            ),
                            child: choice.hex == null
                                ? Center(
                                    child: Text('A',
                                        style: SublyTypography.label.copyWith(
                                            color: colors.inkSecondary)))
                                : null,
                          ),
                        ),
                    ],
                  ),
                  SwitchListTile(
                    key: const Key('trial-switch'),
                    value: _trialEnds != null,
                    onChanged: (on) => setState(() => _trialEnds =
                        on ? DateTime.now().add(const Duration(days: 30)) : null),
                    title: Text('Free trial',
                        style: SublyTypography.body
                            .copyWith(color: colors.inkPrimary)),
                    activeThumbColor: colors.inkPrimary,
                  ),
                  if (_trialEnds != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Trial ends',
                          style: SublyTypography.body
                              .copyWith(color: colors.statusTrial)),
                      subtitle: Text(dateFormat.format(_trialEnds!),
                          style: SublyTypography.caption
                              .copyWith(color: colors.inkSecondary)),
                      trailing: Icon(Icons.calendar_month,
                          color: colors.inkSecondary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _trialEnds!,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (picked != null) setState(() => _trialEnds = picked);
                      },
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Next charge',
                          style: SublyTypography.body
                              .copyWith(color: colors.inkPrimary)),
                      subtitle: Text(dateFormat.format(_nextCharge),
                          style: SublyTypography.caption
                              .copyWith(color: colors.inkSecondary)),
                      trailing: Icon(Icons.calendar_month,
                          color: colors.inkSecondary),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _nextCharge,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) setState(() => _nextCharge = picked);
                      },
                    ),
                  DropdownButtonFormField<int>(
                    initialValue: _reminderDays,
                    dropdownColor: colors.step2,
                    style: SublyTypography.body.copyWith(
                      color: colors.inkPrimary,
                    ),
                    items: [1, 3, 5, 7]
                        .map((d) => DropdownMenuItem(
                            value: d, child: Text('$d day(s) before')))
                        .toList(),
                    onChanged: (d) => setState(() => _reminderDays = d ?? 3),
                    decoration: const InputDecoration(labelText: 'Remind me'),
                  ),
                  const SizedBox(height: SublySpace.s24),
                  FilledButton(
                    key: const Key('save-button'),
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56)),
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Weekly / Monthly / Annual — monochrome segmented selector with an
/// animated thumb. Thumb width is exactly (track width) / 3: asserted
/// in test/ui/ledger_card_test.dart.
class _SegmentedCycle extends StatelessWidget {
  const _SegmentedCycle({required this.value, required this.onChanged});

  final BillingCycle value;
  final ValueChanged<BillingCycle> onChanged;

  Alignment _alignmentFor(BillingCycle c) => switch (c) {
        BillingCycle.weekly => Alignment.centerLeft,
        BillingCycle.monthly => Alignment.center,
        BillingCycle.annual => Alignment.centerRight,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final thumbWidth = (trackWidth - 8) / 3;
        return Container(
          key: const Key('cycle-track'),
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.step1,
            borderRadius: BorderRadius.circular(SublySpace.radiusField),
            border: Border.all(color: colors.hairline),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: SublyMotion.durInstant,
                curve: SublyMotion.curveStandard,
                alignment: _alignmentFor(value),
                child: Container(
                  key: const Key('cycle-thumb'),
                  width: thumbWidth,
                  decoration: BoxDecoration(
                    color: colors.ctaFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final c in BillingCycle.values)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(c),
                        child: Center(
                          child: Text(
                            c.name,
                            style: SublyTypography.label.copyWith(
                              color: c == value
                                  ? colors.inkInverse
                                  : colors.inkSecondary,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
