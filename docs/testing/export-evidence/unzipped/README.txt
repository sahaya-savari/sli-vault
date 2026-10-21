SLI VAULT BACKUP ARCHIVE
========================

This archive is a complete, portable backup of your personal SLI Vault library.

CONTENTS
--------
1. manifest.json
   Structured JSON catalog of all library items, collections, tags, favorites,
   and media checksums (SHA-256). Used by SLI Vault to restore your library.

2. images/
   The original binary image files (PNG, JPEG, WebP, GIF, BMP, HEIC) saved in
   your vault. Images preserve their exact original bytes, format, and animations.

3. links.csv
   A standard UTF-8 spreadsheet-compatible export of your saved links and
   item metadata. You can open this file in Microsoft Excel, Google Sheets,
   Apple Numbers, or any text editor without installing SLI Vault.

4. README.txt
   This documentation file.

HOW TO EXTRACT & VIEW ON A PC
-----------------------------
You can open this ZIP archive with standard archive utilities (Windows Explorer,
macOS Archive Utility, 7-Zip, unzip, etc.):
- Extract the archive to a folder.
- Open 'links.csv' in spreadsheet software to browse your saved URLs and notes.
- Browse the 'images/' folder to view your saved photos and screenshots. Note that
  some formats (such as HEIC or WebP) may require viewing software that supports them.

HOW TO RESTORE IN SLI VAULT
---------------------------
1. Copy or share this ZIP file to your device.
2. Open SLI Vault.
3. Go to Settings -> Storage & Backup -> Import Backup.
4. Select this ZIP file.
5. Review the validation summary and confirm import.
Existing items already in your vault are kept; new items, custom collections,
and images are restored safely into app-private storage.

PRIVACY & SECURITY NOTICE
-------------------------
This backup file is NOT encrypted by SLI Vault. It contains your saved links,
metadata, and image files in their original form. Please keep this archive safe
and private, and do not upload it to untrusted services.

Product: SLI Vault (com.sahayasavari.slivault)
