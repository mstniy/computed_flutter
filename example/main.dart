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

  print('a');

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
      home: const MyHomePage(title: 'Computed Flutter Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final anyNegative =
        Computed(() => source.use.any((element) => element < 0));

    final maybeReversed = Computed(
        () => anyNegative.use ? source.use.reversed.toBuiltList() : source.use);

    final append0 = Computed(() {
      return maybeReversed.use.rebuild((p0) => p0.add(0));
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: append0.asValueListenable,
              builder: (context, BuiltList<int> value, child) => Text(
                value.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
