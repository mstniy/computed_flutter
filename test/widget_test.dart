import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class StatelessTestWidget extends ComputedWidget {
  final ValueNotifier<int> v;
  final List<int> buildCnt;
  final Key textKey;

  const StatelessTestWidget(this.v, this.textKey, this.buildCnt, {super.key});

  @override
  Widget build(BuildContext ctx) {
    buildCnt[0]++;
    return MaterialApp(home: Text(key: textKey, v.use.toString()));
  }
}

class StatefulTestWidget extends ComputedStatefulWidget {
  final ValueNotifier<int> v1, v2;
  final List<int> buildCnt;
  final Key textKey;

  const StatefulTestWidget(this.v1, this.v2, this.textKey, this.buildCnt,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return _StatefulTestWidgetState();
  }
}

class _StatefulTestWidgetState extends State<StatefulTestWidget> {
  void listener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.v2.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.v2.removeListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    widget.buildCnt[0]++;
    return MaterialApp(
        home: Text(
            key: widget.textKey, (widget.v1.use + widget.v2.value).toString()));
  }
}

void expectText(WidgetTester tester, Key key, String text) {
  expect(
    tester.widget<Text>(find.byKey(key)).data,
    equals(text),
  );
}

void main() {
  testWidgets('ComputedWidget', (tester) async {
    final v = ValueNotifier(0);
    final buildCnt = [0];
    final key = UniqueKey();

    await tester.pumpWidget(StatelessTestWidget(v, key, buildCnt));

    expectText(tester, key, "0");
    expect(buildCnt[0], 2);

    await tester.pump();

    expectText(tester, key, "0");
    expect(buildCnt[0], 2);

    v.value = 1;
    await tester.pump();

    expectText(tester, key, "1");
    expect(buildCnt[0], 4);

    await tester.pump();

    expectText(tester, key, "1");
    expect(buildCnt[0], 4);
  });

  testWidgets('ComputedStatefulWidget', (tester) async {
    final v1 = ValueNotifier(0);
    final v2 = ValueNotifier(1);
    final buildCnt = [0];
    final key = UniqueKey();

    await tester.pumpWidget(StatefulTestWidget(v1, v2, key, buildCnt));

    expectText(tester, key, "1");
    expect(buildCnt[0], 2);

    await tester.pump();

    expectText(tester, key, "1");
    expect(buildCnt[0], 2);

    v1.value = 1;
    await tester.pump();

    expectText(tester, key, "2");
    expect(buildCnt[0], 4);

    await tester.pump();

    expectText(tester, key, "2");
    expect(buildCnt[0], 4);

    v2.value = 2;
    await tester.pump();

    expectText(tester, key, "3");
    expect(buildCnt[0], 6);

    await tester.pump();

    expectText(tester, key, "3");
    expect(buildCnt[0], 6);
  });

  testWidgets('ComputedBuilder', (tester) async {
    final v = ValueNotifier(0);
    final buildCnt = [0];
    final key = UniqueKey();

    await tester.pumpWidget(ComputedBuilder(builder: (ctx) {
      buildCnt[0]++;
      return MaterialApp(home: Text(key: key, v.use.toString()));
    }));

    expectText(tester, key, "0");
    expect(buildCnt[0], 2);

    await tester.pump();

    expectText(tester, key, "0");
    expect(buildCnt[0], 2);

    v.value = 1;
    await tester.pump();

    expectText(tester, key, "1");
    expect(buildCnt[0], 4);

    await tester.pump();

    expectText(tester, key, "1");
    expect(buildCnt[0], 4);
  });

  testWidgets('throwing computation throws during widget build',
      (tester) async {
    final buildCnt = [0];
    var flag = false;

    final originalOnError = FlutterError.onError;

    FlutterError.onError = (details) {
      expect(flag, false);
      expect(details.stack.toString(), contains('myThrowingFunction'));
      flag = true;
    };

    Never myThrowingFunction() {
      throw 42;
    }

    try {
      await tester.pumpWidget(ComputedBuilder(builder: (ctx) {
        buildCnt[0]++;
        myThrowingFunction();
      }));

      FlutterError.onError = null;

      expect(buildCnt[0], 2);
      expect(flag, true);
    } finally {
      FlutterError.onError = originalOnError;
    }
  });
}
