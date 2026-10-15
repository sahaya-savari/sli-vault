import 'package:flutter/services.dart';

class IncomingShare {
  final String? text;
  final String? imagePath;

  const IncomingShare({this.text, this.imagePath});

  bool get isEmpty =>
      (text == null || text!.trim().isEmpty) && imagePath == null;
}

class PlatformShareService {
  static const _channel = MethodChannel('sli_vault/share');

  static Future<IncomingShare?> initialShare() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getInitialShare',
      );
      return _fromMap(raw);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static void listen(void Function(IncomingShare share) onShare) {
    _channel.setMethodCallHandler((call) async {
      if (call.method != 'incomingShare') return;
      final share = _fromMap(call.arguments as Map<dynamic, dynamic>?);
      if (share != null && !share.isEmpty) onShare(share);
    });
  }

  static IncomingShare? _fromMap(Map<dynamic, dynamic>? raw) {
    if (raw == null) return null;
    final text = raw['text'] as String?;
    final imagePath = raw['imagePath'] as String?;
    final share = IncomingShare(text: text, imagePath: imagePath);
    return share.isEmpty ? null : share;
  }
}
