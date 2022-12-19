import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

class AppChangeNotifier extends ChangeNotifier {
  bool get isDark => _isDark;
  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  bool get displayCounter => _displayCounter;
  set displayCounter(bool value) {
    _displayCounter = value;
    notifyListeners();
  }

  ThemeData get themeData => isDark
      ? ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        )
      : ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        );

  int get counter => _counter;

  int _counter = 0;
  bool _isDark = false;
  bool _displayCounter = true;

  void increment() {
    _counter++;
    //No need to notify listeners because that will get called here
    isDark = counter.isOdd;
  }
}

class DisposableService {
  final counterLabel = 'You have pushed the button this many times:';
  void dispose() {
    debugPrint('Disposed of the disposable service');
  }
}

class SlowService {
  final title = 'ioc_container example';
}

IocContainer container = compose().toContainer();

IocContainerBuilder compose() => IocContainerBuilder()
  ..
      //Singetons
      addSingletonAsync(
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
  )
  ..addAsync<CounterApp>(
    (container) async => CounterApp._internal(
      slowService: container.getAsync<SlowService>(),
      appChangeNotifier: container<AppChangeNotifier>(),
    ),
  );

void main() {
  runApp(
    const AppRoot(),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    this.configureOverrides,
  });

  final void Function(IocContainerBuilder builder)? configureOverrides;

  @override
  Widget build(BuildContext context) => CompositionRoot(
        configureOverrides: configureOverrides,
        container: container,
        child: CounterApp(),
      );
}

class CounterApp extends StatelessWidget {
  factory CounterApp() => CounterApp._internal(
        slowService: container.getAsync<SlowService>(),
        appChangeNotifier: container<AppChangeNotifier>(),
      );

  const CounterApp._internal({
    required this.slowService,
    required this.appChangeNotifier,
    // ignore: unused_element
    super.key,
  });

  final Future<SlowService> slowService;
  final AppChangeNotifier appChangeNotifier;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: appChangeNotifier,
        builder: (context, widget) => FutureBuilder(
          future: slowService,
          builder: (materialAppContext, snapshot) => MaterialApp(
            title: snapshot.data?.title ?? '',
            theme: appChangeNotifier.themeData,
            home: Scaffold(
              appBar: AppBar(
                title: snapshot.data?.title != null
                    ? Text(snapshot.data!.title)
                    : const CircularProgressIndicator.adaptive(),
              ),
              body: appChangeNotifier.displayCounter
                  ? const Scope(
                      child: CounterDisplay(),
                    )
                  : const Align(
                      child: Text(
                        'X',
                        style: TextStyle(
                          fontSize: 50,
                        ),
                      ),
                    ),
              floatingActionButton: floatingActionButtons(context),
            ),
          ),
        ),
      );

  Row floatingActionButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => appChangeNotifier.displayCounter = false,
            tooltip: 'Remove Counter',
            child: const Icon(Icons.close),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: appChangeNotifier.increment,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
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
              context<DisposableService>().counterLabel,
            ),
            Text(
              '${context<AppChangeNotifier>().counter}',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      );
}
