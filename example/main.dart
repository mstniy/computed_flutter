import 'package:built_collection/built_collection.dart';
import 'package:computed_flutter/computed_flutter.dart';

import 'package:flutter/material.dart';

final source = ValueNotifier(<int>[].toBuiltList());

void main() {
  () async {
    source.value = [1, 2, -3, 4].toBuiltList();
    await Future.delayed(const Duration(seconds: 3));
    source.value = [1, 2, -3, -4].toBuiltList();
    await Future.delayed(const Duration(seconds: 3));
    source.value = [4, 5, 6].toBuiltList();
    await Future.delayed(const Duration(seconds: 3));
    source.value = [4, 5, 6].toBuiltList();
  }();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Computed Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Computed Flutter Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});
  final String title;

  final Computed<BuiltList<int>> list = Computed(() {
    final anyNegative = source.use.any((element) => element < 0);
    final maybeReversed =
        anyNegative ? source.use.reversed.toBuiltList() : source.use;
    return maybeReversed.rebuild((p0) => p0.add(0));
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            list.when(
                context,
                (value) => Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                noValue: () => const Text('no value'))
          ],
        ),
      ),
    );
  }
}
