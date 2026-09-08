import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:subtracker/core/brand/brand.dart';
import 'package:subtracker/core/brand/brand_colors.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/directory/data/cancellation_link.dart';
import 'package:subtracker/features/directory/logic/directory_provider.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final text = _searchController.text.trim();
    if (text != _searchQuery) {
      setState(() => _searchQuery = text);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final linksAsync = ref.watch(directoryStreamProvider);
    final colors = context.sublyColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cancellation directory'),
      ),
      body: linksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: TextStyle(color: colors.inkSecondary)),
        ),
        data: (allLinks) {
          // Extract categories
          final categories = <String>['All'];
          for (final link in allLinks) {
            if (link.category.isNotEmpty && !categories.contains(link.category)) {
              categories.add(link.category);
            }
          }

          // Filter by category and search
          final filtered = allLinks.where((link) {
            if (_selectedCategory != 'All' &&
                !link.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final matchesName = link.name.toLowerCase().contains(q);
              final matchesCategory = link.category.toLowerCase().contains(q);
              final matchesNotes = link.notes.toLowerCase().contains(q);
              return matchesName || matchesCategory || matchesNotes;
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SublySpace.screenMargin,
                  SublySpace.s8,
                  SublySpace.screenMargin,
                  SublySpace.s8,
                ),
                child: TextField(
                  key: const Key('directory-search-field'),
                  controller: _searchController,
                  style: SublyTypography.body.copyWith(color: colors.inkPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search service or keyword...',
                    hintStyle:
                        SublyTypography.body.copyWith(color: colors.inkTertiary),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: colors.inkTertiary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              LucideIcons.x,
                              size: 18,
                              color: colors.inkTertiary,
                            ),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: colors.step1,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SublySpace.s16,
                      vertical: SublySpace.s12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SublySpace.radiusField),
                      borderSide: BorderSide(color: colors.hairline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(SublySpace.radiusField),
                      borderSide: BorderSide(color: colors.inkSecondary),
                    ),
                  ),
                ),
              ),

              // Category filter chips
              if (categories.length > 1)
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: SublySpace.screenMargin),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: SublySpace.s8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == _selectedCategory;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SublySpace.s12,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? colors.step3 : colors.step1,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? colors.inkSecondary
                                    : colors.hairline,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: SublyTypography.caption.copyWith(
                                  color: isSelected
                                      ? colors.inkPrimary
                                      : colors.inkSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: SublySpace.s8),

              // Results count header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SublySpace.screenMargin,
                  vertical: SublySpace.s4,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? 'SERVICE' : 'SERVICES'}',
                      style: SublyTypography.label.copyWith(
                        color: colors.inkTertiary,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedCategory != 'All' || _searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _searchController.clear();
                          });
                        },
                        child: Text(
                          'Reset filters',
                          style: SublyTypography.caption.copyWith(
                            color: colors.inkSecondary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // List or empty state
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(context, colors)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          SublySpace.screenMargin,
                          SublySpace.s4,
                          SublySpace.screenMargin,
                          SublySpace.s24,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final link = filtered[i];
                          return _buildLinkCard(context, colors, link);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, SublyColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SublySpace.screenMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.search, size: 40, color: colors.inkTertiary),
            const SizedBox(height: SublySpace.s12),
            Text(
              'No cancellation links found',
              style: SublyTypography.titleM.copyWith(color: colors.inkPrimary),
            ),
            const SizedBox(height: SublySpace.s4),
            Text(
              'Try adjusting your search query or selected category filter.',
              style: SublyTypography.body.copyWith(color: colors.inkSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SublySpace.s16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchController.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.hairline),
                foregroundColor: colors.inkPrimary,
              ),
              child: const Text('Clear search & filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkCard(
    BuildContext context,
    SublyColors colors,
    CancellationLink link,
  ) {
    final brandColor = brandColorFromName(link.name);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SublySpace.s4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => launchUrl(
            Uri.parse(link.cancelUrl),
            mode: LaunchMode.externalApplication,
          ),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: link.cancelUrl));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied ${link.name} cancellation link to clipboard'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          borderRadius: BorderRadius.circular(SublySpace.radiusCard),
          child: Ink(
            padding: const EdgeInsets.all(SublySpace.s12),
            decoration: BoxDecoration(
              color: colors.step1,
              borderRadius: BorderRadius.circular(SublySpace.radiusCard),
              border: Border.all(color: colors.hairline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BrandTile(
                  name: link.name,
                  color: brandColor,
                  category: link.category,
                  size: 40,
                ),
                const SizedBox(width: SublySpace.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              link.name,
                              style: SublyTypography.titleM.copyWith(
                                fontSize: 15,
                                color: colors.inkPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (link.category.isNotEmpty) ...[
                            const SizedBox(width: SublySpace.s8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.step2,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: colors.hairline),
                              ),
                              child: Text(
                                link.category,
                                style: SublyTypography.caption.copyWith(
                                  fontSize: 10,
                                  color: colors.inkTertiary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (link.notes.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.corner_down_right,
                              size: 11,
                              color: colors.inkTertiary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                link.notes,
                                style: SublyTypography.caption.copyWith(
                                  color: colors.inkSecondary,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: SublySpace.s8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.step2,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.hairline),
                  ),
                  child: Icon(
                    LucideIcons.arrow_up_right,
                    size: 15,
                    color: colors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
