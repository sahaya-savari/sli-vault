import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/platform/document_path.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/backup_service.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import '../../core/constants/sli_version.dart';
import 'legal_screens.dart';

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

class SettingsScreen extends StatefulWidget {
  final VaultController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void _pushPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final palette = context.sli;
        final appStyleLabel = switch (controller.visualStyle) {
          SliVisualStyle.classic => 'Classic',
          SliVisualStyle.minimal => 'Minimal',
          SliVisualStyle.express => 'Express',
        };

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
                // Screen Title
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 20),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: palette.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Profile / User Avatar Header
                _ProfileHeader(controller: controller),
                const SizedBox(height: 24),

                // Card 1: App Style (Stand-alone grouped pill/card)
                _SettingsCard(
                  children: [
                    _NavRow(
                      icon: Icons.smartphone_rounded,
                      title: 'App style',
                      value: appStyleLabel,
                      onTap: () =>
                          _pushPage(_AppStyleSubpage(controller: controller)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card 2: Main Menu (Appearance, Preferences, Data, Support)
                _SettingsCard(
                  children: [
                    _NavRow(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Theme, accent and background',
                      onTap: () =>
                          _pushPage(_AppearanceSubpage(controller: controller)),
                    ),
                    _settingsDivider(context),
                    _NavRow(
                      icon: Icons.tune_rounded,
                      title: 'Preferences',
                      subtitle: 'Startup, browser and sorting',
                      onTap: () => _pushPage(
                        _PreferencesSubpage(controller: controller),
                      ),
                    ),
                    _settingsDivider(context),
                    _NavRow(
                      icon: Icons.storage_rounded,
                      title: 'Data',
                      subtitle: 'Backups, archive and import',
                      onTap: () => _pushPage(
                        _DataSubpage(
                          controller: controller,
                          formatBytes: _formatBytes,
                        ),
                      ),
                    ),
                    _settingsDivider(context),
                    _NavRow(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'Support',
                      subtitle: 'Report a bug or ask for a feature',
                      onTap: () =>
                          _pushPage(_SupportSubpage(controller: controller)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card 3: About this app (Stand-alone grouped card)
                _SettingsCard(
                  children: [
                    _NavRow(
                      icon: Icons.info_outline_rounded,
                      title: 'About this app',
                      subtitle: 'Version, credits and source code',
                      onTap: () =>
                          _pushPage(_AboutSubpage(controller: controller)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Profile Header Widget
// ---------------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final VaultController controller;

  const _ProfileHeader({required this.controller});

  Future<void> _pickPhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 88,
      );
      if (picked != null) {
        await controller.setProfilePhotoPath(picked.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to pick photo: $e')));
      }
    }
  }

  Future<void> _editName(BuildContext context) async {
    final textController = TextEditingController(text: controller.profileName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Profile Name',
            hintText: 'Enter your name or moniker',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(textController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && context.mounted) {
      await controller.setProfileName(newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final photoPath = controller.profilePhotoPath;
    final hasPhoto = photoPath.isNotEmpty && File(photoPath).existsSync();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with edit badge
        Semantics(
          button: true,
          label: 'Change profile photo',
          child: GestureDetector(
            onTap: () => _pickPhoto(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.elevated,
                    border: Border.all(
                      color: palette.primaryAccent.withValues(alpha: 0.35),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.file(
                            File(photoPath),
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            SliAssets.symbol,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.shield_outlined,
                              size: 44,
                              color: palette.primaryAccent,
                            ),
                          ),
                  ),
                ),
                // Edit badge with pencil icon
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.primaryAccent, // Uses active brand accent, not default violet
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 13, color: palette.onAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Profile Name with Edit Icon
        Semantics(
          button: true,
          label: 'Edit name',
          child: GestureDetector(
            onTap: () => _editName(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.profileName,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: palette.primaryAccent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settings Common UI Components
// ---------------------------------------------------------------------------
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final radius = context.sli.cardRadius;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.28 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: dark ? const Color(0xFF161619) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

Widget _settingsDivider(BuildContext context) {
  final dark = _isDark(context);
  return Divider(
    height: 1,
    thickness: 1,
    indent: 62,
    endIndent: 16,
    color: dark ? const Color(0xFF28282C) : const Color(0xFFE5E5EA),
  );
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final dark = _isDark(context);

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF242428) : const Color(0xFFEAEAEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: palette.textPrimary, size: 17),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;

  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final isCompact = textScale >= 1.4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              _IconBadge(icon: icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (isCompact && value != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        value!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: palette.primaryAccent,
                        ),
                      ),
                    ],
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!isCompact && value != null) ...[
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: palette.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1. App Style Subpage (Streak Skeleton Cards & Legend)
// ---------------------------------------------------------------------------
class _AppStyleSubpage extends StatelessWidget {
  final VaultController controller;

  const _AppStyleSubpage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App style'),
        leading: const BackButton(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = ((constraints.maxWidth - 44 - 32) / 3).clamp(
            80.0,
            140.0,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Style',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select the visual geometry and navigation personality.',
                      style: TextStyle(
                        fontSize: 14,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Streak-inspired 3-Style Skeletons
              _StreakStylePicker(controller: controller, width: width),
              const SizedBox(height: 32),

              // Streak-inspired App Style Legend
              _AppStyleLegend(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

class _StreakStylePicker extends StatelessWidget {
  final VaultController controller;
  final double width;

  const _StreakStylePicker({required this.controller, required this.width});

  @override
  Widget build(BuildContext context) {
    final currentStyle = controller.visualStyle;

    final styles = [
      (SliVisualStyle.classic, 'Classic', const _ClassicPreviewSkeleton()),
      (SliVisualStyle.minimal, 'Minimal', const _MinimalPreviewSkeleton()),
      (SliVisualStyle.express, 'Express', const _ExpressPreviewSkeleton()),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < styles.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          SizedBox(
            width: width,
            child: _StyleSkeletonCard(
              label: styles[i].$2,
              selected: currentStyle == styles[i].$1,
              preview: styles[i].$3,
              onTap: () => controller.setVisualStyle(styles[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _StyleSkeletonCard extends StatelessWidget {
  final String label;
  final bool selected;
  final Widget preview;
  final VoidCallback onTap;

  const _StyleSkeletonCard({
    required this.label,
    required this.selected,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final accent = palette.primaryAccent;
    final dark = _isDark(context);
    final outline = dark ? const Color(0xFF2E2E32) : const Color(0xFFDCDCE3);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 0.62,
              child: AnimatedScale(
                scale: selected ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF141416) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? accent : outline,
                      width: selected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: selected ? 0.25 : 0),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: dark
                            ? const Color(0xFF1B1B1F)
                            : const Color(0xFFF3F3F7),
                      ),
                      child: AnimatedOpacity(
                        opacity: selected ? 1.0 : 0.72,
                        duration: const Duration(milliseconds: 240),
                        child: preview,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: selected ? 15 : 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? accent : palette.textSecondary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              height: 4,
              width: selected ? 24 : 0,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassicPreviewSkeleton extends StatelessWidget {
  const _ClassicPreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E32),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF26262A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF38383D)),
              ),
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF38383D),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF202024),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinimalPreviewSkeleton extends StatelessWidget {
  const _MinimalPreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E32),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFF323238)),
              ),
              padding: const EdgeInsets.all(3),
              child: Column(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E32),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E32),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C20),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpressPreviewSkeleton extends StatelessWidget {
  const _ExpressPreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E32),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF24242A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3C3C44)),
              ),
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF202026),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppStyleLegend extends StatelessWidget {
  final VaultController controller;

  const _AppStyleLegend({required this.controller});

  @override
  Widget build(BuildContext context) {
    final currentStyle = controller.visualStyle;

    final rows = [
      (
        SliVisualStyle.classic,
        'Classic Style',
        'Balanced glass surfaces, luminous borders, and standard 16dp radius.',
      ),
      (
        SliVisualStyle.minimal,
        'Minimal Style',
        'High-density layouts, crisp 8dp borders, and ultra-fast 140ms motion.',
      ),
      (
        SliVisualStyle.express,
        'Express Style',
        'Generous 24dp curves, organic squish feedback, and floating pill tabs.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LegendTile(
              title: rows[i].$2,
              description: rows[i].$3,
              selected: currentStyle == rows[i].$1,
              onTap: () => controller.setVisualStyle(rows[i].$1),
            ),
          ),
      ],
    );
  }
}

class _LegendTile extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _LegendTile({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final accent = palette.primaryAccent;
    final dark = _isDark(context);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.12)
                : (dark ? const Color(0xFF161619) : Colors.white),
            borderRadius: BorderRadius.circular(context.sli.cardRadius),
            border: Border.all(
              color: selected
                  ? accent
                  : (dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.07)),
              width: selected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accent : Colors.transparent,
                  border: Border.all(
                    color: selected ? accent : palette.textSecondary,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: selected ? accent : palette.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Appearance Subpage
// ---------------------------------------------------------------------------
class _AppearanceSubpage extends StatelessWidget {
  final VaultController controller;

  const _AppearanceSubpage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Theme Mode Card
          _SettingsSectionCard(
            title: 'Theme Mode',
            subtitle: 'Choose between standard Dark, deep OLED Black, and clean Light mode.',
            child: _ThemeChoiceRow(controller: controller),
          ),
          const SizedBox(height: 16),

          // Accent Presets Card
          _SettingsSectionCard(
            title: 'Accent Palette Highlight',
            subtitle:
                'Select your preferred WCAG AA/AAA-verified brand color tone.',
            child: _AccentChoiceRow(controller: controller),
          ),
          const SizedBox(height: 16),

          // Atmosphere & Motion
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.blur_on_rounded, size: 22),
                title: const Text(
                  'Atmospheric backgrounds',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Displays background art and soft ambient radial glows across app surfaces.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.atmosphereEnabled,
                onChanged: controller.setAtmosphereEnabled,
              ),
              _settingsDivider(context),
              SwitchListTile(
                secondary: const Icon(
                  Icons.motion_photos_off_rounded,
                  size: 22,
                ),
                title: const Text(
                  'Reduced motion',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Minimizes animation durations and transitions for maximum responsiveness.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.reduceMotion,
                onChanged: controller.setReduceMotion,
              ),
              _settingsDivider(context),
              SwitchListTile(
                secondary: const Icon(Icons.security_rounded, size: 22),
                title: const Text(
                  'Screen Protection (FLAG_SECURE)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Prevents screen recording and recents switcher inspection for maximum privacy.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.screenProtectionEnabled,
                onChanged: controller.setScreenProtectionEnabled,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Preferences Subpage
// ---------------------------------------------------------------------------
class _PreferencesSubpage extends StatelessWidget {
  final VaultController controller;

  const _PreferencesSubpage({required this.controller});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Startup Destination
          _SettingsSectionCard(
            title: 'Default Startup Screen',
            subtitle:
                'Choose which destination opens when launching SLI Vault.',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 10) / 2;
                final tabs = [
                  (0, 'Home', Icons.home_rounded),
                  (1, 'Browse', Icons.explore_rounded),
                  (2, 'Favorites', Icons.favorite_rounded),
                  (3, 'Collections', Icons.folder_rounded),
                ];
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tabs.map((tab) {
                    final isSelected = controller.defaultStartupTab == tab.$1;
                    return SizedBox(
                      width: itemWidth,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.setDefaultStartupTab(tab.$1),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? palette.primaryAccent.withValues(
                                      alpha: 0.16,
                                    )
                                  : (_isDark(context)
                                        ? const Color(0xFF222226)
                                        : const Color(0xFFF0F0F4)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? palette.primaryAccent
                                    : (_isDark(context)
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(
                                              alpha: 0.08,
                                            )),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  tab.$3,
                                  size: 18,
                                  color: isSelected
                                      ? palette.primaryAccent
                                      : palette.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tab.$2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? palette.primaryAccent
                                          : palette.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: palette.primaryAccent,
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
            ),
          ),
          const SizedBox(height: 16),

          // Browse Sorting & Density
          _SettingsSectionCard(
            title: 'Default Browse Sorting',
            subtitle: 'Preferred order for library items.',
            child: Row(
              children: [
                for (var i = 0; i < VaultSortOption.values.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final sort = VaultSortOption.values[i];
                        final isSelected = controller.defaultBrowseSort == sort;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.setDefaultBrowseSort(sort),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 46,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? palette.primaryAccent.withValues(
                                        alpha: 0.16,
                                      )
                                    : (_isDark(context)
                                          ? const Color(0xFF222226)
                                          : const Color(0xFFF0F0F4)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? palette.primaryAccent
                                      : (_isDark(context)
                                            ? Colors.white.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.08,
                                              )),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  sort.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? palette.primaryAccent
                                        : palette.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Toggles
          _SettingsCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.open_in_browser_rounded, size: 22),
                title: const Text(
                  'Open in In-App Browser',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Launch links inside the app using Chrome Custom Tabs.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.inAppBrowser,
                onChanged: controller.setInAppBrowser,
              ),
              _settingsDivider(context),
              SwitchListTile(
                secondary: const Icon(Icons.vibration_rounded, size: 22),
                title: const Text(
                  'Haptic Feedback',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Subtle vibration feedback on buttons, toggles, and favorites.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.hapticsEnabled,
                onChanged: controller.setHapticsEnabled,
              ),
              _settingsDivider(context),
              SwitchListTile(
                secondary: const Icon(Icons.auto_fix_high_rounded, size: 22),
                title: const Text(
                  'Auto-Fetch Link Metadata',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Automatically scrap OpenGraph title, description, and thumbnail when adding links.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.autoFetchMetadata,
                onChanged: controller.setAutoFetchMetadata,
              ),
              _settingsDivider(context),
              SwitchListTile(
                key: const ValueKey('lock-vault-switch'),
                secondary: const Icon(Icons.lock_outline_rounded, size: 22),
                title: const Text(
                  'Biometric Vault Lock',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Require fingerprint or device passcode when returning to the app.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                value: controller.lockEnabled,
                onChanged: (val) => controller.setLockEnabled(val),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Data Subpage (Backups, Import, Maintenance)
// ---------------------------------------------------------------------------
class _DataSubpage extends StatefulWidget {
  final VaultController controller;
  final String Function(int) formatBytes;

  const _DataSubpage({required this.controller, required this.formatBytes});

  @override
  State<_DataSubpage> createState() => _DataSubpageState();
}

class _DataSubpageState extends State<_DataSubpage> {
  bool _isWorking = false;

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
      final messenger = ScaffoldMessenger.of(context);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliIllustration(
                SliAssets.illExportSuccess,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Backup Archive Ready',
                style: Theme.of(dialogContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Created $fileName (${widget.formatBytes(zipBytes.length)}) containing ${widget.controller.allItems.length} items, links.csv, and full-resolution images.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.share_outlined, size: 16),
              label: const Text('Share Backup'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Share.shareXFiles([
                  XFile(tempFile.path),
                ], text: 'SLI Vault Backup Archive');
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_rounded, size: 16),
              label: const Text('Save to Device'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  // Pass `bytes` so Android writes via the Storage Access
                  // Framework / document provider. The returned path may be a
                  // virtual document path (e.g. `/document/1770`) — never treat
                  // that as a dart:io filesystem path.
                  final outputPath = await FilePicker.platform.saveFile(
                    dialogTitle: 'Save SLI Vault Backup',
                    fileName: fileName,
                    bytes: zipBytes,
                    type: FileType.custom,
                    allowedExtensions: ['zip'],
                  );
                  if (outputPath != null && mounted) {
                    if (isFilesystemPathSafeForDartIo(outputPath)) {
                      final outputFile = File(outputPath);
                      if (!await outputFile.exists() ||
                          await outputFile.length() == 0) {
                        await outputFile.writeAsBytes(zipBytes, flush: true);
                      }
                    }
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Backup archive saved successfully.'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Save failed: $e')),
                    );
                  }
                }
              },
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
      if (bytes == null &&
          file.path != null &&
          isFilesystemPathSafeForDartIo(file.path!)) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) {
        throw const FormatException(
          'Could not read selected backup archive. '
          'If the file was chosen from cloud or Downloads, try again or use Share.',
        );
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _isWorking = false);
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Temporary Cache?'),
        content: const Text(
          'This will remove temporary export archives and pending share buffers. Your saved vault items and images will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      final freed = await widget.controller.clearTemporaryCache();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleaned temporary cache (${widget.formatBytes(freed)} freed).',
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

  Future<void> _cleanOrphanedImages() async {
    if (_isWorking) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clean Orphaned Images?'),
        content: const Text(
          'This will permanently delete unindexed image files in private storage that are no longer linked to any item in your vault database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.sli.destructive,
              foregroundColor: ctx.sli.onDestructive,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clean Images'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isWorking = true);
    try {
      final count = await widget.controller.cleanOrphanedImages();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cleaned $count orphaned image files.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Clean failed: $e')));
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

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final total = widget.controller.allItems.length;
    final links = widget.controller.countByFilter(VaultTypeFilter.links);
    final images = widget.controller.countByFilter(VaultTypeFilter.images);

    return Scaffold(
      appBar: AppBar(title: const Text('Data'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Storage Usage & Backup Card
          _SettingsSectionCard(
            title: 'Local Storage & Backup',
            subtitle: '$total total items ($links links • $images images)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Approximate local storage used: ${widget.formatBytes(widget.controller.approxStorageBytes)}',
                  style: SliTheme.mono(context, fontSize: 12.5),
                ),
                const SizedBox(height: 8),
                _StorageBar(approxBytes: widget.controller.approxStorageBytes),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stack = constraints.maxWidth < 280;
                    final exportBtn = ElevatedButton.icon(
                      icon: const Icon(Icons.upload_file_rounded, size: 18),
                      label: const Text('Export Backup'),
                      onPressed: _exportBackup,
                    );
                    final importBtn = OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Import Backup'),
                      onPressed: _importBackup,
                    );
                    if (stack) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          exportBtn,
                          const SizedBox(height: 8),
                          importBtn,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: exportBtn),
                        const SizedBox(width: 10),
                        Expanded(child: importBtn),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Database & Cache Maintenance
          _SettingsCard(
            children: [
              ListTile(
                key: const ValueKey('vacuum-db-button'),
                leading: const _IconBadge(icon: Icons.compress_rounded),
                title: const Text(
                  'Defragment & Optimize Database',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Runs SQLite VACUUM to reclaim free pages and rebuild B-tree indexes.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                onTap: _vacuumDb,
              ),
              _settingsDivider(context),
              ListTile(
                key: const ValueKey('check-integrity-button'),
                leading: const _IconBadge(
                  icon: Icons.health_and_safety_outlined,
                ),
                title: const Text(
                  'Check Vault Storage Integrity',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Audits database records against locally stored image files.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                onTap: _runIntegrityCheck,
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(
                  icon: Icons.cleaning_services_outlined,
                ),
                title: const Text(
                  'Clean Orphaned Images',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Removes unindexed residual files from private image storage.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                onTap: _cleanOrphanedImages,
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(icon: Icons.delete_sweep_outlined),
                title: const Text(
                  'Clear Temporary Cache',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Cleans temporary export archives and pending share buffers.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                onTap: _cleanTempCache,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Support Subpage
// ---------------------------------------------------------------------------
class _SupportSubpage extends StatelessWidget {
  final VaultController controller;

  const _SupportSubpage({required this.controller});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open: $url')));
      }
    }
  }

  Future<void> _shareApp() async {
    await Share.share(
      'SLI Vault - A privacy-first, local-first personal vault for links, screenshots, and visual inspiration.\nhttps://sahaya-savari.github.io/sli-vault/',
      subject: 'SLI Vault - Local-First Personal Vault',
    );
  }

  Future<void> _contactDev(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'sahayasavari@gmail.com',
      query: 'subject=SLI Vault Support & Feedback',
    );
    try {
      if (!await launchUrl(uri)) {
        if (context.mounted) {
          await _openUrl(
            context,
            'https://github.com/sahaya-savari/sli-vault/issues',
          );
        }
      }
    } catch (_) {
      await Clipboard.setData(
        const ClipboardData(text: 'sahayasavari@gmail.com'),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email copied: sahayasavari@gmail.com')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;

    return Scaffold(
      appBar: AppBar(title: const Text('Support'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _SettingsCard(
            children: [
              ListTile(
                leading: const _IconBadge(icon: Icons.bug_report_outlined),
                title: const Text(
                  'Report an Issue on GitHub',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'File bugs or technical issues in our repository issue tracker.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _openUrl(
                  context,
                  'https://github.com/sahaya-savari/sli-vault/issues',
                ),
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(
                  icon: Icons.lightbulb_outline_rounded,
                ),
                title: const Text(
                  'Request a Feature',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Suggest ideas or enhancements for future releases.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _openUrl(
                  context,
                  'https://github.com/sahaya-savari/sli-vault/discussions',
                ),
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(icon: Icons.mail_outline_rounded),
                title: const Text(
                  'Contact Developer',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Direct email to sahayasavari@gmail.com',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                onTap: () => _contactDev(context),
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(icon: Icons.star_outline_rounded),
                title: const Text(
                  'Star on GitHub',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Support open source development and track upcoming milestones.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _openUrl(
                  context,
                  'https://github.com/sahaya-savari/sli-vault',
                ),
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(icon: Icons.share_rounded),
                title: const Text(
                  'Share SLI Vault',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Tell friends about this private, offline-first personal vault.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                onTap: _shareApp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. About Subpage
// ---------------------------------------------------------------------------
class _AboutSubpage extends StatelessWidget {
  final VaultController controller;

  const _AboutSubpage({required this.controller});

  Future<void> _openExternal(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open: $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final style = controller.visualStyle;
    final isExpress = style == SliVisualStyle.express;
    final isMinimal = style == SliVisualStyle.minimal;

    final double iconRadius = isExpress ? 24.0 : (isMinimal ? 12.0 : 18.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About this app'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // App Hero Branding Card
          Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(iconRadius),
                    boxShadow: [
                      BoxShadow(
                        color: palette.primaryAccent.withValues(
                          alpha: isExpress ? 0.32 : 0.18,
                        ),
                        blurRadius: isExpress ? 28 : 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(iconRadius),
                    child: Image.asset(
                      SliAssets.symbol,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SLI Vault',
                  style: TextStyle(
                    fontFamily: isExpress
                        ? SliTokens.fontFamilyDisplay
                        : SliTokens.fontFamily,
                    fontSize: isExpress ? 26 : (isMinimal ? 22 : 24),
                    fontWeight: isExpress ? FontWeight.w900 : FontWeight.w800,
                    color: palette.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primaryAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(isExpress ? 9999 : 6),
                    border: Border.all(
                      color: palette.primaryAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    SliVersion.buildLabel,
                    style: TextStyle(
                      fontFamily: SliTokens.fontFamilyMono,
                      fontSize: 12,
                      color: palette.primaryAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'A privacy-first, local-first personal vault for links, screenshots, and visual inspiration. Stored securely on-device with zero tracking or telemetry.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: SliTokens.fontFamily,
                      fontSize: 13.5,
                      height: 1.45,
                      color: palette.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Developer Attribution
                InkWell(
                  onTap: () => _openExternal(
                    context,
                    'https://github.com/sahaya-savari',
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: 'Created with care by ',
                        style: TextStyle(
                          fontFamily: SliTokens.fontFamily,
                          fontSize: 13,
                          color: palette.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${SliVersion.authorName} (${SliVersion.authorHandle})',
                            style: TextStyle(
                              fontFamily: SliTokens.fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: palette.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Primary Actions (GitHub, Issues, Website)
          Row(
            children: [
              Expanded(
                child: _ActionTileButton(
                  icon: Icons.star_rounded,
                  label: 'Star GitHub',
                  onTap: () => _openExternal(context, SliVersion.repositoryUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTileButton(
                  icon: Icons.bug_report_rounded,
                  label: 'Issues',
                  onTap: () => _openExternal(context, SliVersion.issuesUrl),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTileButton(
                  icon: Icons.language_rounded,
                  label: 'Website',
                  onTap: () => _openExternal(context, SliVersion.websiteUrl),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Legal, Privacy & Licenses Section
          _SettingsCard(
            children: [
              ListTile(
                key: const ValueKey('Privacy Policy'),
                leading: const _IconBadge(icon: Icons.verified_user_outlined),
                title: const Text(
                  'Privacy & Security Manifesto',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  '100% on-device SQLite database and private storage.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              _settingsDivider(context),
              ListTile(
                key: const ValueKey('Terms of Use'),
                leading: const _IconBadge(icon: Icons.description_outlined),
                title: const Text(
                  'Terms of Use',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Local storage, backups, and your personal data rights.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TermsScreen())),
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(icon: Icons.code_rounded),
                title: const Text(
                  'Open Source Licenses',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Third-party software libraries, Figtree & JetBrains Mono.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'SLI Vault',
                  applicationVersion: SliVersion.fullVersion,
                ),
              ),
              _settingsDivider(context),
              ListTile(
                leading: const _IconBadge(icon: Icons.policy_outlined),
                title: const Text(
                  'MIT License',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Project-owned code and documentation license terms.',
                  style: TextStyle(color: palette.textSecondary, fontSize: 13),
                ),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () => _openExternal(context, SliVersion.licenseUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTileButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final style = palette.visualStyle;
    final isExpress = style == SliVisualStyle.express;
    final isMinimal = style == SliVisualStyle.minimal;
    final radius = isExpress ? 9999.0 : (isMinimal ? 8.0 : 14.0);

    return Material(
      color: isMinimal ? palette.elevated : palette.surfaceFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: palette.border.withValues(alpha: isMinimal ? 0.9 : 0.6),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isExpress ? 14 : 12,
            horizontal: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: palette.primaryAccent),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: isMinimal
                      ? SliTokens.fontFamilyMono
                      : SliTokens.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable Section Card Helper
// ---------------------------------------------------------------------------
class _SettingsSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final dark = _isDark(context);

    return Material(
      color: dark ? const Color(0xFF161619) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.sli.cardRadius),
        side: BorderSide(
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: palette.textSecondary),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Storage Bar
// ---------------------------------------------------------------------------
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

// ---------------------------------------------------------------------------
// Theme Choice Row (3 Equal-Width Columns)
// ---------------------------------------------------------------------------
class _ThemeChoiceRow extends StatelessWidget {
  final VaultController controller;

  const _ThemeChoiceRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final modes = [
      ('dark', 'Dark', Icons.dark_mode_outlined),
      ('amoled', 'OLED Black', Icons.brightness_1_rounded),
      ('light', 'Light', Icons.light_mode_outlined),
    ];

    return Row(
      children: [
        for (var i = 0; i < modes.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _ThemeButton(
              key: ValueKey('theme-chip-${modes[i].$1}'),
              icon: modes[i].$3,
              label: modes[i].$2,
              selected: controller.themeModeName == modes[i].$1,
              onTap: () => controller.setThemeModeName(modes[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final dark = _isDark(context);
    final accent = palette.primaryAccent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.16)
                : (dark ? const Color(0xFF222226) : const Color(0xFFF0F0F4)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? accent
                  : (dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08)),
              width: selected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? accent : palette.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? accent : palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accent Choice Row (Uniform 2-Column Equal Grid)
// ---------------------------------------------------------------------------
class _AccentChoiceRow extends StatelessWidget {
  final VaultController controller;

  const _AccentChoiceRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final active = controller.accentPreset;
    final presets = SliAccentPreset.presets;
    final dark = _isDark(context);
    final palette = context.sli;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: presets.map((preset) {
            final isSelected = active == preset.key;
            return SizedBox(
              width: itemWidth,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('accent-chip-${preset.key}'),
                  onTap: () => controller.setAccentPreset(preset.key),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? preset.primary.withValues(alpha: 0.16)
                          : (dark
                                ? const Color(0xFF222226)
                                : const Color(0xFFF0F0F4)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? preset.primary
                            : (dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.08)),
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: preset.primary,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            preset.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? preset.primary
                                  : palette.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: preset.primary,
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
