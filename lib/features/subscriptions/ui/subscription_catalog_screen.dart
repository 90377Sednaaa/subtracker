import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:subtracker/core/brand/brand_icons.dart';
import 'package:subtracker/core/theme.dart';
import 'package:subtracker/features/subscriptions/domain/preset_service.dart';

class SubscriptionCatalogScreen extends StatefulWidget {
  const SubscriptionCatalogScreen({super.key, this.onSelect});

  final ValueChanged<PresetService?>? onSelect;

  @override
  State<SubscriptionCatalogScreen> createState() =>
      _SubscriptionCatalogScreenState();
}

class _SubscriptionCatalogScreenState
    extends State<SubscriptionCatalogScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSelect(BuildContext context, PresetService? service) {
    if (widget.onSelect != null) {
      widget.onSelect!(service);
    } else {
      context.push('/subs/new/config', extra: service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.sublyColors;
    final filteredServices =
        kPresetServices.where((s) => s.matchesQuery(_query)).toList();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: SublySpace.s8),
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                'Cancel',
                style: SublyTypography.body.copyWith(
                  color: colors.inkSecondary,
                ),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Add Subscription',
          style: SublyTypography.titleM.copyWith(color: colors.inkPrimary),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SublySpace.screenMargin,
              vertical: SublySpace.s12,
            ),
            child: Text(
              'ALL SERVICES',
              style: SublyTypography.label.copyWith(
                color: colors.inkTertiary,
              ),
            ),
          ),
          Expanded(
            child: filteredServices.isEmpty
                ? _buildEmptyState(context, colors)
                : _buildGrid(context, colors, filteredServices),
          ),
          _buildBottomSearchBar(context, colors),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    SublyColors colors,
    List<PresetService> services,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: SublySpace.screenMargin,
        vertical: SublySpace.s8,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: services.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCustomCard(context, colors);
        }
        final service = services[index - 1];
        return _buildPresetCard(context, colors, service);
      },
    );
  }

  Widget _buildCustomCard(BuildContext context, SublyColors colors) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('custom-service-card'),
        onTap: () => _handleSelect(context, null),
        borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.step1,
            borderRadius: BorderRadius.circular(SublySpace.radiusCard),
            border: Border.all(color: colors.hairline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.step2,
                  border: Border.all(
                    color: colors.hairline,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  LucideIcons.plus,
                  size: 24,
                  color: colors.inkPrimary,
                ),
              ),
              const SizedBox(height: SublySpace.s12),
              Text(
                'Custom',
                style: SublyTypography.label.copyWith(
                  color: colors.inkPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetCard(
    BuildContext context,
    SublyColors colors,
    PresetService service,
  ) {
    final brandColor = Color(service.brandColorHex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(
            'preset-${service.name.toLowerCase().replaceAll(' ', '-')}-card'),
        onTap: () => _handleSelect(context, service),
        borderRadius: BorderRadius.circular(SublySpace.radiusCard),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.step1,
            borderRadius: BorderRadius.circular(SublySpace.radiusCard),
            border: Border.all(color: colors.hairline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: BrandGlyphTile(
                  asset: service.iconAsset,
                  name: service.name,
                  color: brandColor,
                  size: 48,
                ),
              ),
              const SizedBox(height: SublySpace.s12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SublySpace.s8),
                child: Text(
                  service.name,
                  style: SublyTypography.label.copyWith(
                    color: colors.inkPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, SublyColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SublySpace.screenMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 48,
              color: colors.inkTertiary,
            ),
            const SizedBox(height: SublySpace.s16),
            Text(
              'No services found for "$_query"',
              style: SublyTypography.titleM.copyWith(color: colors.inkPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SublySpace.s8),
            Text(
              "Can't find what you're looking for?",
              style: SublyTypography.body.copyWith(color: colors.inkSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SublySpace.s24),
            FilledButton.icon(
              key: const Key('empty-add-custom-button'),
              onPressed: () => _handleSelect(context, null),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add custom subscription'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.step2,
                foregroundColor: colors.inkPrimary,
                side: BorderSide(color: colors.hairline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar(BuildContext context, SublyColors colors) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(SublySpace.screenMargin),
        decoration: BoxDecoration(
          color: colors.base,
          border: Border(top: BorderSide(color: colors.hairline)),
        ),
        child: TextField(
          key: const Key('catalog-search-field'),
          controller: _searchController,
          style: SublyTypography.body.copyWith(color: colors.inkPrimary),
          decoration: InputDecoration(
            hintText: 'Search services',
            hintStyle: SublyTypography.body.copyWith(color: colors.inkTertiary),
            prefixIcon: Icon(
              LucideIcons.search,
              size: 20,
              color: colors.inkTertiary,
            ),
            suffixIcon: _query.isNotEmpty
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
              borderRadius: BorderRadius.circular(SublySpace.radiusField),
              borderSide: BorderSide(color: colors.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SublySpace.radiusField),
              borderSide: BorderSide(color: colors.inkSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
