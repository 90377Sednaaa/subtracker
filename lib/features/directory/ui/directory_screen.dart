import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subtracker/features/directory/logic/directory_provider.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(directoryStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cancellation directory')),
      body: links.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => ListView(
          children: [
            for (final link in list)
              ListTile(
                title: Text(link.name),
                subtitle: Text(
                    '${link.category}${link.notes.isEmpty ? '' : ' · ${link.notes}'}'),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => launchUrl(Uri.parse(link.cancelUrl),
                    mode: LaunchMode.externalApplication),
              ),
          ],
        ),
      ),
    );
  }
}
