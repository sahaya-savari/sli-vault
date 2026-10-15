# Security

SLI Vault is a local-first library. It has no account system and no server to breach. The sensitive material is the on-device database, imported images, and any ZIP or JSON backup the user exports. Those backups are not encrypted by the app.

## Reporting

Do not open a public issue that includes a vault database, backup file, signing key, or screenshot of private library contents.

If this GitHub repository has private vulnerability reporting enabled, use that. A dedicated security contact has not been published yet. Until one is listed here, do not send secrets by email to an address guessed from the commit history.

## Current privacy gaps (known)

- `FLAG_SECURE` is off at the owner's request. Android can capture the Flutter window and the recent-apps preview until the owner asks to restore the commented `addFlags` call in `MainActivity.kt`.
- Optional background lock uses the device authenticator. It does not encrypt SQLite.
- Release builds are debug-signed, and the application ID is still `com.example.sli_vault`. Those are publication blockers, not hidden production credentials. No production keystore is in this repository.
