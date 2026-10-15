# Backup and Restore

## Kotlin JSON

Accepted Kotlin export fields include `app`, `version`, `items`, item IDs, uppercase types, title, URL, domain, description, tags, favorite state, collection, file size, epoch timestamps, and `imageBase64`.

The importer rejects malformed JSON, unsupported versions, invalid records, invalid Base64, missing image bytes, and unsupported image binaries. Duplicate IDs are reported as skipped.

## Flutter ZIP

Flutter backups contain:

```text
manifest.json
images/<image-id>
```

The manifest includes product identity, format version, schema version, item metadata, and image metadata. ZIP imports reject traversal paths, absolute paths, unexpected entries, malformed manifests, invalid image bytes, and unsupported versions.

Restore previews are validated before confirmation. Existing records are not overwritten. Image collisions with different bytes fail safely. Newly staged images are removed if the database transaction fails.

Backups are created in the temporary directory and shared explicitly; they are not placed in public media folders by default.
