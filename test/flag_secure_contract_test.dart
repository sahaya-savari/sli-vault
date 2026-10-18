import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-level contract: production Android builds must keep FLAG_SECURE on.
/// Physical-device screenshot / recents behavior is NOT covered here.
void main() {
  test('MainActivity enables FLAG_SECURE in onCreate and onResume', () {
    final file = File(
      'android/app/src/main/kotlin/com/sahayasavari/slivault/MainActivity.kt',
    );
    expect(file.existsSync(), isTrue);
    final source = file.readAsStringSync();
    expect(source.contains('WindowManager.LayoutParams.FLAG_SECURE'), isTrue);
    expect(source.contains('applySecureFlag()'), isTrue);
    expect(source.contains('override fun onResume()'), isTrue);
    // Must not leave the enable call commented out.
    expect(
      RegExp(
        r'^\s*//\s*window\.addFlags\(WindowManager\.LayoutParams\.FLAG_SECURE\)',
        multiLine: true,
      ).hasMatch(source),
      isFalse,
    );
    expect(
      source.contains(
        'window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)',
      ),
      isTrue,
    );
  });
}
