# flutter_ioc_container

Flutter extensions that allow you to use the [ioc_container](https://pub.dev/packages/ioc_container) throughout the widget tree. The library provides extension methods on `BuildContext` to allow getting instances of objects from the container, such as `get<T>()`, `getAsync<T>()`, and `scoped<T>()`.

## Getting Started

### Installing the Package

To use "flutter_ioc_container", add the following line to your `pubspec.yaml` file under the dependencies section:

`flutter_ioc_container: <latest version>`

Run `flutter pub get` to download the dependencies.

### Defining and Injecting Dependencies
You can define your dependencies and inject them into your widgets using the `CompositionRoot` widget. You can either pass an `IocContainer` instance into `container` or use the compose property to define your dependencies. The `CompositionRoot` widget houses the IoC container and is placed at the root of the widget tree to propagate it throughout the widgets.

### Basic Injection
Let's say you want to inject a string into your widget tree. To do this, you can define a string and pass it to the `CompositionRoot` widget as a parameter. Here's an example:

```dart
const text = 'test';
final root = CompositionRoot(
    compose: (builder) => builder.add((container) => text),
    child: const BasicWidget(),
);
```

### Scoped Injection
If you need a set of dependencies that have a short life and you want to dispose of them afterwards, you can use the `scoped` method to create a scoped container. Here's an example:

```dart
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
```

You can load the dependencies in the `State` of your widget

```dart
@override
void didChangeDependencies() {
final scope = context.scoped();
one = scope<A>();
two = scope<A>();
c = context.getScoped<C>();
super.didChangeDependencies();
}
```

### Async Injection
If you want to inject an object into the widget tree that is loaded asynchronously, you can do so using 'addAsync'. You can use the FutureBuilder widget to render the object when it is available. Here's an example:

```dart
const text = 'test';
final root = CompositionRoot(
    compose: (builder) => builder.addAsync(
    (container) async =>
        Future<String>.delayed(const Duration(seconds: 1), () => text),
    ),
    child: const BasicAsyncWidget(),
);
```

You can access the future with `FutureBuilder` like this.

```dart
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
```


