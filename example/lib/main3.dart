import 'package:bloobit/bloobit.dart';
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

IocContainer container = compose().toContainer();

IocContainerBuilder compose() => IocContainerBuilder()
  ..add(
    (container) => AppBloobit(AppState(0)),
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
        container: container,
        child: CounterApp(),
      );
}

class CounterApp extends StatelessWidget {
  CounterApp({
    // ignore: unused_element
    super.key,
  });
  final bloobit = container<AppBloobit>();
  @override
  Widget build(BuildContext context) {
    final scope = Scope(
      child: BloobitWidget(
        bloobit: bloobit,
        builder: (context, widget) => MaterialApp(
          title: 'sample',
          home: Scaffold(
            appBar: AppBar(
              title: const Text('sample'),
            ),
            body: CounterDisplay(),
            floatingActionButton: floatingActionButtons(context),
          ),
        ),
      ),
    );
    return scope;
  }

  Row floatingActionButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: bloobit.increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      );
}

class CounterDisplay extends StatelessWidget {
  factory CounterDisplay() => CounterDisplay._internal(
        appBloobit: container<AppBloobit>(),
      );

  const CounterDisplay._internal({
    required this.appBloobit,
    // ignore: unused_element
    super.key,
  });

  final AppBloobit appBloobit;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${appBloobit.state.counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      );
}
