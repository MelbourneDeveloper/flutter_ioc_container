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
    await tester.pumpWidget(
      CompositionRoot(
        compose: BuildCompose(
          (builder) => builder.add((_) => text),
        ),
        child: const BasicWidget(),
      ),
    );
    expect(find.text(text), findsOneWidget);
    expect(find.byType(BasicWidget), findsOneWidget);
  });

  ///This test shows how to create an IoC Container and use it as the source
  ///of dependencies for your widgets.
  ///The dependency in this case is a text string.
  testWidgets('basic container', (tester) async {
    const text = 'test';
    await tester.pumpWidget(
      CompositionRoot(
        compose: ContainerCompose(
          (IocContainerBuilder()..add((_) => text)).toContainer(),
        ),
        child: const BasicWidget(),
      ),
    );
    expect(find.text(text), findsOneWidget);
    expect(find.byType(BasicWidget), findsOneWidget);
  });

  ///This test shows how to provide an asynchronous dependency to your widgets.
  ///The dependency in this case is a future that returns a text string.
  testWidgets('basic async', (tester) async {
    const text = 'test';
    await tester.pumpWidget(
      CompositionRoot.configureBuild(
        const BasicAsyncWidget(),
        (builder) => builder.addAsync(
          (_) async => Future.delayed(const Duration(seconds: 1), () => text),
        ),
      ),
    );

    //No text yet
    expect(find.text(text), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    //Wait for 100 milliseconds
    await tester.pump(const Duration(milliseconds: 100));

    //Should see spinner
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(text), findsNothing);

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
    await tester.pumpWidget(
      CompositionRoot(
        compose: ContainerCompose(
          (IocContainerBuilder()
                ..add((_) => A())
                ..add((_) => B())
                ..add((container) => C(container<B>(), container<B>())))
              .toContainer(),
        ),
        child: const BasicWidgetWithScope(),
      ),
    );
    final state = tester
        .state<_BasicWidgetWithScopeState>(find.byType(BasicWidgetWithScope));
    expect(identical(state.one, state.two), isTrue);
    expect(identical(state.c.b1, state.c.b2), isTrue);
    expect(find.byType(BasicWidgetWithScope), findsOneWidget);
    expect(find.text('Hi'), findsOneWidget);
  });

  testWidgets('build compose with overrides', (tester) async {
    const text = 'override';
    await tester.pumpWidget(
      CompositionRoot(
        compose: BuildCompose(
          (b) => b.add<String>((_) => 'original'),
        ),
        configureOverrides: (builder) => builder.add<String>((_) => text),
        child: const BasicWidget(),
      ),
    );
    expect(find.text(text), findsOneWidget);
    expect(find.text('original'), findsNothing);
  });

  testWidgets('builder compose', (tester) async {
    const text = 'test';
    final iocContainerBuilder = IocContainerBuilder()..add((_) => text);
    await tester.pumpWidget(
      CompositionRoot(
        compose: BuilderCompose(iocContainerBuilder),
        child: const BasicWidget(),
      ),
    );
    expect(find.text(text), findsOneWidget);
  });

  testWidgets('basic scoping', (tester) async {
    await tester.pumpWidget(
      CompositionRoot(
        compose: ContainerCompose(
          (IocContainerBuilder()
                ..addSingleton((_) => A())
                ..addSingleton((_) => B())
                ..add((container) => C(container<B>(), container<B>())))
              .toContainer(),
        ),
        child: const BasicWidgetWithScope(),
      ),
    );

    final state = tester.state<_BasicWidgetWithScopeState>(
      find.byType(BasicWidgetWithScope),
    );
    expect(identical(state.one, state.two), isTrue);
    expect(identical(state.c.b1, state.c.b2), isTrue);

    await tester.pumpWidget(
      CompositionRoot(
        compose: ContainerCompose(
          (IocContainerBuilder()
                ..addSingleton((_) => A())
                ..addSingleton((_) => B())
                ..add((container) => C(container<B>(), container<B>())))
              .toContainer(),
        ),
        child: const BasicWidgetWithScopeNoExisting(),
      ),
    );

    final stateNoExisting = tester.state<_BasicWidgetWithScopeNoExistingState>(
      find.byType(BasicWidgetWithScopeNoExisting),
    );
    expect(identical(stateNoExisting.one, stateNoExisting.two), isTrue);
    expect(identical(stateNoExisting.c.b1, stateNoExisting.c.b2), isFalse);
  });
}

class A {}

class B {}

class C {
  const C(this.b1, this.b2);
  final B b1;
  final B b2;
}

class BasicWidget extends StatelessWidget {
  const BasicWidget({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Text(context<String>()),
      );
}

class BasicWidgetWithScope extends StatefulWidget {
  const BasicWidgetWithScope({super.key});

  @override
  State<BasicWidgetWithScope> createState() => _BasicWidgetWithScopeState();
}

class _BasicWidgetWithScopeState extends State<BasicWidgetWithScope> {
  late final A one;
  late final A two;
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
  Widget build(BuildContext context) => const MaterialApp(home: Text('Hi'));
}

class BasicWidgetWithScopeNoExisting extends StatefulWidget {
  const BasicWidgetWithScopeNoExisting({super.key});

  @override
  State<BasicWidgetWithScopeNoExisting> createState() =>
      _BasicWidgetWithScopeNoExistingState();
}

class _BasicWidgetWithScopeNoExistingState
    extends State<BasicWidgetWithScopeNoExisting> {
  late final A one;
  late final A two;
  late final C c;

  @override
  void didChangeDependencies() {
    final scope = context.scoped(useExistingSingletons: false);
    one = scope<A>();
    two = scope<A>();
    c = context.getScoped<C>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => const MaterialApp(home: Text('Hi'));
}

class BasicAsyncWidget extends StatefulWidget {
  const BasicAsyncWidget({super.key});

  @override
  State<BasicAsyncWidget> createState() => _BasicAsyncWidgetState();
}

class _BasicAsyncWidgetState extends State<BasicAsyncWidget> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: FutureBuilder(
          // ignore: discarded_futures
          future: context.getAsync<String>(),
          builder: (ctx, ss) => switch (ss.connectionState) {
            ConnectionState.done => Text(ss.data!),
            _ => const CircularProgressIndicator()
          },
        ),
      );
}
