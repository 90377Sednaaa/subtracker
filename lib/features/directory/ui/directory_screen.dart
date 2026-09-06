import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/directory/logic/directory_provider.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(directoryStreamProvider);
    final colors = context.sublyColors;
    return Scaffold(
      appBar: AppBar(title: const Text('Cancellation directory')),
      body: links.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: TextStyle(color: colors.inkSecondary))),
        data: (list) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: SublySpace.s8),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final link = list[i];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: SublySpace.screenMargin),
              leading: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: brandColorFromName(link.name),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(link.name,
                  style: SublyTypography.titleM
                      .copyWith(fontSize: 16, color: colors.inkPrimary)),
              subtitle: Text(
                  '${link.category}${link.notes.isEmpty ? '' : ' · ${link.notes}'}',
                  style: SublyTypography.caption
                      .copyWith(color: colors.inkSecondary)),
              trailing:
                  Icon(LucideIcons.arrow_up_right, size: 18, color: colors.inkTertiary),
              onTap: () => launchUrl(Uri.parse(link.cancelUrl),
                  mode: LaunchMode.externalApplication),
            );
          },
        ),
      ),
    );
  }
}
