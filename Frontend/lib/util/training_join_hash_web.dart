import 'dart:html' as html;

String? readTrainingJoinHashFromLaunchUri() {
  final href = html.window.location.href;
  final uri = Uri.parse(href);
  for (final key in ['hash', 'join_hash', 'join']) {
    final v = uri.queryParameters[key];
    if (v != null && v.trim().isNotEmpty) {
      return v.trim().toLowerCase();
    }
  }
  final frag = uri.fragment;
  if (frag.contains('hash=')) {
    final i = frag.indexOf('hash=');
    final rest = frag.substring(i + 5);
    final amp = rest.indexOf('&');
    final raw = (amp >= 0 ? rest.substring(0, amp) : rest).trim();
    if (raw.isNotEmpty) {
      return raw.toLowerCase();
    }
  }
  if (frag.contains('join_hash=')) {
    final i = frag.indexOf('join_hash=');
    final rest = frag.substring(i + 10);
    final amp = rest.indexOf('&');
    final raw = (amp >= 0 ? rest.substring(0, amp) : rest).trim();
    if (raw.isNotEmpty) {
      return raw.toLowerCase();
    }
  }
  return null;
}
