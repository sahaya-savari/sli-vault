import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level contract: FLAG_SECURE is completely removed so users can take
/// screenshots and screen recordings without restrictions.
void main() {
  test('MainActivity permanently clears FLAG_SECURE without dynamic protection toggle', () {
    final file = File(
      'android/app/src/main/kotlin/com/sahayasavari/slivault/MainActivity.kt',
    );
    expect(file.existsSync(), isTrue);
    final source = file.readAsStringSync();

    // Must explicitly clear FLAG_SECURE
    expect(
      source.contains(
        'window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)',
      ),
      isTrue,
    );

    // Must NEVER add FLAG_SECURE
    expect(
      source.contains(
        'window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)',
      ),
      isFalse,
    );

    // MethodChannel and toggles must be completely absent
    expect(source.contains('sli_vault/security'), isFalse);
    expect(source.contains('setScreenProtection'), isFalse);
    expect(source.contains('isScreenProtectionEnabled'), isFalse);
    expect(source.contains('applyScreenProtection'), isFalse);
  });
}
