import 'dart:async';

import 'package:cloudless_app/data/caiyun_api.dart';
import 'package:cloudless_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

void main() {
  MockClient okClient() => MockClient(
        (request) async => http.Response(sampleWeatherResponse, 200),
      );

  testWidgets('renders the current weather fetched from the API',
      (WidgetTester tester) async {
    await tester.pumpWidget(CloudlessApp(api: CaiyunApi(client: okClient())));
    await tester.pumpAndSettle();

    expect(find.text('malaga, spain'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(
      find.text('Over the next two hours, no rain is expected'),
      findsOneWidget,
    );
  });

  testWidgets('can switch to the weekly tab', (WidgetTester tester) async {
    await tester.pumpWidget(CloudlessApp(api: CaiyunApi(client: okClient())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('weekly'));
    await tester.pumpAndSettle();

    expect(find.text('mostly sunny for the next 7 days'), findsOneWidget);
    expect(find.text('wednesday'), findsOneWidget);
  });

  testWidgets('switching city from search returns to today',
      (WidgetTester tester) async {
    await tester.pumpWidget(CloudlessApp(api: CaiyunApi(client: okClient())));
    await tester.pumpAndSettle();

    await tester.tap(find.text('search'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('london, uk'));
    await tester.pumpAndSettle();

    expect(find.text('london, uk'), findsOneWidget);
    expect(find.text('malaga, spain'), findsNothing);
  });

  testWidgets('shows a spinner while the request is in flight',
      (WidgetTester tester) async {
    final pending = MockClient((request) => Completer<http.Response>().future);
    await tester.pumpWidget(CloudlessApp(api: CaiyunApi(client: pending)));
    await tester.pump();

    expect(find.text('loading weather\u2026'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a retry action when the request fails',
      (WidgetTester tester) async {
    final failing = MockClient(
      (request) async => http.Response('boom', 500),
    );
    await tester.pumpWidget(CloudlessApp(api: CaiyunApi(client: failing)));
    await tester.pumpAndSettle();

    expect(find.text('try again'), findsOneWidget);
    expect(find.text('the weather service returned 500'), findsOneWidget);
  });
}
