import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subtracker/features/directory/data/cancellation_link.dart';
import 'package:subtracker/features/directory/data/cancellation_link_repository.dart';

final directoryStreamProvider = StreamProvider<List<CancellationLink>>(
    (ref) => ref.watch(cancellationLinkRepositoryProvider).watchAll());
