import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockValueNotifier extends CounterController {
  MockValueNotifier() : super();

  bool hasCalls = false;

  @override
  void increment() {
    hasCalls = true;
    value++;
  }
}

void main() {
  testWidgets('Basic Smoke Test', (tester) async {
    final mockValueNotifier = MockValueNotifier();

    await tester.pumpWidget(
      MyApp(
        //This is how you substitute dependencies with test doubles
        configureOverrides: (builder) => builder
            .addSingleton<CounterController>((container) => mockValueNotifier),
      ),
    );

    //Initial value
    expect(find.text('0'), findsOneWidget);

    //Tap the button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    //Verify value
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);

    //Ensure we're using the mock dependency
    expect(mockValueNotifier.hasCalls, isTrue);
  });
}
