# iOS Release

## Implemented Source Configuration

- Face ID usage description is present.
- Photo library usage description is present.
- Flutter local-auth and picker dependencies are declared.
- Flutter-side share integration is isolated behind a platform channel.

## Blocked Verification

This workspace is running on Windows, so `flutter build ios --simulator` and device testing were not run. A production iOS release still requires macOS/Xcode, a verified bundle identifier, signing team/profiles, simulator/device builds, permission testing, biometric testing, and a separately configured Share Extension target if inbound sharing outside the app is required.

No iOS release readiness claim is made until those checks pass.

## Phase 2 roadmap (documentation only)

Not started in this Android-first release track:

1. macOS/Xcode host and CI for iOS builds
2. Final iOS bundle identifier (aligned with Android branding, not a template ID)
3. Apple Developer signing (development + distribution profiles)
4. Simulator and physical-device QA (onboarding, library CRUD, biometrics, backup)
5. Optional iOS Share Extension target for inbound share (separate from Flutter platform channel stubs)
6. App Store / TestFlight packaging only after Android sideload track is stable and font redistribution is cleared

Do not treat Flutter `ios/` scaffold presence as shipping readiness.
