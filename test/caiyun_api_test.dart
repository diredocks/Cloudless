import 'dart:convert';

import 'package:cloudless_app/data/caiyun_api.dart';
import 'package:cloudless_app/models/weather.dart';
import 'package:cloudless_app/theme/weather_palette.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

const _malaga = CityLocation(
  id: 'malaga',
  name: 'malaga, spain',
  longitude: -4.4214,
  latitude: 36.7213,
);

void main() {
  group('CaiyunMapper', () {
    final bundle = CaiyunMapper.toBundle(
      _malaga,
      (jsonDecode(sampleWeatherResponse) as Map<String, dynamic>)['result']
          as Map<String, dynamic>,
    );

    test('maps the realtime block into the current weather', () {
      final current = bundle.current;
      expect(current.location, 'malaga, spain');
      expect(current.temperature, 24);
      expect(current.summary, 'Over the next two hours, no rain is expected');
      expect(current.feelsLikeValue, '23\u00B0');
      expect(current.feelsLikeLabel, 'pleasant');
      expect(current.windValue, '17 km/h');
      expect(current.windLabel, 'breezy');
      expect(current.uvValue, '5');
      expect(current.uvLabel, 'moderate');
      expect(current.rainValue, '10%');
      expect(current.rainLabel, 'dry');
      expect(current.palette, WeatherPalette.orange);
    });

    test('maps the daily block into the weekly forecast', () {
      final weekly = bundle.weekly;
      expect(weekly.location, 'malaga, spain');
      expect(weekly.days, hasLength(7));
      expect(weekly.days.first.day, 'wednesday');
      expect(weekly.days.first.condition, 'sunny');
      expect(weekly.days.first.temperature, 25);
      expect(weekly.summary, 'mostly sunny for the next 7 days');
    });
  });

  group('CaiyunApi.fetch', () {
    test('builds a request from the city coordinates and maps the response',
        () async {
      late Uri requested;
      final api = CaiyunApi(
        client: MockClient((request) async {
          requested = request.url;
          return http.Response(sampleWeatherResponse, 200);
        }),
      );

      final bundle = await api.fetch(_malaga);

      expect(
        requested.path,
        contains('/v2.6/${CaiyunApi.token}/-4.4214,36.7213/weather'),
      );
      expect(requested.queryParameters['lang'], 'en_US');
      expect(bundle.current.temperature, 24);
    });

    test('throws when the service answers with a non-200 status', () async {
      final api = CaiyunApi(
        client: MockClient((request) async => http.Response('boom', 500)),
      );

      await expectLater(
        api.fetch(_malaga),
        throwsA(isA<WeatherApiException>()),
      );
    });

    test('throws when the payload reports an error', () async {
      final api = CaiyunApi(
        client: MockClient(
          (request) async => http.Response(
            '{"status":"failed","error":"token is invalid"}',
            200,
          ),
        ),
      );

      await expectLater(
        api.fetch(_malaga),
        throwsA(
          isA<WeatherApiException>().having(
            (e) => e.message,
            'message',
            'token is invalid',
          ),
        ),
      );
    });
  });

  group('helpers', () {
    test('weekdayName uses the date portion of an ISO-8601 string', () {
      expect(CaiyunMapper.weekdayName('2026-10-14T00:00+02:00'), 'wednesday');
      expect(CaiyunMapper.weekdayName('2026-10-18T00:00+02:00'), 'sunday');
      expect(CaiyunMapper.weekdayName('bogus'), '');
    });

    test('windLabel buckets by km/h', () {
      expect(CaiyunMapper.windLabel(1), 'calm');
      expect(CaiyunMapper.windLabel(12), 'breezy');
      expect(CaiyunMapper.windLabel(30), 'windy');
      expect(CaiyunMapper.windLabel(60), 'strong');
    });

    test('skyconText and paletteFor handle known and unknown codes', () {
      expect(CaiyunMapper.skyconText('LIGHT_RAIN'), 'light rain');
      expect(CaiyunMapper.skyconText('WHATEVER'), 'clear');
      expect(CaiyunMapper.paletteFor('CLOUDY'), WeatherPalette.blue);
      expect(CaiyunMapper.paletteFor('CLEAR_NIGHT'), WeatherPalette.navy);
    });
  });
}
