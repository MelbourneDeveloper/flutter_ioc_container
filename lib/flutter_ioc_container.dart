library flutter_ioc_container;

import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

///This widget houses the IoC container and we propagate this to all widgets in
///the tree. Put one at the root of your app
class ContainerWidget extends InheritedWidget {
  const ContainerWidget({
    super.key,
    required this.container,
    required super.child,
  });

  final IocContainer container;

  static T get<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.get<T>();

  static Future<T> getAsync<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getAsync<T>();

  static Future<T> getAsyncSafe<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getAsyncSafe<T>();

  static T getScoped<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getScoped<T>();

  static IocContainer scoped<T extends Object>(BuildContext context,
          {bool useExistingSingletons = true}) =>
      _guard(context).container.scoped(
            useExistingSingletons: useExistingSingletons,
          );

  static ContainerWidget _guard(BuildContext context) {
    var container =
        context.dependOnInheritedWidgetOfExactType<ContainerWidget>();
    assert(container != null, 'No Container found in context');
    return container!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

extension IocContainerBuildContextExtensions on BuildContext {
  T get<T extends Object>() => ContainerWidget.get<T>(this);
  T call<T extends Object>() => ContainerWidget.get<T>(this);
  Future<T> getAsync<T extends Object>() => ContainerWidget.getAsync<T>(this);
  Future<T> getAsyncSafe<T extends Object>() =>
      ContainerWidget.getAsyncSafe<T>(this);
  T getScoped<T extends Object>() => ContainerWidget.getScoped<T>(this);
  IocContainer scoped({bool useExistingSingletons = true}) =>
      ContainerWidget.scoped(
        this,
        useExistingSingletons: useExistingSingletons,
      );
}

///This widget is used to create a new scope. Use this to
///hold state
class ScopedContainerWidget extends StatefulWidget {
  ///Creates a [ScopedContainerWidget]
  const ScopedContainerWidget({
    required this.child,
    this.useExistingSingletons = true,
    Key? key,
  }) : super(key: key);

  final bool useExistingSingletons;
  final Widget child;

  @override
  State<ScopedContainerWidget> createState() => _ScopedContainerWidgetState();
}

class _ScopedContainerWidgetState extends State<ScopedContainerWidget> {
  late final IocContainer scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scope = ContainerWidget.scoped(
      context,
      useExistingSingletons: widget.useExistingSingletons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ContainerWidget(
      container: scope,
      child: widget.child,
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await scope.dispose();
  }
}
