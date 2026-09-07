import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/auth/logic/auth_controller.dart';
import 'package:subtracker/features/subscriptions/data/subscription_repository.dart';
import 'package:subtracker/features/subscriptions/domain/billing_cycle.dart';
import 'package:subtracker/features/subscriptions/domain/subscription.dart';
import 'package:subtracker/features/subscriptions/domain/subscription_draft.dart';
import 'package:subtracker/features/subscriptions/logic/subscriptions_provider.dart';
import 'calendar_view.dart';
import 'hero_spend_header.dart';
import 'renewal_strip.dart';
import 'subscription_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialView = ref.read(dashboardViewProvider);
    _pageController = PageController(
      initialPage: initialView == DashboardView.calendar ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onViewChanged(DashboardView view) {
    final targetPage = view == DashboardView.calendar ? 0 : 1;
    if (_pageController.hasClients &&
        _pageController.page?.round() != targetPage) {
      _pageController.animateToPage(
        targetPage,
        duration: SublyMotion.durBase,
        curve: SublyMotion.curveStandard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DashboardView>(dashboardViewProvider, (_, next) {
      _onViewChanged(next);
    });

    final auth = ref.watch(firebaseAuthProvider);
    // The router inflates this route for one frame before the first auth
    // event lands; never touch repositories until a signed-in user exists.
    if (!auth.hasValue || auth.value == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final subs = ref.watch(subscriptionsStreamProvider);
    final view = ref.watch(dashboardViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SublyLogoBadge(size: 24, radius: 2.0),
            SizedBox(width: SublySpace.s8),
            Flexible(
              child: Text(
                'Subly',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.link_2),
            tooltip: 'Cancellation directory',
            onPressed: () => context.push('/directory'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.settings_2),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/subs/new'),
        child: const Icon(LucideIcons.plus),
      ),
      body: subs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SublySpace.s8),
            _ViewToggle(current: view),
            Expanded(
              child: list.isEmpty
                  ? const _EmptyState()
                  : PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        ref.read(dashboardViewProvider.notifier).set(
                              index == 0
                                  ? DashboardView.calendar
                                  : DashboardView.ledger,
                            );
                      },
                      children: [
                        CalendarView(
                          key: const Key('calendar-view'),
                          subscriptions: list,
                          monthlyTotalByCurrency: ref.watch(totalsProvider),
                          now: DateTime.now(),
                        ),
                        _LedgerList(list: list),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calendar | Ledger — the sliding segmented pill toggle with haptic feedback.
class _ViewToggle extends ConsumerWidget {
  const _ViewToggle({required this.current});

  final DashboardView current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.sublyColors;
    final isCalendar = current == DashboardView.calendar;

    return Padding(
      key: const Key('view-toggle'),
      padding: const EdgeInsets.symmetric(horizontal: SublySpace.screenMargin),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.step2,
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
          border: Border.all(color: colors.hairline),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pillWidth = (constraints.maxWidth - 4) / 2;
            return Stack(
              children: [
                AnimatedAlign(
                  duration: SublyMotion.durQuick,
                  curve: SublyMotion.curveStandard,
                  alignment: isCalendar
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: pillWidth,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.step3,
                      borderRadius:
                          BorderRadius.circular(SublySpace.radiusCard - 4),
                      border: Border.all(color: colors.hairline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(dashboardViewProvider.notifier)
                              .set(DashboardView.calendar);
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: isCalendar
                                    ? colors.inkPrimary
                                    : colors.inkTertiary,
                              ),
                              const SizedBox(width: SublySpace.s8),
                              Text(
                                'Calendar',
                                style: SublyTypography.body.copyWith(
                                  color: isCalendar
                                      ? colors.inkPrimary
                                      : colors.inkTertiary,
                                  fontWeight: isCalendar
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(dashboardViewProvider.notifier)
                              .set(DashboardView.ledger);
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.receipt,
                                size: 16,
                                color: !isCalendar
                                    ? colors.inkPrimary
                                    : colors.inkTertiary,
                              ),
                              const SizedBox(width: SublySpace.s8),
                              Text(
                                'Ledger',
                                style: SublyTypography.body.copyWith(
                                  color: !isCalendar
                                      ? colors.inkPrimary
                                      : colors.inkTertiary,
                                  fontWeight: !isCalendar
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LedgerList extends ConsumerStatefulWidget {
  const _LedgerList({required this.list});

  final List<Subscription> list;

  @override
  ConsumerState<_LedgerList> createState() => _LedgerListState();
}

class _LedgerListState extends ConsumerState<_LedgerList> {
  String _activeFilter = 'All';

  List<Subscription> get _filteredList {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_activeFilter) {
      case 'Renewing Soon':
        return widget.list.where((s) {
          final diff = s.nextChargeDate.difference(today).inDays;
          return diff >= 0 && diff <= 7;
        }).toList();
      case 'Monthly':
        return widget.list
            .where((s) => s.billingCycle == BillingCycle.monthly)
            .toList();
      case 'Annual':
        return widget.list
            .where((s) => s.billingCycle == BillingCycle.annual)
            .toList();
      case 'All':
      default:
        return widget.list;
    }
  }

  int get _renewingSoonCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.list.where((s) {
      final diff = s.nextChargeDate.difference(today).inDays;
      return diff >= 0 && diff <= 7;
    }).length;
  }

  int get _monthlyCount =>
      widget.list.where((s) => s.billingCycle == BillingCycle.monthly).length;

  int get _annualCount =>
      widget.list.where((s) => s.billingCycle == BillingCycle.annual).length;

  Future<void> _markPaid(BuildContext context, Subscription sub) async {
    HapticFeedback.mediumImpact();
    final nextDate = sub.billingCycle.advance(sub.nextChargeDate);
    await ref.read(subscriptionRepositoryProvider).update(
          sub.id,
          SubscriptionDraft(
            name: sub.name,
            cost: sub.cost,
            currency: sub.currency,
            billingCycle: sub.billingCycle,
            nextChargeDate: nextDate,
            trialEndsAt: null,
            reminderDaysBefore: sub.reminderDaysBefore,
            brandColor: sub.brandColor,
            category: sub.category,
            notes: sub.notes,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${sub.name} advanced to ${DateFormat.yMMMd().format(nextDate)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, Subscription sub) async {
    final colors = context.sublyColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.step2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
          side: BorderSide(color: colors.hairline),
        ),
        title: Text(
          'Delete Subscription',
          style: SublyTypography.titleM.copyWith(color: colors.inkPrimary),
        ),
        content: Text(
          'Are you sure you want to remove ${sub.name}? This will delete all tracking and reminders for this subscription.',
          style: SublyTypography.body.copyWith(color: colors.inkSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child:
                Text('Cancel', style: TextStyle(color: colors.inkSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(subscriptionRepositoryProvider).delete(sub.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sub.name} deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildFilterChips(SublyColors colors) {
    final filters = [
      ('All', widget.list.length),
      ('Renewing Soon', _renewingSoonCount),
      ('Monthly', _monthlyCount),
      ('Annual', _annualCount),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: SublySpace.screenMargin),
      child: Row(
        children: [
          for (final (label, count) in filters) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeFilter = label);
              },
              child: AnimatedContainer(
                duration: SublyMotion.durQuick,
                padding: const EdgeInsets.symmetric(
                  horizontal: SublySpace.s12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _activeFilter == label ? colors.step3 : colors.step1,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _activeFilter == label
                        ? colors.inkPrimary
                        : colors.hairline,
                    width: _activeFilter == label ? 1.2 : 1.0,
                  ),
                ),
                child: Text(
                  '$label ($count)',
                  style: SublyTypography.caption.copyWith(
                    color: _activeFilter == label
                        ? colors.inkPrimary
                        : colors.inkTertiary,
                    fontWeight: _activeFilter == label
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SublySpace.s8),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    final displayList = _filteredList;

    return ListView(
      children: [
        HeroSpendHeader(
          totals: ref.watch(totalsProvider),
          subCount: widget.list.where((s) => s.active).length,
          now: DateTime.now(),
        ),
        RenewalStrip(
          upcoming: ref.watch(next7DaysProvider),
          now: DateTime.now(),
        ),
        const SizedBox(height: SublySpace.s24),
        _buildFilterChips(colors),
        const SizedBox(height: SublySpace.s12),
        if (displayList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(SublySpace.s32),
            child: Center(
              child: Text(
                'No subscriptions match "$_activeFilter"',
                style: SublyTypography.body.copyWith(color: colors.inkTertiary),
              ),
            ),
          )
        else
          for (var i = 0; i < displayList.length; i++)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SublySpace.screenMargin,
                SublySpace.s8,
                SublySpace.screenMargin,
                SublySpace.s8,
              ),
              child: SubscriptionCard(
                subscription: displayList[i],
                dateFormat: DateFormat.yMMMd(),
                onMarkPaid: (sub) => _markPaid(context, sub),
                onDelete: (sub) => _confirmDelete(context, sub),
              )
                  .animate(
                    delay: (SublyMotion.stagger.inMilliseconds * i).ms,
                  )
                  .fade(duration: SublyMotion.durBase)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: SublyMotion.durBase,
                    curve: SublyMotion.curveStandard,
                  ),
            ),
        const SizedBox(height: SublySpace.s32),
      ],
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
