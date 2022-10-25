import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

final lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
);

final darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
);

class AppChangeNotifier extends ChangeNotifier {
  int counter = 0;

  bool _isDark = false;
  bool get isDark => _isDark;
  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  ThemeData get themeData => isDark ? darkTheme : lightTheme;
  bool _displayCounter = true;
  bool get displayCounter => _displayCounter;
  set displayCounter(bool value) {
    _displayCounter = value;
    notifyListeners();
  }

  void increment() {
    counter++;
    isDark = counter.isOdd;
  }
}

class DisposableService {
  final title = 'You have pushed the button this many times:';
  void dispose() {
    debugPrint('Disposed of the disposable service');
  }
}

class SlowService {
  final title = 'ioc_container example';
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
      //Singetons
      ..addSingletonAsync(
        (container) async => Future<SlowService>.delayed(
          const Duration(seconds: 5),
          SlowService.new,
        ),
      )
      ..addSingleton(
        (container) => AppChangeNotifier(),
      )

      //Transient
      ..add(
        (container) => DisposableService(),
        dispose: (d) => d.dispose(),
      );

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: context<AppChangeNotifier>(),
        builder: (context, widget) => FutureBuilder(
          future: context.getAsync<SlowService>(),
          builder: (futureBuilderContext, snapshot) => MaterialApp(
            title: snapshot.data?.title ?? '',
            theme: futureBuilderContext<AppChangeNotifier>().themeData,
            home: Scaffold(
              appBar: AppBar(
                title: snapshot.data != null
                    ? Text(snapshot.data!.title)
                    : const CircularProgressIndicator.adaptive(),
              ),
              body: context<AppChangeNotifier>().displayCounter
                  ? const ScopedContainerWidget(
                      child: CounterDisplay(),
                    )
                  : const ClosedWidget(),
              floatingActionButton: floatingActionButtons(futureBuilderContext),
            ),
          ),
        ),
      );

  Row floatingActionButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () =>
                context<AppChangeNotifier>().displayCounter = false,
            tooltip: 'Remove Counter',
            child: const Icon(Icons.close),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: context<AppChangeNotifier>().increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      );
}

///This is a blank widget that displays when the app is closed
class ClosedWidget extends StatelessWidget {
  const ClosedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: Scaffold(
          body: Align(
            child: Text(
              'X',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
          ),
        ),
      );
}

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              context<DisposableService>().title,
            ),
            Text(
              '${context<AppChangeNotifier>().counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      );
}
