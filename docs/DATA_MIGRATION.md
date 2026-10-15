# Data Migration

The Kotlin recovery application at `D:\sli-vault` remains untouched. Its Room database is not opened directly by Flutter because the database names, columns, tag encoding, paths, and timestamp representations differ.

## Kotlin Transfer

1. Export JSON from the Kotlin application.
2. Keep the Kotlin app installed and its data intact.
3. In Flutter Settings, choose the exported `.json` file.
4. Review the validation summary.
5. Confirm import.
6. Verify item counts, collections, favorites, and images.

The Flutter adapter reads the Kotlin exporter fields, converts epoch-millisecond timestamps, accepts uppercase Kotlin item types, converts comma-separated tags, and ignores inaccessible Kotlin absolute image paths. Image bytes come from `imageBase64` and are written to Flutter private storage with stable derived IDs.

Existing IDs are skipped rather than overwritten. Validation completes before records are inserted. Image staging and database insertion are cleaned up when an import fails.

## SQLite Upgrade

Flutter schema version 1 is upgraded in place to version 2. The migration adds description, collection, and file-size columns plus a collection index. Existing records and onboarding preferences are preserved. Destructive recreation is not used.

Never uninstall the Kotlin app or clear its data during migration testing.
