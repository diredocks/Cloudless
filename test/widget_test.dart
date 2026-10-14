import 'dart:async';

import 'package:cloudless_app/data/settings_store.dart';
import 'package:cloudless_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

class _MemorySettingsStore implements SettingsStore {
  _MemorySettingsStore([this._apiKey]);

  String? _apiKey;

  @override
  String? get apiKey => _apiKey;

  @override
  Future<void> setApiKey(String value) async => _apiKey = value;
}

void main() {
  MockClient okClient() => MockClient(
        (request) async => http.Response(sampleWeatherResponse, 200),
      );

  Widget appWith(SettingsStore store, {http.Client? client}) => CloudlessApp(
        store: store,
        client: client ?? okClient(),
      );

  Widget app({String? apiKey, http.Client? client}) =>
      appWith(_MemorySettingsStore(apiKey), client: client);

  testWidgets('renders the current weather fetched from the API',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(apiKey: 'test-key'));
    await tester.pumpAndSettle();

    expect(find.text('malaga, spain'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(
      find.text('Over the next two hours, no rain is expected'),
      findsOneWidget,
    );
  });

  testWidgets('can switch to the weekly tab', (WidgetTester tester) async {
    await tester.pumpWidget(app(apiKey: 'test-key'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('weekly'));
    await tester.pumpAndSettle();

    expect(find.text('mostly sunny for the next 7 days'), findsOneWidget);
    expect(find.text('wednesday'), findsOneWidget);
  });

  testWidgets('switching city from search returns to today',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(apiKey: 'test-key'));
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
    await tester.pumpWidget(app(apiKey: 'test-key', client: pending));
    await tester.pump();

    expect(find.text('loading weather\u2026'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows a retry action when the request fails',
      (WidgetTester tester) async {
    final failing = MockClient((request) async => http.Response('boom', 500));
    await tester.pumpWidget(app(apiKey: 'test-key', client: failing));
    await tester.pumpAndSettle();

    expect(find.text('try again'), findsOneWidget);
    expect(find.text('the weather service returned 500'), findsOneWidget);
  });

  testWidgets('asks for an API key on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(apiKey: null));
    await tester.pumpAndSettle();

    expect(find.text('set a valid API key to continue'), findsOneWidget);
    expect(find.text('malaga, spain'), findsNothing);
  });

  testWidgets('entering a valid key on first launch opens the app',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(apiKey: null));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'test-key');
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(find.text('malaga, spain'), findsOneWidget);
  });

  testWidgets('tapping settings shows a hint, long press opens settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(apiKey: 'test-key'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    expect(find.text('long press to open settings'), findsOneWidget);

    await tester.longPress(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('API key'), findsOneWidget);

    // Let the hint SnackBar time out so no timer outlives the test.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('saving a new key from settings persists it',
      (WidgetTester tester) async {
    final store = _MemorySettingsStore('old-key');
    await tester.pumpWidget(appWith(store));
    await tester.pumpAndSettle();

    await tester.longPress(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'new-key');
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(store.apiKey, 'new-key');
    expect(find.text('malaga, spain'), findsOneWidget);
  });
}
