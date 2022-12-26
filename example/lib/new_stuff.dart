import 'package:bloobit/bloobit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

abstract class ScopedStatelessWidget extends StatelessWidget {
  const ScopedStatelessWidget({
    required this.scope,
    super.key,
  });
  final IocContainer scope;
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
