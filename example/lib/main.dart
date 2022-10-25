import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

const scopedContainerKey = ValueKey('asdasd');

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
  set displayCounter(bool value) {
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
  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  ThemeData get themeData => isDark ? darkTheme : lightTheme;
}

class DisposableService {
  final title = 'asdf';
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
      ..addSingletonService(ThemeChangeNotifier())
      ..addSingletonAsync(
        (container) async => Future<SlowService>.delayed(
          const Duration(seconds: 5),
          SlowService.new,
        ),
      )
      ..addSingleton(
        (container) => AppChangeNotifier(
          container<ThemeChangeNotifier>(),
        ),
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
        builder: (context, widget) => context<AppChangeNotifier>()
                .displayCounter
            ? ScopedContainerWidget(
                key: scopedContainerKey,
                child: FutureBuilder(
                  future: context.getAsync<SlowService>(),
                  builder: (c, s) {
                    //We only do this to create an instance of the disposable
                    //service for the scope
                    context<DisposableService>();

                    return AnimatedBuilder(
                      animation: context<ThemeChangeNotifier>(),
                      builder: (context, widget) => MaterialApp(
                        title:
                            s.data?.title ?? context<DisposableService>().title,
                        theme: context<ThemeChangeNotifier>().themeData,
                        home: Scaffold(
                          appBar: AppBar(
                            title: s.data != null
                                ? Text(s.data!.title)
                                : const CircularProgressIndicator.adaptive(),
                          ),
                          body: const CounterDisplay(),
                          floatingActionButton: floatingActionButtons(context),
                        ),
                      ),
                    );
                  },
                ),
              )
            : const ClosedWidget(),
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${context<AppChangeNotifier>().counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      );
}
