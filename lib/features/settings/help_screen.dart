import 'package:flutter/material.dart';
import '../../core/theme/sli_theme.dart';

/// Comprehensive Beginner-Friendly Guide & In-App Help for SLI Vault.
/// Follows actual, verified app functionality across Classic, Minimal, and Express styles.
class SliHelpScreen extends StatelessWidget {
  const SliHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final style = palette.visualStyle;
    final isExpress = style == SliVisualStyle.express;
    final isMinimal = style == SliVisualStyle.minimal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & User Guide'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Header Card
          Container(
            padding: EdgeInsets.all(isMinimal ? 12 : (isExpress ? 20 : 16)),
            decoration: BoxDecoration(
              color: palette.elevated,
              borderRadius: BorderRadius.circular(palette.cardRadius),
              border: Border.all(
                color: palette.border.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.primaryAccent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(
                      isExpress ? 9999 : (isMinimal ? 8 : 12),
                    ),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: palette.primaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Getting Started with SLI Vault',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Quick, verified answers on how to store, organize, back up, and secure your personal vault.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: palette.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Storage & Privacy
          _HelpTopicCard(
            icon: Icons.shield_outlined,
            title: '1. What SLI Vault does & Where Data is Stored',
            bullets: const [
              'SLI Vault is a 100% local-first, privacy-respecting private library for your web links, research bookmarks, screenshots, and visual inspiration.',
              'All data is stored exclusively on this device in an encrypted/private SQLite database (app private sandbox).',
              'Imported images are stored in app-private filesystem storage (not in public Android photo gallery).',
              'Zero cloud accounts, zero tracking, and zero advertising SDKs.',
            ],
          ),
          const SizedBox(height: 12),

          // 2. Saving Links
          _HelpTopicCard(
            icon: Icons.link_rounded,
            title: '2. How to Save a Link',
            bullets: const [
              'Tap the (+) Add button in the bottom navigation bar or floating action button.',
              'Select "Link" mode, paste or type a valid web URL (e.g., https://example.com).',
              'Optional: Enter a custom title, description, tags, or assign to a collection.',
              'Tap "Save Link". If Auto-Fetch is enabled in Preferences, SLI Vault automatically pulls the webpage title, description, and thumbnail preview.',
            ],
          ),
          const SizedBox(height: 12),

          // 3. Adding Images & Screenshots
          _HelpTopicCard(
            icon: Icons.image_outlined,
            title: '3. How to Add Images & Screenshots',
            bullets: const [
              'Tap the (+) Add button and switch the toggle to "Image".',
              'Tap "Choose Image" to select a photo, design reference, or screenshot from your device gallery.',
              'SLI Vault copies the image into its private secure storage folder.',
              'Add an optional title, caption, tags, or collection, then tap "Save Image".',
            ],
          ),
          const SizedBox(height: 12),

          // 4. Browsing, Searching & Opening
          _HelpTopicCard(
            icon: Icons.search_rounded,
            title: '4. Browsing, Searching & Opening Items',
            bullets: const [
              'Home: View quick recents, pinned links, image grids, and storage statistics.',
              'Browse: Complete library with real-time text search (searches title, URL, domain, and notes) and filters (All, Links, Images).',
              'Tap any link card to launch it in the high-speed In-App Browser (Chrome Custom Tabs) or external browser.',
              'Tap any image item to open the interactive pinch-to-zoom full-screen viewer.',
            ],
          ),
          const SizedBox(height: 12),

          // 5. Favourites & Collections
          _HelpTopicCard(
            icon: Icons.folder_special_outlined,
            title: '5. Favorites & Custom Collections',
            bullets: const [
              'Star/Favorite: Tap the heart or star icon on any card or detail screen to pin it to your Favorites tab.',
              'Create Collection: Go to the Collections tab, tap (+) or "New Collection", enter a name, and tap Create.',
              'Organize: When saving or editing an item, choose which collection folder it belongs to.',
              'Move/Remove: From an item\'s menu, easily reassign items between collections.',
            ],
          ),
          const SizedBox(height: 12),

          // 6. Exporting Backups
          _HelpTopicCard(
            icon: Icons.upload_file_rounded,
            title: '6. How to Export a Backup & Where It Goes',
            bullets: const [
              'Go to Settings -> Data.',
              'Tap "Export Backup".',
              'SLI Vault bundles your SQLite records and all local image files into a single standardized .slivault / .zip archive.',
              'Android system share sheet opens: Save the backup file to your Google Drive, Downloads, SD card, or send it to another device via Files app.',
            ],
          ),
          const SizedBox(height: 12),

          // 7. Restoring Backups
          _HelpTopicCard(
            icon: Icons.download_rounded,
            title: '7. How to Restore a Backup',
            bullets: const [
              'Go to Settings -> Data.',
              'Tap "Import Backup" and pick your previously exported backup file.',
              'An import preview dialog displays the number of new items, duplicates, and verified images.',
              'Tap "Import Items" to safely merge records without overwriting your existing library.',
            ],
          ),
          const SizedBox(height: 12),

          // 8. Security & Auto-Lock Cooldown
          _HelpTopicCard(
            icon: Icons.fingerprint_rounded,
            title: '8. Biometric Lock & Auto-Lock Cooldown',
            bullets: const [
              'Go to Settings -> Preferences.',
              'Enable "Biometric Vault Lock" to require fingerprint, face unlock, or device PIN when opening the vault.',
              'Under "Auto-Lock Cooldown", select how quickly the app locks after you leave:',
              '  • Immediately (0s): Locks as soon as the app is backgrounded.',
              '  • 5 sec, 10 sec, or 15 sec: Allows a short grace period when switching briefly between apps.',
            ],
          ),
          const SizedBox(height: 12),

          // 9. Visual Styles & Themes
          _HelpTopicCard(
            icon: Icons.palette_outlined,
            title: '9. Appearance Styles & Personalization',
            bullets: const [
              'Go to Settings -> App style to choose between Classic, Minimal, and Express layouts.',
              'Go to Settings -> Appearance to pick Dark, OLED Black (true pitch black), or Light theme, plus 5 vibrant accent colors.',
              'Theme and style preferences persist across restarts and work seamlessly together.',
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> bullets;

  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final isMinimal = palette.visualStyle == SliVisualStyle.minimal;

    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceFill,
        borderRadius: BorderRadius.circular(palette.cardRadius),
        border: Border.all(
          color: palette.border.withValues(alpha: isMinimal ? 0.9 : 0.6),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(isMinimal ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: palette.primaryAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final bullet in bullets) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: palette.primaryAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        fontSize: 13,
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
