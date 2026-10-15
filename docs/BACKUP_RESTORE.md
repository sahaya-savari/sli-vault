# Backup and Restore

## Kotlin JSON

Accepted Kotlin export fields include `app`, `version`, `items`, item IDs, uppercase types, title, URL, domain, description, tags, favorite state, collection, file size, epoch timestamps, and `imageBase64`.

The importer rejects malformed JSON, unsupported versions, invalid records, invalid Base64, missing image bytes, and unsupported image binaries. IDs already present in the vault are reported as skipped; duplicate IDs within one backup are rejected.

## Flutter ZIP

Flutter backups contain:

```text
manifest.json
images/<image-id>
```

The manifest includes product identity, format version, database schema version, item metadata, and image metadata. Format v2 image metadata includes exact byte length and SHA-256; format v1 remains accepted for backward compatibility. Archives from a newer backup format or database schema are rejected.

ZIP imports reject traversal/absolute paths, duplicate or aliased manifests, duplicate entries or item IDs, unexpected/orphan files, missing images, extension/content mismatches, malformed manifests, corrupt/truncated ZIPs, invalid image bytes, and compressed or expanded content above safety caps.

Restore previews are validated before confirmation. Cancellation performs no write. Existing IDs are skipped and existing records are not overwritten. Image ID collisions with different bytes fail safely. Newly staged images are removed if the database transaction fails, leaving no partial records or files.

Backups are created in the temporary directory and shared explicitly; they are not placed in public media folders by default.

Export fails rather than silently omitting a referenced private image that is missing. Empty and large synthetic libraries are covered by automated tests. Keep exported ZIP/JSON files private: they are portable copies and are not encrypted by SLI Vault.

A real-file export/import walkthrough on a device (save a ZIP, move it, import it, and confirm skipped IDs) is still incomplete. Automated fixtures are not a substitute for that pass.
