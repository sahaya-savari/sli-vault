# Local encrypted signing backup

This folder holds **machine-local** encrypted copies of the Android release keystore and `key.properties`. Sensitive files here must never be committed.

Tracked in Git (safe):

- `.gitignore`
- `.ignore`
- this `README.md`

Not tracked (local only):

- `*.enc`
- any plaintext `*.jks` / `key.properties` copies

## Encrypt

Requires Git for Windows OpenSSL. You will be prompted for a passphrase; use one you already know (for example the keystore store password). Do not paste passwords into committed files.

```powershell
$openssl = "C:\Program Files\Git\usr\bin\openssl.exe"
& $openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt `
  -in "$env:USERPROFILE\keystores\sli-vault-release.jks" `
  -out android\secrets\sli-vault-release.jks.enc
& $openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt `
  -in android\key.properties `
  -out android\secrets\key.properties.enc
```

## Decrypt / restore

```powershell
$openssl = "C:\Program Files\Git\usr\bin\openssl.exe"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\keystores" | Out-Null
& $openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 `
  -in android\secrets\sli-vault-release.jks.enc `
  -out "$env:USERPROFILE\keystores\sli-vault-release.jks"
& $openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 `
  -in android\secrets\key.properties.enc `
  -out android\key.properties
```

Then confirm `android/key.properties` `storeFile` points at the restored `.jks` path.

More context: [docs/ANDROID_RELEASE.md](../../docs/ANDROID_RELEASE.md).
