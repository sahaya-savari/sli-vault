# Security

SLI Vault is a local-first library. It has no account system and no server to breach. The sensitive material is the on-device database, imported images, and any ZIP or JSON backup the user exports. Those backups are not encrypted by the app.

## Reporting

Do not open a public issue that includes a vault database, backup file, signing key, or screenshot of private library contents.

If this GitHub repository has private vulnerability reporting enabled, use that. A dedicated security contact has not been published yet. Until one is listed here, do not send secrets by email to an address guessed from the commit history.

## Current privacy gaps (known)

- `FLAG_SECURE` has been removed in `MainActivity.kt` so users can capture screenshots normally. App lock and biometrics protect access to library contents.
- Optional background lock uses the device authenticator. It does not encrypt SQLite.
- The application ID is `com.sahayasavari.slivault`. Release signing uses a local owner keystore referenced by `android/key.properties` (and GitHub Actions secrets for CI). No keystore or `key.properties` is in this repository.
