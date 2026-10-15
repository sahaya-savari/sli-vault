# Contributing

Thanks for looking at SLI Vault. A project license has not been chosen, and there is no `LICENSE` file. Do not assume contributions are under MIT, Apache-2.0, or any other license until the owner adds one. Please ask before sending a large patch.

## Local checks

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

On PowerShell, quote test name filters that contain `|`.

## What not to change without an explicit owner decision

- Application ID `com.example.sli_vault`
- Release signing (`android/app/build.gradle.kts` still uses the debug config)
- `FLAG_SECURE` in `MainActivity.kt` (the owner paused it; the `addFlags` call stays commented)
- `kotlin.incremental=false` in `android/gradle.properties`
- Bundled fonts and the approved launcher artwork

Do not commit keystores, `key.properties`, `.env` files, `local.properties`, vault databases, backup ZIPs, or files under `build/`, `.dart_tool/`, or `artifacts/`.

## Reports

Use the issue templates. Do not attach a vault database, backup archive, or screenshot of private library contents.
