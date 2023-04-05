import 'package:flutter/material.dart';
import 'package:flutter_ioc_container/flutter_ioc_container.dart';
import 'package:ioc_container/ioc_container.dart';

class CounterController extends ValueNotifier<int> {
  CounterController() : super(0);

  void increment() => value++;
}

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.configureOverrides,
  });

  //This allows us to override the dependencies for testing. Take a look at
  //the widget tests
  final void Function(IocContainerBuilder builder)? configureOverrides;

  @override
  Widget build(BuildContext context) => CompositionRoot(
        configureOverrides: configureOverrides,
        compose: (builder) => builder
          //Adds a singleton CounterController to the container
          ..addSingleton(
            (container) => CounterController(),
          ),
        child:
            //We need the BuildContext from the Builder here so the children
            //can access the container in the CompositionRoot
            Builder(
          builder: (context) => AnimatedBuilder(
            //Access the ValueNotifier. It's a singleton so we can access it
            //from anywhere in the widget tree safely
            animation: context<CounterController>(),
            builder: (context, child) => MaterialApp(
              theme: ThemeData(useMaterial3: true),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Align(
                  child: SizedBox(
                    height: 60,
                    width: 300,
                    child: FloatingActionButton.extended(
                      icon: const Icon(Icons.add),
                      //Increment the value
                      onPressed: context<CounterController>().increment,
                      label: Text(
                        //Display the value
                        context<CounterController>().value.toString(),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
