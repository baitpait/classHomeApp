// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void updateFavicon(String? url) {
  if (url == null || url.trim().isEmpty) return;

  final document = html.document;
  html.LinkElement? link =
      document.querySelector("link[rel*='icon']") as html.LinkElement?;

  link ??= html.LinkElement()..rel = 'shortcut icon';

  link
    ..href = url
    ..type = 'image/png';

  if (link.parent == null) {
    document.head?.append(link);
  }
}

