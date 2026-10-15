import 'dart:convert';

import 'package:cloudless_app/data/caiyun_api.dart';
import 'package:cloudless_app/data/skycon_catalog.dart';
import 'package:cloudless_app/l10n/app_localizations.dart';
import 'package:cloudless_app/l10n/weather_l10n.dart';
import 'package:cloudless_app/theme/weather_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';
import 'helpers.dart';

void main() {
  group('CaiyunMapper', () {
    final bundle = CaiyunMapper.toBundle(
      beijingCity,
      (jsonDecode(sampleWeatherResponse) as Map<String, dynamic>)['result']
          as Map<String, dynamic>,
    );

    test('maps the realtime block into the current weather', () {
      final current = bundle.current;
      expect(current.city.name, '北京');
      expect(current.temperature, 24);
      expect(current.skycon, 'CLEAR_DAY');
      expect(
        current.apiSummary,
        'Over the next two hours, no rain is expected',
      );
      expect(current.feelsLike, 23);
      expect(current.comfortDesc, 'Pleasant');
      expect(current.windSpeed, 17);
      expect(current.uvIndex, 5);
      expect(current.uvDesc, 'Moderate');
      expect(current.rainProbability, 10);
      expect(current.rainIntensity, 0.0);
      expect(current.palette, WeatherPalette.sunny);
    });

    test('maps the daily block into the weekly forecast', () {
      final weekly = bundle.weekly;
      expect(weekly.city.name, '北京');
      expect(weekly.days, hasLength(7));
      expect(weekly.days.first.date, '2026-10-14T00:00+02:00');
      expect(weekly.days.first.skycon, 'CLEAR_DAY');
      expect(weekly.days.first.temperature, 25);
      expect(weekly.dominantSkycon, 'CLEAR_DAY');
    });

    test('maps the hourly block into the hourly forecast', () {
      final hourly = bundle.hourly;
      expect(hourly.city.name, '北京');
      expect(hourly.hours, hasLength(4));
      expect(hourly.hours.first.datetime, '2026-10-14T21:00+02:00');
      expect(hourly.hours.first.skycon, 'CLEAR_DAY');
      expect(hourly.hours.first.temperature, 25);
      expect(hourly.hours.first.rainProbability, 10);
      expect(hourly.dominantSkycon, 'CLEAR_DAY');
    });
  });

  group('CaiyunApi.fetch', () {
    test(
      'builds a request from the city coordinates and maps the response',
      () async {
        late Uri requested;
        final api = CaiyunApi(
          token: 'test-token',
          client: MockClient((request) async {
            requested = request.url;
            return http.Response(sampleWeatherResponse, 200);
          }),
        );

        final bundle = await api.fetch(beijingCity);

        expect(
          requested.path,
          contains('/v2.6/test-token/116.407526,39.90403/weather'),
        );
        expect(requested.queryParameters['lang'], 'en_US');
        expect(bundle.current.temperature, 24);
      },
    );

    test('requests the configured language', () async {
      late Uri requested;
      final api = CaiyunApi(
        token: 'test-token',
        language: 'zh_CN',
        client: MockClient((request) async {
          requested = request.url;
          return http.Response(sampleWeatherResponse, 200);
        }),
      );

      await api.fetch(beijingCity);

      expect(requested.queryParameters['lang'], 'zh_CN');
    });

    test('throws when the service answers with a non-200 status', () async {
      final api = CaiyunApi(
        token: 'test-token',
        client: MockClient((request) async => http.Response('boom', 500)),
      );

      await expectLater(
        api.fetch(beijingCity),
        throwsA(
          isA<WeatherApiException>()
              .having((e) => e.kind, 'kind', WeatherErrorKind.badStatus)
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('throws when the payload reports an error', () async {
      final api = CaiyunApi(
        token: 'test-token',
        client: MockClient(
          (request) async => http.Response(
            '{"status":"failed","error":"token is invalid"}',
            200,
          ),
        ),
      );

      await expectLater(
        api.fetch(beijingCity),
        throwsA(
          isA<WeatherApiException>()
              .having((e) => e.kind, 'kind', WeatherErrorKind.serviceError)
              .having((e) => e.detail, 'detail', 'token is invalid'),
        ),
      );
    });
  });

  group('WeatherLocalizations', () {
    late AppLocalizations en;
    late AppLocalizations zh;

    setUpAll(() async {
      en = await AppLocalizations.delegate.load(const Locale('en'));
      zh = await AppLocalizations.delegate.load(const Locale('zh'));
    });

    test('localizes sky condition labels', () {
      expect(en.skyconLabel('LIGHT_RAIN'), 'light rain');
      expect(en.skyconLabel('WHATEVER'), 'clear');
      expect(zh.skyconLabel('LIGHT_RAIN'), '小雨');
      expect(zh.skyconLabel('CLOUDY'), '阴');
    });

    test('buckets wind speed', () {
      expect(en.windLabel(1), 'calm');
      expect(en.windLabel(12), 'breezy');
      expect(en.windLabel(30), 'windy');
      expect(en.windLabel(60), 'strong');
      expect(zh.windLabel(30), '有风');
    });

    test('derives weekday names from ISO-8601 strings', () {
      expect(en.weekdayName('2026-10-14T00:00+02:00'), 'wednesday');
      expect(en.weekdayName('2026-10-18T00:00+02:00'), 'sunday');
      expect(en.weekdayName('bogus'), '');
      expect(zh.weekdayName('2026-10-14T00:00+02:00'), '周三');
    });

    test('building the weekly summary from the dominant condition', () {
      expect(
        en.weeklyForecastSummary('CLEAR_DAY'),
        'mostly sunny for the next 7 days',
      );
      expect(zh.weeklyForecastSummary('CLEAR_DAY'), '未来 7 天以晴为主');
    });

    test('building the hourly summary from the dominant condition', () {
      expect(
        en.hourlyForecastSummary('CLEAR_DAY'),
        'mostly sunny for the next 24 hours',
      );
      expect(zh.hourlyForecastSummary('CLEAR_DAY'), '未来 24 小时以晴为主');
    });

    test('formats hourly timestamps as 12- or 24-hour clocks', () {
      expect(en.hourLabel('2026-10-14T15:00+02:00', use24Hour: false), '3 pm');
      expect(en.hourLabel('2026-10-14T00:00+02:00', use24Hour: false), '12 am');
      expect(en.hourLabel('2026-10-14T12:00+02:00', use24Hour: false), '12 pm');
      expect(en.hourLabel('2026-10-14T09:00+02:00', use24Hour: false), '9 am');
      expect(en.hourLabel('2026-10-14T15:00+02:00', use24Hour: true), '15:00');
      expect(zh.hourLabel('2026-10-14T15:00+02:00', use24Hour: true), '15 时');
      expect(
        zh.hourLabel('2026-10-14T15:00+02:00', use24Hour: false),
        '下午 3 时',
      );
      expect(en.hourLabel('bogus', use24Hour: false), '');
    });

    test('localizes city names', () {
      expect(en.cityName(beijingCity), '北京');
      expect(zh.cityName(beijingCity), '北京');
    });
  });

  group('skyconFor', () {
    test('handles known and unknown codes', () {
      expect(skyconFor('CLOUDY').palette, WeatherPalette.cloudy);
      expect(skyconFor('CLEAR_NIGHT').palette, WeatherPalette.clearNight);
      expect(skyconFor('WHATEVER').palette, WeatherPalette.sky);
    });

    test('gives every condition its own palette', () {
      final codes = skyconCatalog.map((s) => s.code).toList();
      final palettes = skyconCatalog.map((s) => s.palette).toSet();
      expect(codes.toSet(), hasLength(codes.length));
      expect(palettes, hasLength(codes.length));
    });
  });
}
