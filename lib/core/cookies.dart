// lib/core/cookies.dart
import 'dart:html' as html;

String? readCookie(String name) {
  final cookies = html.document.cookie;
  if (cookies == null || cookies.isEmpty) return null;
  for (final part in cookies.split(';')) {
    final kv = part.trim().split('=');
    if (kv.length == 2 && kv[0] == name) {
      return Uri.decodeComponent(kv[1]);
    }
  }
  return null;
}
