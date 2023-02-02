import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ioc_container/ioc_container.dart';

void main() {
  testWidgets('basic compose', (tester) async {
    const text = 'test';
    final root = CompositionRoot(
      compose: (builder) => builder.add((container) => text),
      child: const BasicWidget(),
    );
    await tester.pumpWidget(root);
    expect(find.text(text), findsOneWidget);
  });

  testWidgets('basic container', (tester) async {
    const text = 'test';
    final root = CompositionRoot(
      container:
          (IocContainerBuilder()..add((container) => text)).toContainer(),
      child: const BasicWidget(),
    );
    await tester.pumpWidget(root);
    expect(find.text(text), findsOneWidget);
  });
}

class BasicWidget extends StatelessWidget {
  const BasicWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Text(context<String>()),
      );
}
