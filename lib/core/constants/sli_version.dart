/// Centralized version, build, and project identity metadata for SLI Vault.
class SliVersion {
  SliVersion._();

  /// Target application version.
  static const String versionName = '1.0.1';

  /// Monotonically increasing Android build code for upgrades.
  static const int versionCode = 2009;

  /// Combined version and build representation.
  static const String fullVersion = '$versionName+$versionCode';

  /// Standard display string for headers and about screens.
  static const String buildLabel = 'Version $versionName (Build $versionCode)';

  /// Lead developer and verified repository links.
  static const String authorName = 'Sahaya Savari';
  static const String authorHandle = '@sahaya-savari';
  static const String repositoryUrl = 'https://github.com/sahaya-savari/sli-vault';
  static const String issuesUrl = 'https://github.com/sahaya-savari/sli-vault/issues';
  static const String websiteUrl = 'https://sahaya-savari.github.io/sli-vault';
  static const String licenseUrl = 'https://github.com/sahaya-savari/sli-vault/blob/main/LICENSE';
}
