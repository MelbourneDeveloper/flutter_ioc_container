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
  AppChangeNotifier(this.themeNotifier);

  int counter = 0;

  bool _displayCounter = true;
  bool get displayCounter => _displayCounter;
  set displayCounter(value) {
    _displayCounter = value;
    notifyListeners();
  }

  final ThemeChangeNotifier themeNotifier;

  void increment() {
    counter++;
    themeNotifier.isDark = counter.isOdd;
    notifyListeners();
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
      ..addSingleton(
        (container) => AppChangeNotifier(
          container<ThemeChangeNotifier>(),
        ),
      );

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ScopedContainerWidget(
        child: AnimatedBuilder(
          animation: context<ThemeChangeNotifier>(),
          builder: (context, widget) => MaterialApp(
            title: title,
            theme: context<ThemeChangeNotifier>().themeData,
            home: Scaffold(
              appBar: AppBar(
                title: const Text(title),
              ),
              body: context<AppChangeNotifier>().displayCounter
                  ? const CounterDisplay()
                  : const Text('X'),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () =>
                        context<AppChangeNotifier>().displayCounter = false,
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
      );
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
