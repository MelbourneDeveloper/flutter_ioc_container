import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    var builder = compose(allowOverrides: true)
      ..addSingletonService(
        ThemeChangeNotifier(),
      );

    final compositionWidget = ContainerWidget(
      container: builder.toContainer(),
      child: const MyApp(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(compositionWidget);

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}