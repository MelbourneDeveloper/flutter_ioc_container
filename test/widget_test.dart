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

    //No text yet
    expect(find.text(text), findsNothing);

    //Wait for 100 milliseconds
    await tester.pump(const Duration(milliseconds: 100));

    //Should see spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //Wait 2 seconds
    await tester.pump(const Duration(seconds: 2));

    //Should see text
    expect(find.text(text), findsOneWidget);

    //Should not see spinner
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('basic scoping', (tester) async {
    final root = CompositionRoot(
      container: (IocContainerBuilder()
            ..add(
              (container) => A(),
            )
            ..add(
              (container) => B(),
            )
            ..add(
              (container) => C(
                container<B>(),
                container<B>(),
              ),
            ))
          .toContainer(),
      child: const BasicWidgetWithScope(),
    );
    await tester.pumpWidget(root);
    final state = tester
        .state<_BasicWidgetWithScopeState>(find.byType(BasicWidgetWithScope));
    expect(identical(state.one, state.two), isTrue);
    expect(identical(state.c.b1, state.c.b2), isTrue);
  });
}

class A {}

class B {}

class C {
  C(
    this.b1,
    this.b2,
  );

  final B b1;
  final B b2;
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

class BasicWidgetWithScope extends StatefulWidget {
  const BasicWidgetWithScope({
    super.key,
  });

  @override
  State<BasicWidgetWithScope> createState() => _BasicWidgetWithScopeState();
}

class _BasicWidgetWithScopeState extends State<BasicWidgetWithScope> {
  late final A one, two;
  late final C c;

  @override
  void didChangeDependencies() {
    final scope = context.scoped();
    one = scope<A>();
    two = scope<A>();
    c = context.getScoped<C>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Text('Hi'),
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
