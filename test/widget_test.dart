import 'package:flutter_test/flutter_test.dart';

import 'package:cloudless_app/main.dart';

void main() {
  testWidgets('renders the current weather for the first city',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CloudlessApp());

    expect(find.text('malaga, spain'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('it\u2019s sunny, remember the sunscreen'), findsOneWidget);
  });

  testWidgets('can switch to the weekly tab', (WidgetTester tester) async {
    await tester.pumpWidget(const CloudlessApp());

    await tester.tap(find.text('weekly'));
    await tester.pumpAndSettle();

    expect(find.text('it stays hot for the next 7 days'), findsOneWidget);
    expect(find.text('monday'), findsOneWidget);
  });
}
