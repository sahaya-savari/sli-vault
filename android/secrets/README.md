# Local signing restore (`.env`)

This folder holds **machine-local** restore info for the Android release keystore credentials. Sensitive files here must never be committed.

Tracked in Git (safe):

- `.gitignore`
- `.ignore`
- this `README.md`

Not tracked (local only):

- `.env` / `*.env` (keystore restore credentials)
- any plaintext `*.jks` / `key.properties` copies
- legacy `*.enc` (if present; prefer `.env` instead)

## Local files

Typical local files (not in Git):

- `android/secrets/.env` — env-style keys (`STORE_FILE`, `KEY_ALIAS`, `STORE_PASSWORD`, `KEY_PASSWORD`)
- `android/secrets/keystore.env` — same values using `key.properties` field names (easy copy/restore)

The keystore binary itself stays outside the repo (example: `%USERPROFILE%\keystores\sli-vault-release.jks`).

## Create / refresh from `android/key.properties`

After you have a working `android/key.properties`, mirror it into this folder (do not commit the result):

```powershell
# Example shape for android/secrets/.env (use your real values locally only)
@"
STORE_FILE=C:\\Users\\<YOU>\\keystores\\sli-vault-release.jks
KEY_ALIAS=sli-vault
STORE_PASSWORD=<STORE_PASSWORD>
KEY_PASSWORD=<KEY_PASSWORD>
"@ | Set-Content -Path android\secrets\.env -Encoding utf8

# Optional: key.properties field names for a one-step restore copy
Copy-Item android\key.properties android\secrets\keystore.env
```

## Restore → `android/key.properties`

**Option A — from `keystore.env` (same field names):**

```powershell
Copy-Item android\secrets\keystore.env android\key.properties
```

**Option B — from `.env` (map env keys):**

```powershell
# Load android/secrets/.env then write key.properties
Get-Content android\secrets\.env | ForEach-Object {
  if ($_ -match '^\s*([^#=]+)=(.*)$') { Set-Variable -Name $matches[1].Trim() -Value $matches[2] }
}
@"
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$STORE_FILE
"@ | Set-Content -Path android\key.properties -Encoding utf8
```

Then confirm `storeFile` points at your `.jks` path and that the keystore file exists.

Hard rules: never commit `.env`, `*.env`, `key.properties`, `*.jks`, or passwords. Never paste passwords into issues, chat, README, or CI logs.

More context: [docs/ANDROID_RELEASE.md](../../docs/ANDROID_RELEASE.md).
