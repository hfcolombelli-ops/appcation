import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

bool get downloadBytesSupported => true;

void downloadBytesAsFile(Uint8List bytes, String filename) {
  final blob = Blob([bytes.toJS].toJS);
  final url = URL.createObjectURL(blob);
  final anchor = HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}
