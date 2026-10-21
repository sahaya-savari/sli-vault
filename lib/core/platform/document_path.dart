/// Helpers for Android Storage Access Framework / document-provider paths.
///
/// [FilePicker] and similar APIs may return paths that are not ordinary
/// filesystem paths (for example `/document/1770` or `content://...`).
/// Treating those as `dart:io` [File] paths causes [PathNotFoundException].
library;

/// Returns true when [path] looks like a document-provider URI or virtual
/// document path that must not be opened with `dart:io` `File(path)`.
bool isDocumentProviderPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return false;

  final lower = trimmed.toLowerCase();
  if (lower.startsWith('content://')) return true;
  // Raw `file://` strings are URIs, not filesystem paths for [File].
  if (lower.startsWith('file://')) return true;

  // Virtual document ids returned by some SAF / MediaStore pickers.
  // Historical failure: PathNotFoundException for `/document/1770`.
  if (trimmed.startsWith('/document/') || trimmed == '/document') {
    return true;
  }

  return false;
}

/// Whether it is safe to open [path] with `dart:io` [File] for read/write.
bool isFilesystemPathSafeForDartIo(String path) {
  if (path.trim().isEmpty) return false;
  return !isDocumentProviderPath(path);
}
