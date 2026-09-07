import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cancellation_link.dart';

/// Overridden in main.dart with real Firestore; tests override with a
/// fake-backed repository.
final cancellationLinkRepositoryProvider = Provider<CancellationLinkRepository>(
    (ref) => throw UnimplementedError());

class CancellationLinkRepository {
  CancellationLinkRepository(
    this._db, {
    this.defaults = kDefaultCancellationLinks,
  });

  final FirebaseFirestore _db;
  final List<CancellationLink> defaults;

  Stream<List<CancellationLink>> watchAll() => _db
      .collection('cancellation_links')
      .snapshots()
      .map((s) {
        final map = <String, CancellationLink>{
          for (final def in defaults) def.id.toLowerCase(): def,
        };

        final docs = s.docs.toList()
          ..sort((a, b) {
            final aOrder = a.data()['sortOrder'] as num?;
            final bOrder = b.data()['sortOrder'] as num?;
            if (aOrder != null && bOrder != null) {
              return aOrder.compareTo(bOrder);
            }
            final aName = (a.data()['name'] as String? ?? '').toLowerCase();
            final bName = (b.data()['name'] as String? ?? '').toLowerCase();
            return aName.compareTo(bName);
          });

        for (final d in docs) {
          final link = CancellationLink.fromMap(d.id, d.data());
          final key = (link.id.isNotEmpty ? link.id : link.name).toLowerCase();
          map[key] = link;
        }

        if (defaults.isEmpty) {
          return docs
              .map((d) => CancellationLink.fromMap(d.id, d.data()))
              .toList(growable: false);
        }

        final ordered = <CancellationLink>[];
        for (final def in defaults) {
          final key = def.id.toLowerCase();
          if (map.containsKey(key)) {
            ordered.add(map.remove(key)!);
          }
        }
        ordered.addAll(map.values);
        return ordered;
      });
}
