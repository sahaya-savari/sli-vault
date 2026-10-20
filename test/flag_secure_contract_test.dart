import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level contract: production Android builds must permit screenshots normally.
/// FLAG_SECURE is explicitly cleared and not added to window flags.
void main() {
  test('MainActivity removes screenshot-blocking FLAG_SECURE', () {
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
    // Must NOT add FLAG_SECURE
    expect(
      source.contains(
        'window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)',
      ),
      isFalse,
    );
  });
}
