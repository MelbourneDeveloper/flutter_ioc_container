import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ioc_container/ioc_container.dart';

void main() {
  ///This test shows how to use the CompositionRoot widget to provide
  ///dependencies to other widgets in your application.
  ///The dependency in this case is a text string.
  testWidgets('basic compose', (tester) async {
    const text = 'test';
    final root = CompositionRoot(
      compose: (builder) => builder.add((container) => text),
      child: const BasicWidget(),
    );
    await tester.pumpWidget(root);
    expect(find.text(text), findsOneWidget);
  });

  ///This test shows how to create an IoC Container and use it as the source
  ///of dependencies for your widgets.
  ///The dependency in this case is a text string.
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

  ///This test shows how to provide an asynchronous dependency to your widgets.
  ///The dependency in this case is a future that returns a text string.
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

  ///This test shows how to use scoped dependencies in your widgets.
  ///The scoped dependencies in this case are two instances of class A and
  ///one instance of class C, which takes two instances of class B.
  ///Each type only ever has one instance in a scope
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

class BasicAsyncWidget extends StatefulWidget {
  const BasicAsyncWidget({
    super.key,
  });

  @override
  State<BasicAsyncWidget> createState() => _BasicAsyncWidgetState();
}

class _BasicAsyncWidgetState extends State<BasicAsyncWidget> {
  late final Future<String> future;

  @override
  void didChangeDependencies() {
    // ignore: discarded_futures
    future = context.getAsync<String>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: FutureBuilder(
          // ignore: discarded_futures
          future: future,
          builder: (ctx, ss) => ss.connectionState == ConnectionState.done
              ? Text(ss.data!)
              : const CircularProgressIndicator(),
        ),
      );
}
