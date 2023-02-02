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

  testWidgets('basic async', (tester) async {
    const text = 'test';
    final root = CompositionRoot(
      compose: (builder) => builder.addAsync(
        (container) async =>
            Future<String>.delayed(const Duration(seconds: 1), () => text),
      ),
      child: const BasicAsyncWidget(),
    );
    await tester.pumpWidget(root);
    expect(find.text(text), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(text), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
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

class BasicAsyncWidget extends StatelessWidget {
  const BasicAsyncWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: FutureBuilder(
          // ignore: discarded_futures
          future: context.getAsync<String>(),
          builder: (ctx, ss) => ss.connectionState == ConnectionState.done
              ? Text(ss.data!)
              : const CircularProgressIndicator(),
        ),
      );
}
