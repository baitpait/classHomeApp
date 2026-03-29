import 'package:flutter_test/flutter_test.dart';
import 'package:hexacom_user/helper/google_maps_location_helper.dart';

void main() {
  group('parseGoogleMapsUrlToPoint', () {
    test('parses @lat,lng,zoom z', () {
      final p = parseGoogleMapsUrlToPoint(
        'https://www.google.com/maps/place/Foo/@31.95,35.90,17z/data=!3m1',
      );
      expect(p, isNotNull);
      expect(p!.latitude, 31.95);
      expect(p.longitude, 35.90);
      expect(p.zoom, 17.0);
    });

    test('parses @lat,lng without zoom (defaults to 15)', () {
      final p = parseGoogleMapsUrlToPoint(
        'https://www.google.com/maps/@48.8584,2.2945',
      );
      expect(p, isNotNull);
      expect(p!.latitude, closeTo(48.8584, 0.0001));
      expect(p.longitude, closeTo(2.2945, 0.0001));
      expect(p.zoom, 15.0);
    });

    test('parses !3d !4d segment', () {
      final p = parseGoogleMapsUrlToPoint(
        'https://www.google.com/maps/place/x/data=!3m1!4m1!3d25.2048!4d55.2708',
      );
      expect(p, isNotNull);
      expect(p!.latitude, closeTo(25.2048, 0.0001));
      expect(p.longitude, closeTo(55.2708, 0.0001));
    });

    test('parses q=lat,lng query', () {
      final p = parseGoogleMapsUrlToPoint('https://maps.google.com/?q=33.5,44.6');
      expect(p, isNotNull);
      expect(p!.latitude, 33.5);
      expect(p.longitude, 44.6);
    });

    test('returns null for empty and short links', () {
      expect(parseGoogleMapsUrlToPoint(null), isNull);
      expect(parseGoogleMapsUrlToPoint(''), isNull);
      expect(parseGoogleMapsUrlToPoint('   '), isNull);
      expect(parseGoogleMapsUrlToPoint('https://maps.app.goo.gl/abc'), isNull);
    });
  });

  group('pickStoreGoogleMapsUrl', () {
    test('returns first non-empty', () {
      expect(pickStoreGoogleMapsUrl(' https://a ', null), 'https://a');
      expect(pickStoreGoogleMapsUrl('', 'https://b'), 'https://b');
      expect(pickStoreGoogleMapsUrl(null, null), isNull);
    });
  });
}
