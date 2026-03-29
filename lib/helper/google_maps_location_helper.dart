/// Parses Google Maps share / place URLs so the app can show an OSM preview (same idea as Laravel Helpers).
class GoogleMapsParsedPoint {
  final double latitude;
  final double longitude;
  final double zoom;

  const GoogleMapsParsedPoint({
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
  });
}

bool _isValidLatLng(double lat, double lng) =>
    lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;

final RegExp _atLatLngZoom = RegExp(
  r'@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)(?:,(\d+(?:\.\d+)?)z)?',
  caseSensitive: false,
);

GoogleMapsParsedPoint? _pointFromAtMatch(RegExpMatch atMatch) {
  final lat = double.tryParse(atMatch.group(1)!);
  final lng = double.tryParse(atMatch.group(2)!);
  final zStr = atMatch.group(3);
  if (lat == null || lng == null || !_isValidLatLng(lat, lng)) return null;
  final z = zStr != null ? double.tryParse(zStr) : null;
  final zoom = (z ?? 15).clamp(1.0, 21.0);
  return GoogleMapsParsedPoint(latitude: lat, longitude: lng, zoom: zoom);
}

/// Returns a point when the URL contains extractable coordinates (e.g. `@lat,lng,17z`, `!3d…!4d…`, or `q=` / `ll=`).
GoogleMapsParsedPoint? parseGoogleMapsUrlToPoint(String? raw) {
  if (raw == null) return null;
  final url = raw.trim();
  if (url.isEmpty) return null;

  final atMatch = _atLatLngZoom.firstMatch(url);
  if (atMatch != null) {
    final p = _pointFromAtMatch(atMatch);
    if (p != null) return p;
  }

  final dMatch = RegExp(
    r'!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)',
    caseSensitive: false,
  ).firstMatch(url);
  if (dMatch != null) {
    final lat = double.tryParse(dMatch.group(1)!);
    final lng = double.tryParse(dMatch.group(2)!);
    if (lat != null && lng != null && _isValidLatLng(lat, lng)) {
      return GoogleMapsParsedPoint(latitude: lat, longitude: lng, zoom: 15);
    }
  }

  final uri = Uri.tryParse(url) ?? Uri.tryParse('https://$url');
  if (uri != null) {
    for (final key in ['q', 'll']) {
      final param = uri.queryParameters[key];
      if (param == null || param.isEmpty) continue;
      final decoded = Uri.decodeComponent(param);
      final coord = _parseCommaSeparatedLatLng(decoded);
      if (coord != null) return coord;
    }
  }

  return null;
}

GoogleMapsParsedPoint? _parseCommaSeparatedLatLng(String value) {
  final v = value.trim();
  final nestedAt = _atLatLngZoom.firstMatch(v);
  if (nestedAt != null) {
    final p = _pointFromAtMatch(nestedAt);
    if (p != null) return p;
  }
  final parts = v.split(',');
  if (parts.length < 2) return null;
  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  if (lat == null || lng == null || !_isValidLatLng(lat, lng)) return null;
  return GoogleMapsParsedPoint(latitude: lat, longitude: lng, zoom: 15);
}

/// First non-empty trimmed URL (store field and API alias are often identical).
String? pickStoreGoogleMapsUrl(String? a, String? b) {
  for (final s in [a, b]) {
    if (s != null && s.trim().isNotEmpty) return s.trim();
  }
  return null;
}
