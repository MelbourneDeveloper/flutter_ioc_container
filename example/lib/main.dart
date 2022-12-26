import 'package:bloobit/bloobit.dart';
import 'package:example/new_stuff.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

class AppState {
  AppState(this.counter);

  final int counter;

  AppState copyWith({int? counter}) => AppState(counter ?? this.counter);
}

class AppBloobit extends Bloobit<AppState> {
  AppBloobit(super.initialState);

  void increment() => setState(state.copyWith(counter: state.counter + 1));
}

IocContainerBuilder compose() => IocContainerBuilder()
  ..add(
    (container) => AppBloobit(AppState(0)),
  )
  ..add(
    (container) => CounterDisplay(
      scope: container,
    ),
  )
  ..add(
    (container) => CounterText(
      counter: container<AppBloobit>().state.counter,
    ),
  );

void main() {
  runApp(
    const AppRoot(),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    this.configureOverrides,
  });

  final void Function(IocContainerBuilder builder)? configureOverrides;

  @override
  Widget build(BuildContext context) => CompositionRoot(
        configureOverrides: configureOverrides,
        container: compose().toContainer(),
        child: const CounterApp(),
      );
}

class CounterApp extends StatelessWidget {
  const CounterApp({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context) => BloobitScope<AppBloobit, AppState>(
        builder: (context, scope, bloobit) => MaterialApp(
          title: 'sample',
          home: Scaffold(
            appBar: AppBar(
              title: const Text('sample'),
            ),
            body: Align(
              child: SizedBox(
                height: 60,
                width: 300,
                child: ElevatedButton(
                  onPressed: bloobit.increment,
                  child: scope<CounterDisplay>(isTransient: true),
                ),
              ),
            ),
          ),
        ),
      );
}

class CounterDisplay extends ScopedStatelessWidget {
  const CounterDisplay({
    required super.scope,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: scope<CounterText>(isTransient: true),
      );
}

class CounterText extends StatelessWidget {
  const CounterText({
    required this.counter,
    super.key,
  });

  final int counter;

  @override
  Widget build(BuildContext context) => Text(
        '$counter',
        style: Theme.of(context).textTheme.headline4!.copyWith(
              color: Colors.white,
            ),
      );
}
