import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ioc_container/ioc_container.dart';

///A Compose object is used to determine how the IoC container is created.
///The two choices are [ContainerCompose] and [BuildCompose].
sealed class Compose {}

/// Use this to pass an existing container to the CompositionRoot
final class ContainerCompose extends Compose {
  /// Creates a [ContainerCompose]
  ContainerCompose(this.container);

  /// The container to use
  final IocContainer container;
}

/// Use this to build the container from a builder at the point of
/// constructing the [CompositionRoot]. Most apps will use this case
final class BuildCompose extends Compose {
  /// Creates a [BuildCompose]
  BuildCompose(this.configureBuild);

  /// Exposes the builder so you can configure it at the point of constructing
  /// the [CompositionRoot]
  final void Function(IocContainerBuilder builder) configureBuild;
}

/// Use this to build the container from a builder at the point of
/// constructing the [CompositionRoot].
final class BuilderCompose extends Compose {
  /// Creates a [BuilderCompose]
  BuilderCompose(this.builder);

  /// The builder to build the container with
  final IocContainerBuilder builder;
}

///This widget houses the IoC container and we propagate this to all widgets in
///the tree. Put one at the root of your app
class CompositionRoot extends InheritedWidget {
  ///Creates a [CompositionRoot]
  CompositionRoot({
    required super.child,
    required Compose compose,
    this.configureOverrides,
    super.key,
  }) : container = switch (compose) {
          // Accepts an existing container
          final ContainerCompose cc => cc.container,
          // Builds the container from a builder
          final BuildCompose bc =>
            _getBuilder(bc, configureOverrides != null).toContainer(),
          // Builds the container from a builder, but BYO
          final BuilderCompose bc => bc.builder.toContainer(),
        };

  /// Runs the configuration on the builder
  static IocContainerBuilder _getBuilder(
    BuildCompose composeBuilder,
    bool allowOverrides,
  ) {
    final iocContainerBuilder =
        IocContainerBuilder(allowOverrides: allowOverrides);
    composeBuilder.configureBuild(iocContainerBuilder);
    return iocContainerBuilder;
  }

  ///Allows overrides for testing
  final void Function(IocContainerBuilder builder)?
      // ignore: diagnostic_describe_all_properties
      configureOverrides;

  ///The IoC container. This is the container that will be used by all widgets.
  ///Use [IocContainerBuilder] to compose your dependencies and then call
  ///[IocContainerBuilder.toContainer] to get the container
  final IocContainer container;

  ///Get an instance of the service by type
  static T get<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.get<T>();

  ///Gets a service that requires async initialization. Add these services with
  ///[IocContainerBuilder.addAsync] or [IocContainerBuilder.addSingletonAsync].
  ///This uses the async locking feature.
  static Future<T> getAsync<T extends Object>(
    BuildContext context,
  ) =>
      _guard(context).container.getAsync<T>();

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

  static CompositionRoot _guard(BuildContext context) {
    final container =
        context.dependOnInheritedWidgetOfExactType<CompositionRoot>();
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
  T get<T extends Object>() => CompositionRoot.get<T>(this);

  ///Shortcut for [get]
  T call<T extends Object>() => CompositionRoot.get<T>(this);

  ///Gets a service that requires async initialization. Add these services with
  ///[IocContainerBuilder.addAsync] or [IocContainerBuilder.addSingletonAsync]
  ///You can only use this on factories that return a Future<>.
  Future<T> getAsync<T extends Object>() => CompositionRoot.getAsync<T>(this);

  ///Gets a service, but each service in the object mesh will have only one
  ///instance. If you want to get multiple scoped objects, call [scoped] to
  ///get a reusable [IocContainer] and then call [get] or [getAsync] on that.
  T getScoped<T extends Object>() => CompositionRoot.getScoped<T>(this);

  ///Creates a new Ioc Container for a particular scope. Does not use existing singletons/scope by default. Warning: if you use the existing singletons, calling dispose will dispose those singletons
  IocContainer scoped({bool useExistingSingletons = true}) =>
      CompositionRoot.scoped(
        this,
        useExistingSingletons: useExistingSingletons,
      );
}
