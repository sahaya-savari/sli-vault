# Backup and Restore

## Kotlin JSON

Accepted Kotlin export fields include `app`, `version`, `items`, item IDs, uppercase types, title, URL, domain, description, tags, favorite state, collection, file size, epoch timestamps, and `imageBase64`.

The importer rejects malformed JSON, unsupported versions, invalid records, invalid Base64, missing image bytes, and unsupported image binaries. IDs already present in the vault are reported as skipped; duplicate IDs within one backup are rejected.

## Flutter ZIP (Format v3)

Flutter backups produce a fully portable archive:

```text
manifest.json
images/<image-id>
links.csv
README.txt
```

The manifest includes product identity (`SLI Vault`), backup format version (`3`), database schema version (`2`), item metadata, image metadata, and `customCollections` list.
- Format v3 includes `links.csv` with formula injection mitigation (prepending `'` to `=`, `+`, `-`, `@`, `\t`, `\r`) and `README.txt` instructions for desktop extraction without the app.
- Custom collections (including empty collections) are tracked in `manifest.json` and restored into local preferences.
- Image metadata includes exact byte length, SHA-256 digest, and MIME type. Formats supported include JPEG, PNG, GIF, WebP, BMP, and HEIC/HEIF (with ISO BMFF `ftyp` box brand validation).
- Format v1 and v2 archives remain fully accepted for backward compatibility. Archives from newer future backup formats or database schemas are safely rejected.

ZIP imports reject path traversal (`..`), absolute paths, duplicate or aliased manifests, duplicate entries or item IDs, unexpected/orphan files, missing images, extension/content mismatches, malformed manifests, corrupt/truncated ZIPs, invalid image bytes, and compressed or expanded content above safety caps.

Restore previews are validated before confirmation. Cancellation performs no write. Existing IDs are skipped and existing records are not overwritten. Image ID collisions with different bytes fail safely. Newly staged images are removed if the database transaction fails, leaving no partial records or files.

Backups are created in the temporary directory and shared explicitly; they are not placed in public media folders by default.

Export fails rather than silently omitting a referenced private image that is missing. Empty and large synthetic libraries are covered by automated tests. Keep exported ZIP/JSON files private: they are portable copies and are not encrypted by SLI Vault.

## Selective Export

Users can select specific items from the Browse screen (via long-press multi-select) and export only those items into a valid ZIP archive containing `manifest.json`, `links.csv`, `README.txt`, and the corresponding full-resolution media files.

A physical device-to-device transfer test remains labeled as not tested on physical hardware. Automated host and round-trip fixtures are verified.
