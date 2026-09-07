import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({
    super.key,
    this.existingId,
    this.initialPreset,
  });

  final String? existingId; // null = create
  final PresetService? initialPreset;

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cost = TextEditingController();
  final _notes = TextEditingController();
  BillingCycle _cycle = BillingCycle.monthly;
  String _currency = 'USD';
  DateTime _nextCharge = DateTime.now().add(const Duration(days: 30));
  DateTime? _trialEnds;
  int _reminderDays = 3;
  String _category = 'Other';
  String? _brandColor;
  bool _loaded = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialPreset != null) {
      _name.text = widget.initialPreset!.name;
      _category = widget.initialPreset!.category;
      _brandColor = hexToStore(widget.initialPreset!.brandColorHex);
    }
    _name.addListener(_onNameChanged);
    _loadExisting();
  }

  void _onNameChanged() {
    setState(() {});
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
      _category = sub.category;
      _notes.text = sub.notes;
      _brandColor = sub.brandColor;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _name.removeListener(_onNameChanged);
    _name.dispose();
    _cost.dispose();
    _notes.dispose();
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
      category: _category,
      notes: _notes.text.trim(),
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

  Color get _activeBrandColor {
    if (widget.initialPreset != null &&
        _name.text.trim().toLowerCase() ==
            widget.initialPreset!.name.trim().toLowerCase()) {
      return Color(widget.initialPreset!.brandColorHex);
    }
    if (_brandColor != null && _brandColor!.isNotEmpty) {
      final hex = _brandColor!.replaceFirst('#', '');
      final val = int.tryParse(hex, radix: 16);
      if (val != null) return Color(0xFF000000 | val);
    }
    if (_name.text.isNotEmpty) {
      return brandColorFromName(_name.text);
    }
    return otherColor;
  }

  String? get _activeBrandIconAsset {
    if (widget.initialPreset?.iconAsset != null &&
        _name.text.trim().toLowerCase() ==
            widget.initialPreset!.name.trim().toLowerCase()) {
      return widget.initialPreset!.iconAsset;
    }
    return brandIconAssetFromName(_name.text);
  }

  Color _categoryDotColor(String category) {
    final lowered = category.toLowerCase();
    if (lowered.contains('entertainment') || lowered.contains('streaming')) {
      return const Color(0xFFC96B6B);
    }
    if (lowered.contains('music')) return const Color(0xFF6FA97C);
    if (lowered.contains('productivity')) return const Color(0xFF7C93BE);
    if (lowered.contains('gaming')) return const Color(0xFFA08BC0);
    if (lowered.contains('books')) return const Color(0xFFC09878);
    if (lowered.contains('storage') || lowered.contains('cloud')) {
      return const Color(0xFF78A0AC);
    }
    if (lowered.contains('design')) return const Color(0xFF78A8A0);
    if (lowered.contains('education')) return const Color(0xFF58CC02);
    if (lowered.contains('utilities')) return const Color(0xFF0A85EA);
    for (final entry in categoryColorTable.entries) {
      if (lowered.contains(entry.key)) return Color(entry.value);
    }
    return otherColor;
  }

  Widget _buildGroupCard({
    required SublyColors colors,
    required Widget child,
  }) {
    return Material(
      color: colors.step1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        side: BorderSide(color: colors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SublySpace.s16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    final colors = context.sublyColors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevron_left),
          color: colors.inkPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: Hero(
          tag: widget.existingId == null
              ? 'form-new'
              : 'sub-${widget.existingId}',
          child: Text(
            widget.existingId == null
                ? 'New Subscription'
                : (_name.text.isEmpty ? 'Edit subscription' : _name.text),
            style: SublyTypography.titleM.copyWith(color: colors.inkPrimary),
          ),
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SublySpace.screenMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hero Brand Avatar with radial glow
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _activeBrandColor.withValues(alpha: 0.25),
                                _activeBrandColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        BrandGlyphTile(
                          size: 72,
                          name: _name.text.isNotEmpty
                              ? _name.text
                              : (widget.initialPreset?.name ?? 'New'),
                          color: _activeBrandColor,
                          asset: _activeBrandIconAsset,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SublySpace.s24),

                  // Grouped Card 1: Details
                  _buildGroupCard(
                    colors: colors,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const Key('name-field'),
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: 'Service name',
                            hintText: 'e.g. Netflix, Spotify',
                            labelStyle: SublyTypography.body
                                .copyWith(color: colors.inkSecondary),
                            hintStyle: SublyTypography.body
                                .copyWith(color: colors.inkTertiary),
                          ),
                          style: SublyTypography.body
                              .copyWith(color: colors.inkPrimary),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: SublySpace.s16),
                        _SegmentedCycle(
                          value: _cycle,
                          onChanged: (c) => setState(() => _cycle = c),
                        ),
                        const SizedBox(height: SublySpace.s8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            widget.existingId == null
                                ? 'Start date'
                                : 'Next charge',
                            style: SublyTypography.body
                                .copyWith(color: colors.inkPrimary),
                          ),
                          subtitle: Text(
                            dateFormat.format(_nextCharge),
                            style: SublyTypography.caption
                                .copyWith(color: colors.inkSecondary),
                          ),
                          trailing: Icon(
                            LucideIcons.calendar,
                            color: colors.inkSecondary,
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _nextCharge,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 5)),
                            );
                            if (picked != null) {
                              setState(() => _nextCharge = picked);
                            }
                          },
                        ),
                        Divider(height: 1, color: colors.hairline),
                        SwitchListTile(
                          key: const Key('trial-switch'),
                          contentPadding: EdgeInsets.zero,
                          value: _trialEnds != null,
                          onChanged: (on) => setState(() => _trialEnds =
                              on ? DateTime.now().add(const Duration(days: 30)) : null),
                          title: Text(
                            'Free trial',
                            style: SublyTypography.body
                                .copyWith(color: colors.inkPrimary),
                          ),
                          activeThumbColor: colors.inkPrimary,
                        ),
                        if (_trialEnds != null) ...[
                          Divider(height: 1, color: colors.hairline),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Trial ends',
                              style: SublyTypography.body
                                  .copyWith(color: colors.statusTrial),
                            ),
                            subtitle: Text(
                              dateFormat.format(_trialEnds!),
                              style: SublyTypography.caption
                                  .copyWith(color: colors.inkSecondary),
                            ),
                            trailing: Icon(
                              LucideIcons.calendar,
                              color: colors.inkSecondary,
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _trialEnds!,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365 * 2)),
                              );
                              if (picked != null) {
                                setState(() => _trialEnds = picked);
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: SublySpace.s16),

                  // Grouped Card 2: Amount
                  _buildGroupCard(
                    colors: colors,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const Key('cost-field'),
                            controller: _cost,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: SublyTypography.moneyRow.copyWith(
                              fontSize: 16,
                              color: colors.inkPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Cost per cycle',
                              prefixText: '$_currency ',
                              prefixStyle: SublyTypography.body.copyWith(
                                color: colors.inkSecondary,
                              ),
                              labelStyle: SublyTypography.body.copyWith(
                                color: colors.inkSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: SublySpace.s12),
                        SizedBox(
                          width: 112,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _currency,
                            dropdownColor: colors.step2,
                            style: SublyTypography.body.copyWith(
                              color: colors.inkPrimary,
                            ),
                            items: const ['USD', 'EUR', 'GBP', 'PHP', 'JPY']
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (c) =>
                                setState(() => _currency = c ?? _currency),
                            decoration: InputDecoration(
                              labelText: 'Currency',
                              labelStyle: SublyTypography.body
                                  .copyWith(color: colors.inkSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SublySpace.s16),

                  // Grouped Card 3: Categorization & Alerts
                  _buildGroupCard(
                    colors: colors,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: kSubscriptionCategories.contains(_category)
                              ? _category
                              : 'Other',
                          dropdownColor: colors.step2,
                          style: SublyTypography.body.copyWith(
                            color: colors.inkPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: SublyTypography.body
                                .copyWith(color: colors.inkSecondary),
                          ),
                          items: kSubscriptionCategories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _categoryDotColor(cat),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: SublySpace.s8),
                                  Text(cat),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (c) =>
                              setState(() => _category = c ?? 'Other'),
                        ),
                        const SizedBox(height: SublySpace.s16),
                        DropdownButtonFormField<int>(
                          initialValue: _reminderDays,
                          dropdownColor: colors.step2,
                          style: SublyTypography.body.copyWith(
                            color: colors.inkPrimary,
                          ),
                          items: const [1, 3, 5, 7]
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text('$d day(s) before')))
                              .toList(),
                          onChanged: (d) =>
                              setState(() => _reminderDays = d ?? 3),
                          decoration: InputDecoration(
                            labelText: 'Remind me',
                            labelStyle: SublyTypography.body
                                .copyWith(color: colors.inkSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SublySpace.s16),

                  // Grouped Card 4: Notes
                  _buildGroupCard(
                    colors: colors,
                    child: TextFormField(
                      key: const Key('notes-field'),
                      controller: _notes,
                      maxLines: 3,
                      style: SublyTypography.body
                          .copyWith(color: colors.inkPrimary),
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add notes, account email, or plan details',
                        labelStyle: SublyTypography.body
                            .copyWith(color: colors.inkSecondary),
                        hintStyle: SublyTypography.body
                            .copyWith(color: colors.inkTertiary),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: SublySpace.s24),

                  // Bottom Save Button
                  FilledButton(
                    key: const Key('save-button'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SublySpace.radiusField),
                      ),
                    ),
                    onPressed: _save,
                    child: Text(
                      widget.existingId == null ? 'Add Subscription' : 'Save',
                      style: SublyTypography.label.copyWith(
                        color: colors.inkInverse,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
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
