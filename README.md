# flutter_ioc_container

![ioc_container](https://github.com/MelbourneDeveloper/ioc_container/raw/main/images/ioc_container-256x256.png)

Manage your dependencies in the widget tree, access them from the `BuildContext` and replace them with test doubles for testing.

[ioc_container](https://pub.dev/packages/ioc_container) is a dependency injection and service location library for Dart. You can use it in Flutter as a service locator like the `GetIt` package. `flutter_ioc_container` is an extension for `ioc_container` that exposes the library throughout the widget tree so you can use it like `Provider`. It provides extension methods on `BuildContext` to allow you to get instances of your dependencies and anywhere in the widget tree. 

This accesses the `CounterController` to increment and grab the current value

```dart
FloatingActionButton.extended(
    icon: const Icon(Icons.add),
    //Increment the value
    onPressed: context<CounterController>().increment,
    label: Text(
    //Display the value
    context<CounterController>().value.toString(),
    style: Theme.of(context).textTheme.headlineMedium,
    ),
),
```

_See the [ioc_container](https://pub.dev/packages/ioc_container) documentation for a more comprehensive guide._

## Getting Started

### Installing the Package

Add the following line to your `pubspec.yaml` file under the dependencies section:

`flutter_ioc_container: <latest version>`

Run `flutter pub get` to download the dependencies.

Or, you can install the package from the command line:

`flutter pub add flutter_ioc_container`

### Defining and Injecting Dependencies
You can define your dependencies and inject them into your widgets using the `CompositionRoot` widget. You can either pass an `IocContainer` instance into `container` or use the compose property to define your dependencies. The `CompositionRoot` widget houses the IoC container and is placed at the root of the widget tree to propagate it throughout the widgets.

### Basic Usage
- Put a `CompositionRoot` widget at the base of your widget tree 
- Use the `builder` in the `compose` function to add singleton or transient dependencies to the container. 
- Access the dependencies throughout the widget tree via the `BuildContext`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';

void main() {
  runApp(
    CompositionRoot(
      compose: (builder) => builder.addSingleton((container) => 'test'),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => const BasicWidget()),
        ),
      ),
    ),
  );
}

class BasicWidget extends StatelessWidget {
  const BasicWidget({super.key});

  @override
  Widget build(BuildContext context) => Text(context<String>());
}
```

### Scoping
If you need a set of dependencies that have a short life and you need to dispose of them afterward, something in the widget tree needs to hold onto a scoped container. Get a scoped container by calling `context.scoped()`. One approach is to put the scoped container in the `State` of a `StatefulWidget` and dispose of the contents in the `dispose()` method of the `State`.

This example creates a scoped container on `didChangeDependencies`. It exists for the lifespan of the state and the resources get disposed when the widget tree disposes of this widget.

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

class DisposableResources {
  String display = 'hello world';

  void dispose() {
    // ignore: avoid_print
    print('Disposed');
  }
}

void main() {
  runApp(
    CompositionRoot(
      compose: (builder) => builder.addServiceDefinition<DisposableResources>(
        ServiceDefinition(
          (container) => DisposableResources(),
          dispose: (service) => service.dispose(),
        ),
      ),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => const BasicWidget()),
        ),
      ),
    ),
  );
}

class BasicWidget extends StatefulWidget {
  const BasicWidget({super.key});

  @override
  State<BasicWidget> createState() => _BasicWidgetState();
}

class _BasicWidgetState extends State<BasicWidget> {
  late final IocContainer scopedContainer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scopedContainer = context.scoped();
  }

  @override
  void dispose() {
    super.dispose();
    unawaited(scopedContainer.dispose());
  }

  @override
  Widget build(BuildContext context) =>
      Text(scopedContainer<DisposableResources>().display);
}
```

See more on scoping [here](https://pub.dev/packages/ioc_container#scoping-and-disposal). 

### Async Injection
If your dependency requires async initialization, you can do this using 'addAsync'. You can use the [`FutureBuilder`](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html) widget to render the object when it is available. Here's an example:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';

void main() {
  runApp(
    CompositionRoot(
      compose: (builder) => builder.addSingletonAsync(
        (container) async => Future<String>.delayed(
          const Duration(seconds: 5),
          () => 'Hello world!',
        ),
      ),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) => const BasicAsyncWidget()),
        ),
      ),
    ),
  );
}

class BasicAsyncWidget extends StatefulWidget {
  const BasicAsyncWidget({super.key});

  @override
  State<BasicAsyncWidget> createState() => _BasicAsyncWidgetState();
}

class _BasicAsyncWidgetState extends State<BasicAsyncWidget> {
  late final Future<String> future;

  @override
  void didChangeDependencies() {
    // ignore: discarded_futures
    future = context.getAsync<String>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
        // ignore: discarded_futures
        future: future,
        builder: (ctx, ss) => ss.connectionState == ConnectionState.done
            ? Text(ss.data!)
            : const CircularProgressIndicator(),
      );
}
```

See more on async injection [here](https://pub.dev/packages/ioc_container#async-initialization).

