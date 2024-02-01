import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:flutter_ioc_container/ioc_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fallback method returns correct instance', (tester) async {
    // Configure the container
    final containerBuilder = IocContainerBuilder()
      ..add((container) => A('Hello, World!'));

    await tester.pumpWidget(
      MaterialApp(
        home: CompositionRoot(
          container: containerBuilder.toContainer(),
          child: const TestWidget(),
        ),
      ),
    );

    // Expect that the TestWidget shows the correct text from the container
    expect(find.text('Hello, World!'), findsOneWidget);
  });
}

class A {
  A(this.name);
  final String name;
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final instance = CompositionRoot.fallback<A>(context);
    return Text(instance.name);
  }
}
