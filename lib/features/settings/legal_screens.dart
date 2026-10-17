 import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/sli_theme.dart';

class AboutSliVaultScreen extends StatelessWidget {
  const AboutSliVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _DocumentScaffold(
      title: 'About SLI Vault',
      children: [
        const _DocumentSection(
          heading: 'SLI Vault 1.0.1',
          body: 'SLI Vault is a local-first personal library for links and images (including screenshots you import). Records and imported media are stored in app-private storage on this device.',
        ),
        const _DocumentSection(
          heading: 'Privacy model',
          body: 'The app has no account, cloud sync, advertising, or analytics integration. Optional vault locking uses the authentication configured on the device; it does not encrypt the database.',
        ),
        const _DocumentSection(
          heading: 'Credits & Acknowledgements',
          body: 'Design inspiration and curated developer resources referenced from InlitX Streak Resources. SLI Vault is an independent project and is not affiliated with or endorsed by InlitX.',
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('InlitX Streak Resources'),
          subtitle: const Text('https://inlitx.github.io/streak/resources/'),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () async {
            final uri = Uri.parse('https://inlitx.github.io/streak/resources/');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
        ),
        const SizedBox(height: SliTokens.spaceMd),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Open-source licenses'),
          subtitle: const Text('Licenses supplied by Flutter dependencies'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'SLI Vault',
            applicationVersion: '1.0.1',
          ),
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScaffold(
      title: 'Privacy Policy',
      children: [
        _DocumentSection(
          heading: 'Data stored by the app',
          body: 'SLI Vault stores saved links, titles, descriptions, tags, favorite state, collection assignments, timestamps, settings, and imported image files locally in app-private storage.',
        ),
        _DocumentSection(
          heading: 'Data transmission',
          body: 'SLI Vault does not include an account service, cloud sync, analytics, or advertising SDK. A link is sent to another app only when you choose to open or share it. Backup archives leave the app only when you explicitly share or save them.',
        ),
        _DocumentSection(
          heading: 'Device features',
          body: 'If enabled, vault locking asks the operating system to authenticate you with a configured biometric or device credential. SLI Vault does not receive or store biometric data. Android inbound sharing copies selected image content to temporary app cache for review.',
        ),
        _DocumentSection(
          heading: 'Deletion and backups',
          body: 'You can delete individual items or clear the vault. Deleting a media item removes its private image when no other item references it. Exported backups are separate files under your control, are not encrypted by SLI Vault, and are not deleted when the vault is cleared.',
        ),
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DocumentScaffold(
      title: 'Terms of Use',
      children: [
        _DocumentSection(
          heading: 'Local storage and backups',
          body: 'You are responsible for maintaining device access and any backup files you create. SLI Vault does not provide hosted storage, account recovery, or cloud restoration.',
        ),
        _DocumentSection(
          heading: 'Your content',
          body: 'Only save or share content that you are permitted to use. Opening links and sharing content hands that data to the selected external application under its own terms and privacy practices.',
        ),
        _DocumentSection(
          heading: 'Availability',
          body: 'The app describes current on-device behavior and does not promise uninterrupted operation or recovery from device loss, storage failure, or deletion.',
        ),
      ],
    );
  }
}

class _DocumentScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DocumentScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(SliTokens.spaceLg),
          children: children,
        ),
      ),
    );
  }
}

class _DocumentSection extends StatelessWidget {
  final String heading;
  final String body;

  const _DocumentSection({required this.heading, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SliTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: SliTokens.spaceSm),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
