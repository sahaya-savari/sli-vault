import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
                const SizedBox(height: SliTokens.spaceSm),
                Text(
                  '• 100% Local-First: Saved links, tags, and imported images are stored in app-private storage on this device.\n'
                  '• Zero Telemetry: No accounts, cloud sync, analytics, or advertising SDKs.\n'
                  '• Security Notice: Keep your phone lock screen protected and store backup archives securely.',
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
