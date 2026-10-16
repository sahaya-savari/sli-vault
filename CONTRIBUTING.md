# Contributing

Thanks for looking at SLI Vault. Project-owned code and documentation are under the [MIT License](LICENSE). Third-party assets (for example Anthropic Serif) remain separately licensed — see [assets/fonts/claude/README.md](assets/fonts/claude/README.md).

## Local checks

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

On PowerShell, quote test name filters that contain `|`.

### Website (`website/`)

Install and run checks only inside `website/` (see [docs/WEBSITE_SETUP.md](docs/WEBSITE_SETUP.md)):

```powershell
cd website
bun install
bun run lint
bun run test
bun run build
```

Do not run `bun install` or `npm install` at the repository root.

## What not to change without an explicit owner decision

- Application ID `com.sahayasavari.slivault`
- Release signing (local `android/key.properties` + owner keystore; never commit secrets)
- `FLAG_SECURE` behavior in `MainActivity.kt` (enabled via `applySecureFlag()` in `onCreate` / `onResume`)
- `kotlin.incremental=false` in `android/gradle.properties`
- Bundled fonts and the approved launcher artwork

Do not commit keystores, `key.properties`, `.env` files, `local.properties`, vault databases, backup ZIPs, or files under `build/`, `.dart_tool/`, or `artifacts/`.

## Reports

Use the issue templates. Do not attach a vault database, backup archive, or screenshot of private library contents.
