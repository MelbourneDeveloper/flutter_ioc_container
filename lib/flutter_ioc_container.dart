library flutter_ioc_container;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

///This widget houses the IoC container and we propagate this to all widgets in
///the tree. Put one at the root of your app
class ContainerWidget extends InheritedWidget {
  ///Creates a [ContainerWidget]
  ContainerWidget({
    required super.child,
    IocContainer? container,
    IocContainer Function(IocContainerBuilder builder)? compose,
    super.key,
  })  : container = container ?? compose!(IocContainerBuilder()),
        assert(
          compose != null || container != null,
          'You must specify a container or a compose method.',
        );

  ///The IoC container. This is the container that will be used by all widgets.
  ///Use [IocContainerBuilder] to compose your dependencies and then call
  ///[IocContainerBuilder.toContainer] to get the container
  final IocContainer container;

  ///Get an instance of the service by type
  static T get<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.get<T>();

  ///Gets a service that requires async initialization. Add these services with [IocContainerBuilder.addAsync] or [IocContainerBuilder.addSingletonAsync] You can only use this on factories that return a Future<>. Warning: if the definition is singleton/scoped and the Future fails, the factory will never return a valid value, so use [getAsyncSafe] to ensure the container doesn't store failed singletons
  static Future<T> getAsync<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getAsync<T>();

  ///See [getAsync]. Safely makes an async call by creating a temporary scoped container, attempting to make the async initialization and merging the result with the current container if there is success. You don't need call this inside a factory (in your composition). Only call this from the outside, and handle the errors/timeouts gracefully. Warning: this does not do error handling and this also allows reentrancy. If you call this more than once in parallel it will create multiple Futures - i.e. make multiple async calls. You need to guard against this and perform retries on failure.
  static Future<T> getAsyncSafe<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getAsyncSafe<T>();

  ///Gets a service, but each service in the object mesh will have only one
  ///instance. If you want to get multiple scoped objects, call [scoped] to
  ///get a reusable [IocContainer] and then call [get] or [getAsync] on that.
  static T getScoped<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getScoped<T>();

  ///Creates a new Ioc Container for a particular scope. Does not use existing singletons/scope by default. Warning: if you use the existing singletons, calling dispose will dispose those singletons
  static IocContainer scoped<T extends Object>(
    BuildContext context, {
    bool useExistingSingletons = true,
  }) =>
      _guard(context).container.scoped(
            useExistingSingletons: useExistingSingletons,
          );

  static ContainerWidget _guard(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<ContainerWidget>();
    assert(container != null, 'No Container found in context');
    return container!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IocContainer>('container', container));
  }
}

///BuildContext extensions for ContainerWidget
extension IocContainerBuildContextExtensions on BuildContext {
  ///Get an instance of the service by type
  T get<T extends Object>() => ContainerWidget.get<T>(this);

  ///Shortcut for [get]
  T call<T extends Object>() => ContainerWidget.get<T>(this);

  ///Gets a service that requires async initialization. Add these services with [IocContainerBuilder.addAsync] or [IocContainerBuilder.addSingletonAsync] You can only use this on factories that return a Future<>. Warning: if the definition is singleton/scoped and the Future fails, the factory will never return a valid value, so use [getAsyncSafe] to ensure the container doesn't store failed singletons
  Future<T> getAsync<T extends Object>() => ContainerWidget.getAsync<T>(this);

  ///See [getAsync]. Safely makes an async call by creating a temporary scoped container, attempting to make the async initialization and merging the result with the current container if there is success. You don't need call this inside a factory (in your composition). Only call this from the outside, and handle the errors/timeouts gracefully. Warning: this does not do error handling and this also allows reentrancy. If you call this more than once in parallel it will create multiple Futures - i.e. make multiple async calls. You need to guard against this and perform retries on failure.
  Future<T> getAsyncSafe<T extends Object>() =>
      ContainerWidget.getAsyncSafe<T>(this);

  ///Gets a service, but each service in the object mesh will have only one
  ///instance. If you want to get multiple scoped objects, call [scoped] to
  ///get a reusable [IocContainer] and then call [get] or [getAsync] on that.
  T getScoped<T extends Object>() => ContainerWidget.getScoped<T>(this);

  ///Creates a new Ioc Container for a particular scope. Does not use existing singletons/scope by default. Warning: if you use the existing singletons, calling dispose will dispose those singletons
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
    super.key,
  });

  ///Whether or not to use existing singletons in the parent container
  // ignore: diagnostic_describe_all_properties
  final bool useExistingSingletons;

  ///The child widget
  final Widget child;

  @override
  State<ScopedContainerWidget> createState() => ScopedContainerWidgetState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>('child', child));
  }
}

///The staate of the ScopedContainerWidget
class ScopedContainerWidgetState extends State<ScopedContainerWidget> {
  ///The scoped container for this widget
  IocContainer? scope;

  @override
  void didUpdateWidget(ScopedContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    scope ??=
        context.scoped(useExistingSingletons: widget.useExistingSingletons);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scope ??=
        context.scoped(useExistingSingletons: widget.useExistingSingletons);
  }

  @override
  Widget build(BuildContext context) {
    assert(scope != null, 'No ContainerWidget found in context');

    return ContainerWidget(
      container: scope,
      child: widget.child,
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await scope?.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IocContainer>('scope', scope));
  }
}
