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

IocContainerBuilder compose() => IocContainerBuilder()
  ..add(
    (container) => AppBloobit(AppState(0)),
  )
  ..add(
    (container) => CounterDisplay(
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

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    required this.counter,
    super.key,
  });

  final int counter;

  @override
  Widget build(BuildContext context) => Center(
        child: CounterText(counter: counter),
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

class BloobitScope<T extends Bloobit<TState>, TState> extends StatefulWidget {
  const BloobitScope({
    required this.builder,
    super.key,
  });

  ///The child widget
  final Widget Function(
    BuildContext context,
    IocContainer scope,
    T bloobit,
  ) builder;

  @override
  State<BloobitScope<T, TState>> createState() =>
      BloobitScopeState<T, TState>();
}

///The staate of the ScopedContainerWidget
class BloobitScopeState<T extends Bloobit<TState>, TState>
    extends State<BloobitScope<T, TState>> {
  ///The scoped container for this widget
  IocContainer? scope;
  T? bloobit;

  @override
  void didUpdateWidget(BloobitScope<T, TState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    scope ??= context.scoped();
    bloobit ??= scope!<T>();
    bloobit!.attach(setState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scope ??= context.scoped();
    bloobit ??= scope!<T>();
    bloobit!.attach(setState);
  }

  @override
  Widget build(BuildContext context) {
    assert(scope != null, 'No ContainerWidget found in context');

    return CompositionRoot(
      container: scope,
      child: widget.builder(
        context,
        scope!,
        bloobit!,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await scope?.dispose();
  }
}
