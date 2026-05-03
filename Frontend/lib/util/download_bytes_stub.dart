import 'dart:async';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';

bool get downloadBytesSupported => true;

MimeType _mimeForExtension(String ext) {
  switch (ext.toLowerCase()) {
    case 'pdf':
      return MimeType.pdf;
    case 'csv':
      return MimeType.csv;
    case 'png':
      return MimeType.png;
    case 'jpg':
    case 'jpeg':
      return MimeType.jpeg;
    case 'webp':
      return MimeType.webp;
    default:
      return MimeType.other;
  }
}

void downloadBytesAsFile(Uint8List bytes, String filename) {
  unawaited(_saveBytes(bytes, filename));
}

Future<void> _saveBytes(Uint8List bytes, String filename) async {
  final dot = filename.lastIndexOf('.');
  final String base;
  final String ext;
  if (dot > 0 && dot < filename.length - 1) {
    base = filename.substring(0, dot);
    ext = filename.substring(dot + 1);
  } else {
    base = filename;
    ext = 'bin';
  }
  try {
    await FileSaver.instance.saveFile(
      name: base,
      bytes: bytes,
      fileExtension: ext,
      mimeType: _mimeForExtension(ext),
    );
  } catch (e, st) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: e,
        stack: st,
        library: 'util/download_bytes_stub.dart',
        context: ErrorDescription('while saving downloaded bytes as "$filename"'),
      ),
    );
  }
}
