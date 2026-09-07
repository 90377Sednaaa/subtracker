import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/subscription.dart';
import '../domain/subscription_draft.dart';

/// Overridden in main.dart with real Firestore + signed-in uid; tests
/// override with a fake-backed repository.
final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) => throw UnimplementedError());

class LimitReachedException implements Exception {
  LimitReachedException(this.freeLimit);
  final int freeLimit;
}

class SubscriptionRepository {
  SubscriptionRepository(this._db, this._uid);
  final FirebaseFirestore _db;
  final String _uid;
  static const freeLimit = 5;

  CollectionReference<Map<String, dynamic>> get _subs =>
      _db.collection('users').doc(_uid).collection('subscriptions');

  Stream<List<Subscription>> watchAll() => _subs
      .orderBy('nextChargeDate')
      .snapshots()
      .map((s) =>
          s.docs.map((d) => Subscription.fromMap(d.id, d.data())).toList());

  Future<void> add(SubscriptionDraft draft) async {
    await _guardLimit();
    await _subs.add(_mapFor(draft));
  }

  Future<void> update(String id, SubscriptionDraft draft) =>
      _subs.doc(id).update(_mapFor(draft));

  Future<void> setActive(String id, bool active) => _subs
      .doc(id)
      .update({'active': active, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> delete(String id) => _subs.doc(id).delete();

  Future<Subscription?> get(String id) async {
    final snap = await _subs.doc(id).get();
    return snap.exists ? Subscription.fromMap(snap.id, snap.data()!) : null;
  }

  Future<void> _guardLimit() async {
    final user = await _db.collection('users').doc(_uid).get();
    if (user.data()?['premium'] == true) return;
    final active = await _subs.where('active', isEqualTo: true).get();
    if (active.docs.length >= freeLimit) {
      throw LimitReachedException(freeLimit);
    }
  }

  Map<String, dynamic> _mapFor(SubscriptionDraft d) => {
        'name': d.name,
        'cost': d.cost,
        'currency': d.currency,
        'billingCycle': d.billingCycle.name,
        'nextChargeDate': Timestamp.fromDate(d.nextChargeDate),
        'trialEndsAt': d.trialEndsAt == null
            ? null
            : Timestamp.fromDate(d.trialEndsAt!),
        'reminderDaysBefore': d.reminderDaysBefore,
        'category': d.category,
        'notes': d.notes,
        'active': true,
        'brandColor': d.brandColor,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
