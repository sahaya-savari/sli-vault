import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_glass_surface.dart';
import '../../core/widgets/sli_screen_header.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/backup_service.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import 'legal_screens.dart';

class SettingsScreen extends StatefulWidget {
  final VaultController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isWorking = false;

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> _exportBackup() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      final zipBytes = await widget.controller.createBackupArchiveBytes();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'sli-vault-backup-${DateTime.now().millisecondsSinceEpoch}.zip';
      final tempFile = File(p.join(tempDir.path, fileName));
      await tempFile.writeAsBytes(zipBytes, flush: true);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliIllustration(
                SliAssets.illExportSuccess,
                width: 120,
                height: 120,
              ),
              SizedBox(height: SliTokens.spaceMd),
              Text(
                'Backup Archive Ready',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: SliTokens.spaceSm),
              Text(
                'Created $fileName (${_formatBytes(zipBytes.length)}) containing ${widget.controller.allItems.length} items, links.csv, and full-resolution images.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Share.shareXFiles([
                  XFile(tempFile.path),
                ], text: 'SLI Vault Backup Archive');
              },
              child: const Text('Share / Save Archive'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _importBackup() async {
    if (_isWorking) return;
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) return;

      setState(() => _isWorking = true);
      final file = picked.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) {
        throw const FormatException('Could not read selected backup archive.');
      }

      final isJson = file.name.toLowerCase().endsWith('.json');
      final ImportPreviewSummary preview = isJson
          ? await widget.controller.backupService.validateKotlinJson(bytes)
          : await widget.controller.backupService.validateBackupArchive(bytes);
      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Backup Restore'),
          content: Text(
            '${preview.sourceFormat == 'kotlin_json' ? 'Kotlin JSON' : 'Flutter ZIP'} format v${preview.formatVersion} validated.\n\n'
            '• Total items in archive: ${preview.totalItemsInArchive}\n'
            '• New items to import: ${preview.newItemsToImport}\n'
            '• Duplicate IDs skipped: ${preview.duplicateItemsSkipped}\n'
            '• Image files verified: ${preview.imageFilesRestored}\n\n'
            'Existing items in your vault will be preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Import Items'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await widget.controller.commitImportPreview(preview);
        await widget.controller.reloadLibrary();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${preview.newItemsToImport} new items (${preview.duplicateItemsSkipped} duplicates skipped).',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliIllustration(
                SliAssets.illImportFailure,
                width: 120,
                height: 120,
              ),
              SizedBox(height: SliTokens.spaceMd),
              Text(
                'Import Validation Failed',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: SliTokens.spaceSm),
              Text(
                '${e.toString().replaceFirst('FormatException: ', '')}\n\nYour existing library was not modified.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _confirmClearAll() async {
    if (_isWorking) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final palette = context.sli;
        return AlertDialog(
          scrollable: true,
          title: const Text('Clear Entire Vault?'),
          content: const Text(
            'This permanently deletes all saved links and images, their tags, and any custom collections from this device. Without an exported backup ZIP, this cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.destructive,
                foregroundColor: palette.onDestructive,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete Everything'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _isWorking = true);
      try {
        await widget.controller.clearAllVaultData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local vault data cleared.')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not clear vault: $e')));
      } finally {
        if (mounted) setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _vacuumDb() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      await widget.controller.vacuumDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database defragmented & optimized.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database optimization error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _cleanTempCache() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      final freed = await widget.controller.clearTemporaryCache();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned temporary cache (${_formatBytes(freed)} freed).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cache clean failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _runIntegrityCheck() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      final report = await widget.controller.checkIntegrity();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                report.isHealthy
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: report.isHealthy
                    ? context.sli.successText
                    : context.sli.accentText,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Vault Integrity Report')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Total items in database: ${report.totalDatabaseItems}'),
              const SizedBox(height: 4),
              Text('• Valid images on disk: ${report.validImageFiles}'),
              const SizedBox(height: 4),
              Text(
                '• Missing image files: ${report.missingImageFiles}',
                style: TextStyle(
                  color: report.missingImageFiles > 0
                      ? context.sli.errorText
                      : context.sli.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Orphaned image files: ${report.orphanedImageFiles}',
                style: TextStyle(
                  color: report.orphanedImageFiles > 0
                      ? context.sli.amberText
                      : context.sli.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                report.isHealthy
                    ? 'Your vault storage is healthy and properly synchronized.'
                    : 'Some files require attention or cleanup.',
                style: TextStyle(color: context.sli.textSecondary, fontSize: 13),
              ),
            ],
          ),
          actions: [
            if (report.orphanedImageFiles > 0)
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(this.context);
                  Navigator.of(context).pop();
                  final cleaned = await widget.controller.cleanOrphanedImages();
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Cleaned $cleaned orphaned image files.'),
                      ),
                    );
                  }
                },
                child: const Text('Clean Orphaned Files'),
              ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Integrity check failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.controller.allItems.length;
    final links = widget.controller.countByFilter(VaultTypeFilter.links);
    final images = widget.controller.countByFilter(VaultTypeFilter.images);
    final palette = context.sli;

    return SliAtmosphere(
      variant: SliAtmosphereVariant.abstractFlow,
      imageAsset: SliAssets.bgSettings,
      child: SafeArea(
        child: ListView(
          key: const ValueKey('settings-scroll'),
          padding: EdgeInsets.fromLTRB(
            SliTokens.spaceLg,
            SliTokens.spaceMd,
            SliTokens.spaceLg,
            96,
          ),
          children: [
            const SliScreenHeader(
              margin: EdgeInsets.only(bottom: SliTokens.spaceMd),
              title: 'Settings',
            ),
            _SectionCard(
              title: 'Local Storage & Backup',
              iconAsset: SliAssets.utilStorage,
              children: [
                Text(
                  '$total total ${total == 1 ? 'item' : 'items'} ($links ${links == 1 ? 'link' : 'links'} • $images ${images == 1 ? 'image' : 'images'})',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Approximate local storage used: ${_formatBytes(widget.controller.approxStorageBytes)}',
                  style: SliTheme.mono(context, fontSize: 12.5),
                ),
                const SizedBox(height: SliTokens.spaceSm),
                Text(
                  'Backups produce a portable ZIP containing manifest.json, links.csv, and full-resolution image binaries for offline preservation.',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                _ActionPair(
                  primary: SliGradientButton(
                    label: 'Export Backup',
                    iconAsset: SliAssets.utilExport,
                    isLoading: _isWorking,
                    onPressed: _exportBackup,
                  ),
                  secondary: OutlinedButton.icon(
                    onPressed: _isWorking ? null : _importBackup,
                    icon: SliIcon(
                      SliAssets.utilImport,
                      size: 18,
                      color: _isWorking
                          ? palette.textSecondary
                          : palette.textPrimary,
                    ),
                    label: const _ButtonLabel('Import Backup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'Appearance',
              iconAsset: SliAssets.utilTheme,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    color: context.sli.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose the appearance used by SLI Vault.',
                  style: TextStyle(
                    color: context.sli.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceSm),
                _ThemeChoiceRow(controller: widget.controller),
              ],
            ),
            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'Privacy & Security',
              iconAsset: SliAssets.utilPrivacy,
              children: [
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    key: const ValueKey('lock-vault-switch'),
                    contentPadding: EdgeInsets.zero,
                    value: widget.controller.lockEnabled,
                    onChanged: widget.controller.setLockEnabled,
                    title: Text(
                      'Lock vault when backgrounded',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Uses biometrics or device credentials. Biometric lock guards app access; SQLite database on disk is not hardware-encrypted.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                if (widget.controller.lockEnabled) ...[
                  const SizedBox(height: SliTokens.spaceSm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Lock timeout',
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: SliTokens.spaceSm),
                      DropdownButton<int>(
                        value: widget.controller.lockTimeoutSeconds,
                        dropdownColor: palette.elevated,
                        underline: const SizedBox.shrink(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: palette.textSecondary,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text('Immediately'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('After 1 minute'),
                          ),
                          DropdownMenuItem(
                            value: 300,
                            child: Text('After 5 minutes'),
                          ),
                          DropdownMenuItem(
                            value: 900,
                            child: Text('After 15 minutes'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            widget.controller.setLockTimeoutSeconds(val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: SliTokens.spaceSm),
                  OutlinedButton.icon(
                    onPressed: () => widget.controller.lockVault(),
                    icon: const Icon(Icons.lock_clock, size: 16),
                    label: const _ButtonLabel('Lock Vault Now'),
                  ),
                ],
                const SizedBox(height: SliTokens.spaceSm),
                Text(
                  '• 100% Local-First: Saved links, tags, and imported images are stored in app-private storage on this device.\n'
                  '• Zero Telemetry: No accounts, cloud sync, analytics, or advertising SDKs.\n'
                  '• Screen Protection: FLAG_SECURE is active to guard app previews and prevent accidental screen capture.',
                  style: TextStyle(
                    color: context.sli.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'Accent Palette & Atmosphere',
              iconAsset: SliAssets.utilTheme,
              children: [
                Text(
                  'Accent Palette Highlight',
                  style: TextStyle(
                    color: context.sli.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a WCAG AA/AAA-verified brand color tone.',
                  style: TextStyle(
                    color: context.sli.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceSm),
                _AccentChoiceRow(controller: widget.controller),
                const SizedBox(height: SliTokens.spaceMd),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: widget.controller.atmosphereEnabled,
                    onChanged: widget.controller.setAtmosphereEnabled,
                    title: Text(
                      'Atmospheric backgrounds',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Displays background art and soft ambient radial glows across app surfaces.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: widget.controller.reduceMotion,
                    onChanged: widget.controller.setReduceMotion,
                    title: Text(
                      'Reduce motion & animations',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Disables shimmer sheens and reduces animated transitions for a calmer experience.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'Library & Behavior Preferences',
              iconAsset: SliAssets.navBrowse,
              children: [
                Text(
                  'Default Startup Tab',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceSm),
                Wrap(
                  spacing: SliTokens.spaceSm,
                  runSpacing: SliTokens.spaceSm,
                  children: [
                    for (final tab in const [
                      (0, 'Home'),
                      (1, 'Browse'),
                      (2, 'Favorites'),
                      (3, 'Collections'),
                    ])
                      ChoiceChip(
                        key: ValueKey('startup-tab-${tab.$1}'),
                        label: Text(tab.$2),
                        selected:
                            widget.controller.defaultStartupTab == tab.$1,
                        showCheckmark: false,
                        onSelected: (_) =>
                            widget.controller.setDefaultStartupTab(tab.$1),
                      ),
                  ],
                ),
                const SizedBox(height: SliTokens.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Default Browse Sort',
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                    DropdownButton<VaultSortOption>(
                      value: widget.controller.defaultBrowseSort,
                      dropdownColor: palette.elevated,
                      underline: const SizedBox.shrink(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: palette.textSecondary,
                      ),
                      items: VaultSortOption.values.map((sort) {
                        return DropdownMenuItem<VaultSortOption>(
                          value: sort,
                          child: Text(sort.label),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          widget.controller.setDefaultBrowseSort(val);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: SliTokens.spaceSm),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: widget.controller.inAppBrowser,
                    onChanged: widget.controller.setInAppBrowser,
                    title: Text(
                      'Open links in in-app browser',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Uses Chrome Custom Tabs instead of switching out of the app.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: widget.controller.hapticsEnabled,
                    onChanged: widget.controller.setHapticsEnabled,
                    title: Text(
                      'Tactile haptic feedback',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Delivers subtle tactile clicks when tapping tabs and actions.',
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'Storage Optimization & Diagnostics',
              iconAsset: SliAssets.utilStorage,
              children: [
                Text(
                  'Approximate local storage used: ${_formatBytes(widget.controller.approxStorageBytes)}',
                  style: SliTheme.mono(context, fontSize: 12.5),
                ),
                const SizedBox(height: 8),
                _StorageBar(
                  approxBytes: widget.controller.approxStorageBytes,
                ),
                const SizedBox(height: SliTokens.spaceSm),
                Text(
                  'Optimize database pages, clean temporary cached files, or verify SQLite table integrity.',
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceSm),
                Wrap(
                  spacing: SliTokens.spaceSm,
                  runSpacing: SliTokens.spaceSm,
                  children: [
                    OutlinedButton.icon(
                      key: const ValueKey('vacuum-db-button'),
                      onPressed: _isWorking ? null : _vacuumDb,
                      icon: const Icon(Icons.speed, size: 16),
                      label: const Text('Vacuum DB'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('clean-cache-button'),
                      onPressed: _isWorking ? null : _cleanTempCache,
                      icon: const Icon(
                        Icons.cleaning_services_outlined,
                        size: 16,
                      ),
                      label: const Text('Clean Cache'),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('check-integrity-button'),
                      onPressed: _isWorking ? null : _runIntegrityCheck,
                      icon: const Icon(
                        Icons.health_and_safety_outlined,
                        size: 16,
                      ),
                      label: const Text('Check Integrity'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'Library & Data',
              iconAsset: SliAssets.contentCollection,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.controller.reopenOnboarding,
                  icon: SliIcon(
                    SliAssets.utilInfo,
                    size: 16,
                    color: palette.textPrimary,
                  ),
                  label: const _ButtonLabel('View Welcome Guide Again'),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                Divider(color: palette.border),
                const SizedBox(height: SliTokens.spaceSm),
                Text(
                  'Clearing your vault removes all database records and stored image files from this device.',
                  style: TextStyle(
                    color: context.sli.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                OutlinedButton.icon(
                  key: const ValueKey('clear-all-button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.errorText,
                    side: BorderSide(
                      color: total == 0 ? palette.border : palette.errorText,
                    ),
                    backgroundColor: palette.errorText.withValues(alpha: 0.08),
                  ),
                  onPressed: total == 0 || _isWorking ? null : _confirmClearAll,
                  icon: SliIcon(
                    SliAssets.actionDelete,
                    size: 18,
                    color: total == 0
                        ? palette.textSecondary
                        : palette.errorText,
                  ),
                  label: const _ButtonLabel('Clear All Vault Data'),
                ),
              ],
            ),
            const SizedBox(height: SliTokens.spaceMd),
            _SectionCard(
              title: 'About SLI Vault',
              iconAsset: SliAssets.utilInfo,
              children: [
                Text(
                  'SLI Vault v1.0.2 (Flutter + Dart Canonical Build)',
                  style: SliTheme.mono(
                    context,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: context.sli.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save links and images',
                  style: TextStyle(color: palette.amberText, fontSize: 13),
                ),
                const SizedBox(height: SliTokens.spaceMd),
                for (final destination in [
                  (
                    'About',
                    'App details and open-source licenses',
                    const AboutSliVaultScreen(),
                  ),
                  (
                    'Privacy Policy',
                    'How SLI Vault stores and handles your data',
                    const PrivacyPolicyScreen(),
                  ),
                  (
                    'Terms of Use',
                    'Local storage, backups, and your content',
                    const TermsScreen(),
                  ),
                ])
                  Material(
                    key: ValueKey(destination.$1),
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(destination.$1),
                      subtitle: Text(destination.$2),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => destination.$3)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  final int approxBytes;

  const _StorageBar({required this.approxBytes});

  @override
  Widget build(BuildContext context) {
    const targetMax = 500 * 1024 * 1024; // 500 MB ceiling
    final progress = (approxBytes / targetMax).clamp(0.02, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(SliTokens.radiusPill),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: context.sli.border.withValues(alpha: 0.5),
        color: context.sli.primaryAccent,
      ),
    );
  }
}

class _AccentChoiceRow extends StatelessWidget {
  final VaultController controller;

  const _AccentChoiceRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final active = controller.accentPreset;
    return Wrap(
      spacing: SliTokens.spaceSm,
      runSpacing: SliTokens.spaceSm,
      children: [
        for (final preset in SliAccentPreset.presets)
          InkWell(
            key: ValueKey('accent-chip-${preset.key}'),
            onTap: () {
              if (controller.hapticsEnabled) {
                HapticFeedback.selectionClick();
              }
              controller.setAccentPreset(preset.key);
            },
            borderRadius: BorderRadius.circular(SliTokens.radiusPill),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: active == preset.key
                    ? preset.primary.withValues(alpha: 0.16)
                    : context.sli.elevated,
                borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                border: Border.all(
                  color: active == preset.key
                      ? preset.primary
                      : context.sli.border,
                  width: active == preset.key ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: preset.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      preset.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: SliTokens.fontFamily,
                        fontSize: 12,
                        fontWeight: active == preset.key
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: active == preset.key
                            ? context.sli.textPrimary
                            : context.sli.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ThemeChoiceRow extends StatelessWidget {
  final VaultController controller;

  const _ThemeChoiceRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    return Wrap(
      spacing: SliTokens.spaceSm,
      runSpacing: SliTokens.spaceSm,
      children: [
        for (final mode in const [
          ('dark', 'Dark'),
          ('amoled', 'OLED Black'),
          ('light', 'Light'),
          ('system', 'System'),
        ])
          ChoiceChip(
            key: ValueKey('theme-chip-${mode.$1}'),
            label: Text(mode.$2),
            selected: controller.themeModeName == mode.$1,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontFamily: SliTokens.fontFamily,
              fontWeight: FontWeight.w700,
              color: controller.themeModeName == mode.$1
                  ? palette.onAccent
                  : palette.textPrimary,
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
            visualDensity: VisualDensity.standard,
            onSelected: (_) => controller.setThemeModeName(mode.$1),
          ),
      ],
    );
  }
}

/// Lays out two buttons side-by-side, or stacked (full width) when the card is
/// narrow or the text scale is large, so labels are never shrunk or clipped.
class _ActionPair extends StatelessWidget {
  final Widget primary;
  final Widget secondary;

  const _ActionPair({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(15) > 18;
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primary,
              const SizedBox(height: SliTokens.spaceSm),
              secondary,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: primary),
            const SizedBox(width: SliTokens.spaceSm),
            Expanded(child: secondary),
          ],
        );
      },
    );
  }
}

/// Button label that wraps onto a second line instead of overflowing.
class _ButtonLabel extends StatelessWidget {
  final String text;

  const _ButtonLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.center, softWrap: true);
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String iconAsset;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.iconAsset,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SliGlassSurface(
      enableBlur: true,
      blurSigma: 12,
      borderRadius: BorderRadius.circular(SliTokens.radiusLg),
      padding: const EdgeInsets.all(SliTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SliIcon(iconAsset, size: 18, color: context.sli.accentText),
              SizedBox(width: SliTokens.spaceSm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: SliTokens.spaceMd),
          ...children,
        ],
      ),
    );
  }
}
