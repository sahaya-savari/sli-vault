import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cache clean failed: $e')));
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
                style: TextStyle(
                  color: context.sli.textSecondary,
                  fontSize: 13,
                ),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Integrity check failed: $e')));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _shareApp() async {
    await Share.share(
      'SLI Vault — A privacy-first, local-first personal vault for links, screenshots, and visual inspiration.\nhttps://sahaya-savari.github.io/sli-vault/',
      subject: 'SLI Vault — Local-First Personal Vault',
    );
  }

  Future<void> _rateApp() async {
    final uri = Uri.parse('https://github.com/sahaya-savari/sli-vault');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open browser. Star at: https://github.com/sahaya-savari/sli-vault',
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendFeedback() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedbackSheet(controller: widget.controller),
    );
  }

  Future<void> _contactDeveloper() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'sahayasavari@gmail.com',
      query: 'subject=SLI Vault Support & Feedback',
    );
    try {
      if (!await launchUrl(emailUri)) {
        await launchUrl(
          Uri.parse('https://github.com/sahaya-savari/sli-vault/issues'),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      await Clipboard.setData(
        const ClipboardData(text: 'sahayasavari@gmail.com'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Contact email copied to clipboard: sahayasavari@gmail.com',
            ),
          ),
        );
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
            _buildStorageSection(context, palette, total, links, images),
            const SizedBox(height: SliTokens.spaceMd),
            _buildAppearanceSection(context, palette),
            const SizedBox(height: SliTokens.spaceMd),
            _buildPrivacySection(context, palette),
            const SizedBox(height: SliTokens.spaceMd),
            _buildBrowsingSection(context, palette),
            const SizedBox(height: SliTokens.spaceMd),
            _buildInteractionSection(context, palette),
            const SizedBox(height: SliTokens.spaceMd),
            _buildMaintenanceSection(context, palette, total),
            const SizedBox(height: SliTokens.spaceMd),
            _buildCommunitySection(context, palette),
            const SizedBox(height: SliTokens.spaceMd),
            _buildAboutSection(context, palette),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(
    BuildContext context,
    SliPalette palette,
    int total,
    int links,
    int images,
  ) {
    return _SectionCard(
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
        const SizedBox(height: 8),
        _StorageBar(approxBytes: widget.controller.approxStorageBytes),
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
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SliPalette palette) {
    return _SectionCard(
      title: 'Appearance',
      iconAsset: SliAssets.utilTheme,
      children: [
        Text(
          'Theme',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose the appearance used by SLI Vault.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: SliTokens.spaceSm),
        _ThemeChoiceRow(controller: widget.controller),
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceSm),
        Text(
          'Interface Style',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose between balanced Classic, compact Minimal, and curved Express design.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: SliTokens.spaceSm),
        _StyleChoiceRow(controller: widget.controller),
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceSm),
        Text(
          'Accent Palette Highlight',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a WCAG AA/AAA-verified brand color tone.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: SliTokens.spaceSm),
        _AccentChoiceRow(controller: widget.controller),
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceXs),
        _DualModeSwitchCard(
          icon: const Icon(Icons.blur_on_rounded, size: 20),
          title: 'Atmospheric backgrounds',
          subtitle:
              'Displays background art and soft ambient radial glows across app surfaces.',
          value: widget.controller.atmosphereEnabled,
          onChanged: widget.controller.setAtmosphereEnabled,
        ),
        _DualModeSwitchCard(
          icon: const Icon(Icons.motion_photos_off_outlined, size: 20),
          title: 'Reduce motion & animations',
          subtitle:
              'Disables shimmer sheens and reduces animated transitions for a calmer experience.',
          value: widget.controller.reduceMotion,
          onChanged: widget.controller.setReduceMotion,
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, SliPalette palette) {
    return _SectionCard(
      title: 'Privacy & Security',
      iconAsset: SliAssets.utilPrivacy,
      children: [
        _DualModeSwitchCard(
          switchKey: const ValueKey('lock-vault-switch'),
          icon: const Icon(Icons.lock_outline_rounded, size: 20),
          title: 'Lock vault when backgrounded',
          subtitle:
              'Uses biometrics or device credentials. Biometric lock guards app access; SQLite database on disk is not hardware-encrypted.',
          value: widget.controller.lockEnabled,
          onChanged: widget.controller.setLockEnabled,
        ),
        if (widget.controller.lockEnabled) ...[
          const SizedBox(height: SliTokens.spaceSm),
          Text(
            'Lock timeout',
            style: TextStyle(
              color: palette.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: SliTokens.spaceXs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: palette.elevated,
              borderRadius: BorderRadius.circular(
                SliTokens.radiusSm,
              ),
              border: Border.all(color: palette.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: widget.controller.lockTimeoutSeconds,
                dropdownColor: palette.elevated,
                isExpanded: true,
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
            ),
          ),
          const SizedBox(height: SliTokens.spaceSm),
          OutlinedButton.icon(
            onPressed: () => widget.controller.lockVault(),
            icon: const Icon(Icons.lock_clock, size: 16),
            label: const _ButtonLabel('Lock Vault Now'),
          ),
        ],
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceXs),
        _DualModeSwitchCard(
          switchKey: const ValueKey('screen-protection-switch'),
          icon: const Icon(Icons.shield_outlined, size: 20),
          title: 'Screen protection (FLAG_SECURE)',
          subtitle:
              'Blocks screenshots and masks app content in recent apps preview. Can be temporarily disabled for QA feedback.',
          value: widget.controller.screenProtectionEnabled,
          onChanged: widget.controller.setScreenProtectionEnabled,
        ),
        const SizedBox(height: SliTokens.spaceSm),
        Text(
          '• 100% Local-First: Saved links, tags, and imported images are stored in app-private storage on this device.\n'
          '• Zero Telemetry: No accounts, cloud sync, analytics, or advertising SDKs.\n'
          '• Direct Metadata: Link metadata previews connect directly to target sites without intermediate servers.',
          style: TextStyle(
            color: context.sli.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildBrowsingSection(BuildContext context, SliPalette palette) {
    return _SectionCard(
      title: 'Browsing',
      iconAsset: SliAssets.navBrowse,
      children: [
        Text(
          'Thumbnail Density',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose between spacious media previews or a denser layout.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: SliTokens.spaceSm),
        Wrap(
          spacing: SliTokens.spaceSm,
          runSpacing: SliTokens.spaceSm,
          children: [
            ChoiceChip(
              avatar: const Icon(Icons.view_agenda_outlined, size: 16),
              label: const Text('Comfortable'),
              selected:
                  widget.controller.browseDensity == 'comfortable',
              showCheckmark: false,
              onSelected: (_) =>
                  widget.controller.setBrowseDensity('comfortable'),
            ),
            ChoiceChip(
              avatar: const Icon(Icons.density_small_outlined, size: 16),
              label: const Text('Compact'),
              selected: widget.controller.browseDensity == 'compact',
              showCheckmark: false,
              onSelected: (_) =>
                  widget.controller.setBrowseDensity('compact'),
            ),
          ],
        ),
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceSm),
        Text(
          'Default Browse Sort',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Order applied when loading Browse',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: SliTokens.spaceSm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: palette.elevated,
            borderRadius: BorderRadius.circular(SliTokens.radiusSm),
            border: Border.all(color: palette.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VaultSortOption>(
              value: widget.controller.defaultBrowseSort,
              dropdownColor: palette.elevated,
              isExpanded: true,
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
          ),
        ),
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceSm),
        Text(
          'Default Startup Tab',
          style: TextStyle(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Initial tab selected when SLI Vault opens.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
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
                selected: widget.controller.defaultStartupTab == tab.$1,
                showCheckmark: false,
                onSelected: (_) =>
                    widget.controller.setDefaultStartupTab(tab.$1),
              ),
          ],
        ),
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceXs),
        _DualModeSwitchCard(
          switchKey: const ValueKey('auto-fetch-metadata-switch'),
          icon: const Icon(Icons.auto_awesome_outlined, size: 20),
          title: 'Automatic link previews',
          subtitle:
              'Directly requests page title, description, and icon from target websites with zero intermediary servers.',
          value: widget.controller.autoFetchMetadata,
          onChanged: widget.controller.setAutoFetchMetadata,
        ),
      ],
    );
  }

  Widget _buildInteractionSection(BuildContext context, SliPalette palette) {
    return _SectionCard(
      title: 'Interaction',
      iconAsset: SliAssets.navHome,
      children: [
        _DualModeSwitchCard(
          icon: const Icon(Icons.open_in_browser_rounded, size: 20),
          title: 'Open links in in-app browser',
          subtitle:
              'Uses Chrome Custom Tabs instead of switching out of the app.',
          value: widget.controller.inAppBrowser,
          onChanged: widget.controller.setInAppBrowser,
        ),
        _DualModeSwitchCard(
          icon: const Icon(Icons.vibration_rounded, size: 20),
          title: 'Tactile haptic feedback',
          subtitle:
              'Delivers subtle tactile clicks when tapping tabs and actions.',
          value: widget.controller.hapticsEnabled,
          onChanged: widget.controller.setHapticsEnabled,
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection(
    BuildContext context,
    SliPalette palette,
    int total,
  ) {
    return _SectionCard(
      title: 'Maintenance',
      iconAsset: SliAssets.utilStorage,
      children: [
        Text(
          'Optimize database pages, clean temporary cache files, or verify SQLite table integrity.',
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
        const SizedBox(height: SliTokens.spaceMd),
        Divider(color: palette.border),
        const SizedBox(height: SliTokens.spaceSm),
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
        const SizedBox(height: SliTokens.spaceSm),
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
    );
  }

  Widget _buildCommunitySection(BuildContext context, SliPalette palette) {
    return _SectionCard(
      title: 'Community & Support',
      iconAsset: SliAssets.navFavorites,
      children: [
        Text(
          'Share SLI Vault, report suggestions, or star the project on GitHub.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: SliTokens.spaceSm),
        _DualModeActionTile(
          icon: const Icon(
            Icons.star_outline_rounded,
            size: 20,
            color: Color(0xFFF59E0B),
          ),
          title: 'Rate App / Star on GitHub',
          subtitle: 'Support open-source development with a GitHub star',
          onTap: _rateApp,
        ),
        _DualModeActionTile(
          icon: const Icon(
            Icons.share_outlined,
            size: 20,
            color: Color(0xFF3B82F6),
          ),
          title: 'Share App',
          subtitle: 'Share SLI Vault with friends and collaborators',
          onTap: _shareApp,
        ),
        _DualModeActionTile(
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 20,
            color: Color(0xFF10B981),
          ),
          title: 'Send Feedback',
          subtitle: 'Submit feature requests, ideas, or bug reports',
          onTap: _sendFeedback,
        ),
        _DualModeActionTile(
          icon: const Icon(
            Icons.mail_outline_rounded,
            size: 20,
            color: Color(0xFF8B5CF6),
          ),
          title: 'Contact Developer',
          subtitle: 'Direct email support: sahayasavari@gmail.com',
          onTap: _contactDeveloper,
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, SliPalette palette) {
    return _SectionCard(
      title: 'About SLI Vault',
      iconAsset: SliAssets.utilInfo,
      children: [
        Text(
          'SLI Vault v1.0.3 (Production Build • Code 2007)',
          style: SliTheme.mono(
            context,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: context.sli.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Save links and images locally with total privacy',
          style: TextStyle(color: palette.amberText, fontSize: 13),
        ),
        const SizedBox(height: SliTokens.spaceMd),
        _DualModeActionTile(
          tileKey: const ValueKey('About'),
          icon: const Icon(Icons.info_outline_rounded, size: 20),
          title: 'About',
          subtitle: 'App details and open-source licenses',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AboutSliVaultScreen(),
            ),
          ),
        ),
        _DualModeActionTile(
          tileKey: const ValueKey('Privacy Policy'),
          icon: const Icon(Icons.privacy_tip_outlined, size: 20),
          title: 'Privacy Policy',
          subtitle: 'How SLI Vault stores and handles your data',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PrivacyPolicyScreen(),
            ),
          ),
        ),
        _DualModeActionTile(
          tileKey: const ValueKey('Terms of Use'),
          icon: const Icon(Icons.description_outlined, size: 20),
          title: 'Terms of Use',
          subtitle: 'Local storage, backups, and your content',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TermsScreen(),
            ),
          ),
        ),
      ],
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
          ('dark', 'Dark', Icons.dark_mode_outlined),
          ('amoled', 'OLED Black', Icons.brightness_2_outlined),
          ('light', 'Light', Icons.light_mode_outlined),
          ('system', 'System', Icons.settings_brightness_outlined),
        ])
          ChoiceChip(
            key: ValueKey('theme-chip-${mode.$1}'),
            avatar: Icon(
              mode.$3,
              size: 15,
              color: controller.themeModeName == mode.$1
                  ? palette.onAccent
                  : palette.textSecondary,
            ),
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

class _StyleChoiceRow extends StatelessWidget {
  final VaultController controller;

  const _StyleChoiceRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final currentStyle = controller.visualStyle;

    final styles = [
      (
        SliVisualStyle.classic,
        'Classic',
        'Balanced',
        14.0,
        10.0,
      ),
      (
        SliVisualStyle.minimal,
        'Minimal',
        'Compact',
        6.0,
        4.0,
      ),
      (
        SliVisualStyle.express,
        'Express',
        'Organic',
        22.0,
        14.0,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;
        final itemWidth = isNarrow
            ? constraints.maxWidth
            : (constraints.maxWidth - (SliTokens.spaceSm * 2)) / 3;

        return Wrap(
          spacing: SliTokens.spaceSm,
          runSpacing: SliTokens.spaceSm,
          children: styles.map((entry) {
            final style = entry.$1;
            final title = entry.$2;
            final subtitle = entry.$3;
            final previewRadius = entry.$4;
            final previewThumbRadius = entry.$5;
            final isSelected = currentStyle == style;

            return SizedBox(
              width: itemWidth,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('style-card-${style.name}'),
                  onTap: () => controller.setVisualStyle(style),
                  borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? palette.primaryAccent.withValues(alpha: 0.12)
                          : palette.elevated,
                      borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? palette.primaryAccent
                            : palette.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: isNarrow
                        ? Row(
                            children: [
                              Container(
                                width: 56,
                                height: 40,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: palette.surfaceFill,
                                  borderRadius:
                                      BorderRadius.circular(previewRadius),
                                  border: Border.all(
                                    color: isSelected
                                        ? palette.primaryAccent
                                            .withValues(alpha: 0.4)
                                        : palette.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: palette.charcoal,
                                        borderRadius: BorderRadius.circular(
                                            previewThumbRadius),
                                        border:
                                            Border.all(color: palette.border),
                                      ),
                                      child: Icon(
                                        Icons.bookmark_border,
                                        size: 13,
                                        color: isSelected
                                            ? palette.primaryAccent
                                            : palette.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? palette.primaryAccent
                                                  .withValues(alpha: 0.8)
                                              : palette.textPrimary
                                                  .withValues(alpha: 0.6),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        fontFamily: SliTokens.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        color: isSelected
                                            ? palette.primaryAccent
                                            : palette.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: palette.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: palette.primaryAccent,
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 48,
                                width: double.infinity,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: palette.surfaceFill,
                                  borderRadius:
                                      BorderRadius.circular(previewRadius),
                                  border: Border.all(
                                    color: isSelected
                                        ? palette.primaryAccent
                                            .withValues(alpha: 0.4)
                                        : palette.border,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: palette.charcoal,
                                        borderRadius: BorderRadius.circular(
                                            previewThumbRadius),
                                        border:
                                            Border.all(color: palette.border),
                                      ),
                                      child: Icon(
                                        Icons.bookmark_border,
                                        size: 14,
                                        color: isSelected
                                            ? palette.primaryAccent
                                            : palette.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 4.5,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? palette.primaryAccent
                                                      .withValues(alpha: 0.8)
                                                  : palette.textPrimary
                                                      .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(2.5),
                                            ),
                                          ),
                                          const SizedBox(height: 3.5),
                                          Container(
                                            height: 3,
                                            width: 22,
                                            decoration: BoxDecoration(
                                              color: palette.textSecondary
                                                  .withValues(alpha: 0.4),
                                              borderRadius:
                                                  BorderRadius.circular(1.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: SliTokens.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: isSelected
                                            ? palette.primaryAccent
                                            : palette.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 3),
                                    Icon(
                                      Icons.check_circle,
                                      size: 13,
                                      color: palette.primaryAccent,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: palette.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
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
      borderRadius: BorderRadius.circular(context.sli.cardRadius),
      padding: const EdgeInsets.all(SliTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SliIcon(iconAsset, size: 18, color: context.sli.accentText),
              const SizedBox(width: SliTokens.spaceSm),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: SliTokens.spaceMd),
          ...children,
        ],
      ),
    );
  }
}

/// A sleek pill-shaped action tile inspired by modern dual-mode settings design.
class _DualModeActionTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Key? tileKey;

  const _DualModeActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.tileKey,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Material(
        color: isDark
            ? palette.elevated.withValues(alpha: 0.55)
            : palette.charcoal.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(context.sli.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: tileKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.sli.cardRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.sli.cardRadius),
              border: Border.all(
                color: palette.border.withValues(alpha: isDark ? 0.35 : 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? palette.obsidian.withValues(alpha: 0.8)
                        : palette.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: palette.border.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: palette.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A sleek pill-shaped switch tile with custom leading icon box and SwitchListTile compatibility.
class _DualModeSwitchCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Key? switchKey;

  const _DualModeSwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.switchKey,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isDark
            ? palette.elevated.withValues(alpha: 0.55)
            : palette.charcoal.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(context.sli.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.sli.cardRadius),
            border: Border.all(
              color: palette.border.withValues(alpha: isDark ? 0.35 : 0.5),
            ),
          ),
          child: SwitchListTile(
            key: switchKey,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            secondary: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? palette.obsidian.withValues(alpha: 0.8)
                    : palette.elevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: palette.border.withValues(alpha: 0.3),
                ),
              ),
              alignment: Alignment.center,
              child: icon,
            ),
            value: value,
            onChanged: onChanged,
            activeThumbColor: palette.primaryAccent,
            title: Text(
              title,
              style: TextStyle(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet dialog providing actionable feedback avenues and diagnostic export.
class _FeedbackSheet extends StatelessWidget {
  final VaultController controller;

  const _FeedbackSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Feedback & Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Help improve SLI Vault or report issues directly to the developers.',
              style: TextStyle(color: palette.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _DualModeActionTile(
              icon: const Icon(
                Icons.bug_report_outlined,
                size: 20,
                color: Color(0xFFEF4444),
              ),
              title: 'Open GitHub Issue',
              subtitle: 'Report a defect or request new functionality on GitHub',
              onTap: () async {
                Navigator.of(context).pop();
                final uri = Uri.parse(
                  'https://github.com/sahaya-savari/sli-vault/issues',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            _DualModeActionTile(
              icon: const Icon(
                Icons.mail_outline,
                size: 20,
                color: Color(0xFF3B82F6),
              ),
              title: 'Email Developer',
              subtitle: 'Send feedback directly to sahayasavari@gmail.com',
              onTap: () async {
                Navigator.of(context).pop();
                final uri = Uri(
                  scheme: 'mailto',
                  path: 'sahayasavari@gmail.com',
                  query: 'subject=SLI Vault Feedback',
                );
                try {
                  await launchUrl(uri);
                } catch (_) {
                  await Clipboard.setData(
                    const ClipboardData(text: 'sahayasavari@gmail.com'),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email copied: sahayasavari@gmail.com'),
                      ),
                    );
                  }
                }
              },
            ),
            _DualModeActionTile(
              icon: const Icon(
                Icons.copy_rounded,
                size: 20,
                color: Color(0xFF10B981),
              ),
              title: 'Copy Diagnostic Info',
              subtitle:
                  'Copies app version, item counts, and device details for reporting',
              onTap: () async {
                Navigator.of(context).pop();
                final info = 'SLI Vault v1.0.3 (Build 2007)\n'
                    'Items: ${controller.allItems.length}\n'
                    'Storage: ${(controller.approxStorageBytes / 1024).toStringAsFixed(1)} KB\n'
                    'Theme: ${controller.themeModeName} (${controller.visualStyle.name})\n'
                    'Platform: Android';
                await Clipboard.setData(ClipboardData(text: info));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Diagnostic info copied to clipboard!'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

