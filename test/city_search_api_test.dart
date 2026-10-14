import 'dart:convert';

import 'package:cloudless_app/data/city_search_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

http.Response utf8Response(String body) =>
    http.Response.bytes(utf8.encode(body), 200);

void main() {
  group('CitySearchApi.search', () {
    test('parses area results into cities with Chinese labels', () async {
      late Uri requested;
      final api = CitySearchApi(
        client: MockClient((request) async {
          requested = request.url;
          return utf8Response(sampleCitySearchResponse);
        }),
      );

      final cities = await api.search('北京');

      expect(requested.queryParameters['key'], '北京');
      expect(cities, hasLength(2));

      final beijing = cities.first;
      expect(beijing.id, '101010100');
      expect(beijing.name, '北京');
      expect(beijing.longitude, closeTo(116.406992, 1e-6));
      expect(beijing.latitude, closeTo(39.904583, 1e-6));

      // Repeated province/city/district parts are collapsed.
      expect(cities[1].name, '北京，海淀');
      expect(cities[1].id, '101010200');
    });

    test('does not hit the network for a blank keyword', () async {
      final api = CitySearchApi(
        client: MockClient((request) async => fail('unexpected request')),
      );

      expect(await api.search('   '), isEmpty);
    });

    test('throws when the service answers with a non-200 status', () async {
      final api = CitySearchApi(
        client: MockClient((request) async => http.Response('boom', 500)),
      );

      await expectLater(api.search('北京'), throwsA(isA<CitySearchException>()));
    });

    test('throws when the payload is not a list', () async {
      final api = CitySearchApi(
        client: MockClient((request) async => http.Response('{}', 200)),
      );

      await expectLater(api.search('北京'), throwsA(isA<CitySearchException>()));
    });
  });
}
