import 'package:flutter_test/flutter_test.dart';
import 'package:sli_vault/core/platform/document_path.dart';

void main() {
  group('isDocumentProviderPath', () {
    test('flags historical /document/<id> SAF paths', () {
      expect(isDocumentProviderPath('/document/1770'), isTrue);
      expect(isDocumentProviderPath('/document/primary:Download/backup.zip'),
          isTrue);
      expect(isDocumentProviderPath('/document'), isTrue);
    });

    test('flags content and file URIs', () {
      expect(
        isDocumentProviderPath(
          'content://com.android.providers.downloads.documents/document/1770',
        ),
        isTrue,
      );
      expect(
        isDocumentProviderPath('file:///storage/emulated/0/Download/a.zip'),
        isTrue,
      );
    });

    test('allows ordinary filesystem paths', () {
      expect(
        isDocumentProviderPath(r'C:\Users\test\Downloads\backup.zip'),
        isFalse,
      );
      expect(
        isFilesystemPathSafeForDartIo('/tmp/sli-vault-backup.zip'),
        isTrue,
      );
      expect(
        isFilesystemPathSafeForDartIo(
          '/data/user/0/com.sahayasavari.slivault/cache/backup.zip',
        ),
        isTrue,
      );
      expect(
        isFilesystemPathSafeForDartIo('/storage/emulated/0/Download/a.zip'),
        isTrue,
      );
    });

    test('empty path is not safe for dart:io File', () {
      expect(isFilesystemPathSafeForDartIo(''), isFalse);
      expect(isFilesystemPathSafeForDartIo('   '), isFalse);
    });
  });
}
