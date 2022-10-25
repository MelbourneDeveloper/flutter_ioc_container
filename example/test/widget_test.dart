import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDisposableService implements DisposableService {
  bool isDisposed = false;

  @override
  void dispose() => isDisposed = true;

  @override
  String get counterLabel => 'asdasd';
}

void main() {
  testWidgets('Counter increments smoke test', (tester) async {
    final builder = compose(allowOverrides: true)
      ..add<DisposableService>(
        (container) => FakeDisposableService(),
        dispose: (service) => service.dispose(),
      );

    final compositionWidget = ContainerWidget(
      container: builder.toContainer(),
      child: const AppRoot(),
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(compositionWidget);
    await tester.pumpAndSettle();

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    final scopeState = tester
        .state<ScopedContainerWidgetState>(find.byType(ScopedContainerWidget));

    final disposable =
        scopeState.scope.get<DisposableService>() as FakeDisposableService;

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(disposable.isDisposed, true);
  });
}
