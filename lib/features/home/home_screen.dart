import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_glass_surface.dart';
import '../../core/widgets/sli_svg.dart';
import '../../core/widgets/type_filter_bar.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';
import '../add_item/add_item_sheet.dart';
import '../item_detail/item_detail_screen.dart';
import '../search/search_screen.dart';
import '../../domain/vault_item.dart';

class HomeScreen extends StatefulWidget {
  final VaultController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _backupDismissed = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final items = controller.homeFilteredItems;
    final totalCount = controller.allItems.length;
    final hasTags = controller.tagFrequencies.isNotEmpty;
    final hasDomains = controller.domainFrequencies.isNotEmpty;
    final hasFilters = controller.activeTagFilter != null ||
        controller.activeDomainFilter != null;

    return SliAtmosphere(
      variant: SliAtmosphereVariant.abstractFlow,
      imageAsset: SliAssets.bgHome,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                SliTokens.spaceLg,
                SliTokens.spaceMd,
                SliTokens.spaceLg,
                SliTokens.spaceSm,
              ),
              child: _HomeHeader(totalCount: totalCount),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SliTokens.spaceLg,
                vertical: SliTokens.spaceSm,
              ),
              child: InkWell(
                key: const Key('home_search_bar'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(controller: controller),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(context.sli.cardRadius),
                child: SliGlassSurface(
                  enableBlur: false,
                  borderRadius: BorderRadius.circular(context.sli.cardRadius),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SliTokens.spaceLg,
                  ),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        SliIcon(
                          SliAssets.actionSearch,
                          size: 18,
                          color: context.sli.textSecondary,
                        ),
                        SizedBox(width: SliTokens.spaceMd),
                        Expanded(
                          child: Text(
                            'Search links, images, notes, or tags...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.sli.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: SliTokens.spaceXs),
            TypeFilterBar(
              selected: controller.homeFilter,
              onChanged: controller.setHomeFilter,
              countForFilter: (f) => controller.countByFilter(f),
            ),
            if (hasTags || hasDomains || hasFilters)
              _TagAndDomainRibbon(controller: controller),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SliTokens.spaceLg,
                vertical: 4,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final textScaler = MediaQuery.textScalerOf(context);
                  final isNarrow = constraints.maxWidth < 380 || textScaler.scale(12.5) > 14;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.sli.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Density toggle
                          InkWell(
                            key: const Key('home_density_toggle'),
                            onTap: controller.toggleBrowseDensity,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Icon(
                                controller.browseDensity == 'compact'
                                    ? Icons.view_headline_rounded
                                    : Icons.view_agenda_outlined,
                                size: 18,
                                color: context.sli.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Sort Order Menu
                          PopupMenuButton<VaultSortOption>(
                            key: const Key('home_sort_button'),
                            tooltip: 'Sort Library',
                            initialValue: controller.homeSort,
                            onSelected: controller.setHomeSort,
                            color: context.sli.elevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: context.sli.border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SliIcon(
                                    SliAssets.actionSort,
                                    size: 15,
                                    color: context.sli.primaryAccent,
                                  ),
                                  if (!isNarrow) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      controller.homeSort.label,
                                      style: TextStyle(
                                        color: context.sli.primaryAccent,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            itemBuilder: (context) => VaultSortOption.values
                                .map(
                                  (sort) => PopupMenuItem<VaultSortOption>(
                                    value: sort,
                                    child: Text(
                                      sort.label,
                                      style: TextStyle(
                                        color: controller.homeSort == sort
                                            ? context.sli.primaryAccent
                                            : context.sli.textPrimary,
                                        fontWeight: controller.homeSort == sort
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: SliTokens.spaceXs),
            Expanded(
              child: items.isEmpty
                  ? ListView(
                      padding: EdgeInsets.fromLTRB(
                        SliTokens.spaceLg,
                        SliTokens.spaceSm,
                        SliTokens.spaceLg,
                        96,
                      ),
                      children: [
                        if (controller.isBackupReminderDue && !_backupDismissed) ...[
                          _BackupReminderBanner(
                            controller: controller,
                            onDismiss: () =>
                                setState(() => _backupDismissed = true),
                          ),
                          const SizedBox(height: SliTokens.spaceMd),
                        ],
                        SliEmptyState(
                          illustrationAsset: SliAssets.illEmptyLibrary,
                          title: totalCount == 0
                              ? 'Your vault is empty'
                              : 'No ${controller.homeFilter.label.toLowerCase()} yet',
                          subtitle: totalCount == 0
                              ? 'Save links, offline markdown notes, code snippets, or images. Everything stays stored privately on this device.'
                              : 'Tap Add below to capture a new item in this category.',
                          actionLabel: totalCount == 0
                              ? 'Add First Item'
                              : 'Add Item',
                          onAction: () =>
                              AddItemSheet.show(context, controller: controller),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        SliTokens.spaceLg,
                        SliTokens.spaceSm,
                        SliTokens.spaceLg,
                        96,
                      ),
                      itemCount: items.length +
                          ((controller.isBackupReminderDue && !_backupDismissed)
                              ? 1
                              : 0),
                      separatorBuilder: (_, _) =>
                          SizedBox(height: SliTokens.spaceMd),
                      itemBuilder: (context, index) {
                        final showReminder = controller.isBackupReminderDue &&
                            !_backupDismissed;
                        if (showReminder && index == 0) {
                          return _BackupReminderBanner(
                            controller: controller,
                            onDismiss: () =>
                                setState(() => _backupDismissed = true),
                          );
                        }
                        final itemIndex = showReminder ? index - 1 : index;
                        final item = items[itemIndex];
                        return VaultItemCard(
                          item: item,
                          controller: controller,
                          isCompact: controller.browseDensity == 'compact',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(
                                  itemId: item.id,
                                  controller: controller,
                                ),
                              ),
                            );
                          },
                          onToggleFavorite: () =>
                              controller.toggleFavorite(item.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final int totalCount;

  const _HomeHeader({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final identity = Row(
      children: [
        // Official square brand mark (same asset as launcher master). The
        // artwork is an opaque dark tile, so it gets a hairline ring that
        // keeps its edge crisp on light surfaces as well as dark ones.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: palette.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              SliAssets.symbol,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              semanticLabel: 'SLI Vault',
              errorBuilder: (_, _, _) => SliIllustration(
                SliAssets.brandMark,
                width: 40,
                height: 40,
                semanticLabel: 'SLI Vault',
              ),
            ),
          ),
        ),
        const SizedBox(width: SliTokens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SLI Vault',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Local-first personal library',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
    final badge = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(SliTokens.radiusPill),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliIcon(
              SliAssets.utilPrivacy,
              size: 14,
              color: palette.successText,
            ),
            const SizedBox(width: 6),
            Text(
              '$totalCount saved',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(12) / 12 > 1.3;
    // A restrained header plate (tokenised glass, not a full-width opaque
    // panel) keeps the title/subtitle legible over the background artwork.
    return SliGlassSurface(
      enableBlur: true,
      blurSigma: 6,
      borderRadius: BorderRadius.circular(SliTokens.radiusLg),
      padding: const EdgeInsets.symmetric(
        horizontal: SliTokens.spaceMd,
        vertical: SliTokens.spaceSm + 2,
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                identity,
                const SizedBox(height: SliTokens.spaceSm),
                Align(alignment: Alignment.centerLeft, child: badge),
              ],
            )
          : Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: SliTokens.spaceSm),
                badge,
              ],
            ),
    );
  }
}

class _BackupReminderBanner extends StatefulWidget {
  final VaultController controller;
  final VoidCallback onDismiss;

  const _BackupReminderBanner({
    required this.controller,
    required this.onDismiss,
  });

  @override
  State<_BackupReminderBanner> createState() => _BackupReminderBannerState();
}

class _BackupReminderBannerState extends State<_BackupReminderBanner> {
  bool _isExporting = false;

  Future<void> _exportNow() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final zipBytes = await widget.controller.createBackupArchiveBytes();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'sli-vault-backup-${DateTime.now().millisecondsSinceEpoch}.zip';
      final tempFile = File(p.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(zipBytes, flush: true);

      await widget.controller.recordBackupCompleted();

      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.shareXFiles(
        [XFile(tempFile.path, name: fileName, mimeType: 'application/zip')],
        subject: 'SLI Vault Backup ($fileName)',
        sharePositionOrigin: origin,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup exported & logged ($fileName)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup export failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final days = widget.controller.daysSinceLastBackup;
    final subtitle = days < 0
        ? 'No local backups yet. Export now to keep your offline vault safe.'
        : 'Last local backup was $days days ago. Time for a safety snapshot.';

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context);
        final isNarrow = constraints.maxWidth < 360 || textScaler.scale(12) > 15;

        final actionButtons = _isExporting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: widget.onDismiss,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _exportNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primaryAccent,
                      foregroundColor: Colors.white,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Export', style: TextStyle(fontSize: 12)),
                  ),
                ],
              );

        return Container(
          decoration: BoxDecoration(
            color: palette.elevated.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
            border: Border.all(
              color: palette.primaryAccent.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                palette.primaryAccent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: palette.primaryAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Local Backup Recommended',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: actionButtons,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: palette.primaryAccent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: palette.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Local Backup Recommended',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    actionButtons,
                  ],
                ),
        );
      },
    );
  }
}

class _TagAndDomainRibbon extends StatelessWidget {
  final VaultController controller;

  const _TagAndDomainRibbon({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final topTags = controller.tagFrequencies.entries.take(8).toList();
    final topDomains = controller.domainFrequencies.entries.take(6).toList();
    final activeTag = controller.activeTagFilter;
    final activeDomain = controller.activeDomainFilter;

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
        children: [
          if (activeTag != null || activeDomain != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
              child: InkWell(
                onTap: controller.clearFilters,
                borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: palette.errorText.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                    border: Border.all(
                      color: palette.errorText.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, size: 13, color: palette.errorText),
                      const SizedBox(width: 4),
                      Text(
                        'Clear filter',
                        style: TextStyle(
                          color: palette.errorText,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          ...topTags.map((entry) {
            final isSelected = activeTag == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
              child: InkWell(
                onTap: () => controller.setTagFilter(entry.key),
                borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? palette.primaryAccent.withValues(alpha: 0.2)
                        : palette.elevated,
                    borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? palette.primaryAccent
                          : palette.border,
                    ),
                  ),
                  child: Text(
                    '#${entry.key} (${entry.value})',
                    style: TextStyle(
                      color: isSelected
                          ? palette.primaryAccent
                          : palette.textPrimary,
                      fontSize: 11.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
          ...topDomains.map((entry) {
            final isSelected = activeDomain == entry.key;
            return Padding(
              padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
              child: InkWell(
                onTap: () => controller.setDomainFilter(entry.key),
                borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? palette.primaryAccent.withValues(alpha: 0.2)
                        : palette.elevated,
                    borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? palette.primaryAccent
                          : palette.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language_rounded,
                        size: 12,
                        color: isSelected
                            ? palette.primaryAccent
                            : palette.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.key} (${entry.value})',
                        style: TextStyle(
                          color: isSelected
                              ? palette.primaryAccent
                              : palette.textPrimary,
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
