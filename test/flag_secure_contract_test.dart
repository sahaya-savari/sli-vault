import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level contract: Android builds provide configurable screen protection
/// via FLAG_SECURE connected to the sli_vault/security MethodChannel.
void main() {
  test('MainActivity provides dynamic, user-controlled FLAG_SECURE protection', () {
    final file = File(
      'android/app/src/main/kotlin/com/sahayasavari/slivault/MainActivity.kt',
    );
    expect(file.existsSync(), isTrue);
    final source = file.readAsStringSync();
    expect(source.contains('WindowManager.LayoutParams.FLAG_SECURE'), isTrue);
    expect(
      source.contains(
        'window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)',
      ),
      isTrue,
    );
    expect(
      source.contains(
        'window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)',
      ),
      isTrue,
    );
    expect(source.contains('sli_vault/security'), isTrue);
    expect(source.contains('setScreenProtection'), isTrue);
    expect(source.contains('isScreenProtectionEnabled'), isTrue);
  });
}
