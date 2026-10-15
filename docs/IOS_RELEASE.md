# iOS Release

## Implemented Source Configuration

- Face ID usage description is present.
- Photo library usage description is present.
- Flutter local-auth and picker dependencies are declared.
- Flutter-side share integration is isolated behind a platform channel.

## Blocked Verification

This workspace is running on Windows, so `flutter build ios --simulator` and device testing were not run. A production iOS release still requires macOS/Xcode, a verified bundle identifier, signing team/profiles, simulator/device builds, permission testing, biometric testing, and a separately configured Share Extension target if inbound sharing outside the app is required.

No iOS release readiness claim is made until those checks pass.
