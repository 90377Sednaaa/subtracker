import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cancellation_link.dart';

/// Overridden in main.dart with real Firestore; tests override with a
/// fake-backed repository.
final cancellationLinkRepositoryProvider = Provider<CancellationLinkRepository>(
    (ref) => throw UnimplementedError());

class CancellationLinkRepository {
  CancellationLinkRepository(this._db);
  final FirebaseFirestore _db;

  Stream<List<CancellationLink>> watchAll() => _db
      .collection('cancellation_links')
      .orderBy('sortOrder')
      .snapshots()
      .map((s) {
        if (s.docs.isEmpty) {
          return kDefaultCancellationLinks;
        }
        return s.docs
            .map((d) => CancellationLink.fromMap(d.id, d.data()))
            .toList();
      });
}
