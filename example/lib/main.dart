import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

const title = 'ioc_container example';

final lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
);

final darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
);

class AppChangeNotifier extends ChangeNotifier {
  AppChangeNotifier(this.themeNotifier, this.disposableService);

  int counter = 0;

  bool _displayCounter = true;
  bool get displayCounter => _displayCounter;
  set displayCounter(value) {
    _displayCounter = value;
    notifyListeners();
  }

  final ThemeChangeNotifier themeNotifier;
  final DisposableService disposableService;

  void increment() {
    counter++;
    themeNotifier.isDark = counter.isOdd;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint('Disposed of the app change notifier');
  }
}

class ThemeChangeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  set isDark(value) {
    _isDark = value;
    notifyListeners();
  }

  ThemeData get themeData => isDark ? darkTheme : lightTheme;
}

class DisposableService {
  void dispose() {
    debugPrint('Disposed of the disposable service');
  }
}

void main() {
  runApp(
    ContainerWidget(
      container: compose().toContainer(),
      child: const MyApp(),
    ),
  );
}

IocContainerBuilder compose({bool allowOverrides = false}) =>
    IocContainerBuilder(
      allowOverrides: allowOverrides,
    )
      ..addSingletonService(ThemeChangeNotifier())
      ..add(
        (container) => DisposableService(),
        dispose: (d) => d.dispose(),
      )
      ..addSingleton(
        (container) => AppChangeNotifier(
          container<ThemeChangeNotifier>(),
          container<DisposableService>(),
        ),
      );

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: context<AppChangeNotifier>(),
        builder: (context, widget) => context<AppChangeNotifier>()
                .displayCounter
            ? ScopedContainerWidget(
                child: AnimatedBuilder(
                  animation: context<ThemeChangeNotifier>(),
                  builder: (context, widget) => MaterialApp(
                    title: title,
                    theme: context<ThemeChangeNotifier>().themeData,
                    home: Scaffold(
                      appBar: AppBar(
                        title: const Text(title),
                      ),
                      body: const CounterDisplay(),
                      floatingActionButton: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            onPressed: () => context<AppChangeNotifier>()
                                .displayCounter = false,
                            tooltip: 'Remove Counter',
                            child: const Icon(Icons.close),
                          ),
                          FloatingActionButton(
                            onPressed: context<AppChangeNotifier>().increment,
                            tooltip: 'Increment',
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const ClosedWidget(),
      );
}

///This is a blank widget that displays when the app is closed
class ClosedWidget extends StatelessWidget {
  const ClosedWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Text('X'),
      ),
    );
  }
}

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            AnimatedBuilder(
              animation: context<AppChangeNotifier>(),
              builder: (context, widget) => Text(
                '${context<AppChangeNotifier>().counter}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      );
}
