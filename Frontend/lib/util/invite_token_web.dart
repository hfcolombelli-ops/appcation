import 'dart:html' as html;

String? readInviteTokenFromLaunchUri() {
  final href = html.window.location.href;
  final uri = Uri.parse(href);
  final q = uri.queryParameters['token'];
  if (q != null && q.trim().isNotEmpty) {
    return q.trim();
  }
  final frag = uri.fragment;
  if (frag.contains('token=')) {
    final i = frag.indexOf('token=');
    final rest = frag.substring(i + 6);
    final amp = rest.indexOf('&');
    return (amp >= 0 ? rest.substring(0, amp) : rest).trim();
  }
  return null;
}
