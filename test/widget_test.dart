import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

class StatelessTestWidget extends ComputedWidget {
  final ValueNotifier<Key> v;
  final List<int> buildCnt;

  const StatelessTestWidget(this.v, this.buildCnt, {super.key});

  @override
  Widget build(BuildContext ctx) {
    buildCnt[0]++;
    return SizedBox.shrink(key: v.use);
  }
}

class StatefulTestWidget extends ComputedStatefulWidget {
  final ValueNotifier<Key> v1, v2;
  final List<int> buildCnt;

  const StatefulTestWidget(this.v1, this.v2, this.buildCnt, {super.key});

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
    return Column(children: [
      SizedBox.shrink(key: widget.v1.use),
      SizedBox.shrink(key: widget.v2.value)
    ]);
  }
}

void main() {
  testWidgets('ComputedWidget', (tester) async {
    final v = ValueNotifier(UniqueKey());
    final buildCnt = [0];

    await tester.pumpWidget(StatelessTestWidget(v, buildCnt));

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);

    var flag1 = false;

    // Redundant frame trap
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      flag1 = true;
    });

    await tester.pump();

    expect(flag1, false, reason: 'No unexpected frames');
    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);

    v.value = UniqueKey();
    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 4);

    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 4);
  });

  testWidgets('ComputedStatefulWidget', (tester) async {
    final v1 = ValueNotifier(UniqueKey());
    final v2 = ValueNotifier(UniqueKey());
    final buildCnt = [0];

    await tester.pumpWidget(StatefulTestWidget(v1, v2, buildCnt));

    expect(find.byKey(v1.value), findsOneWidget);
    expect(find.byKey(v2.value), findsOneWidget);
    expect(buildCnt[0], 2);

    await tester.pump();

    expect(find.byKey(v1.value), findsOneWidget);
    expect(find.byKey(v2.value), findsOneWidget);
    expect(buildCnt[0], 2);

    v1.value = UniqueKey();
    await tester.pump();

    expect(find.byKey(v1.value), findsOneWidget);
    expect(find.byKey(v2.value), findsOneWidget);
    expect(buildCnt[0], 4);

    await tester.pump();

    expect(find.byKey(v1.value), findsOneWidget);
    expect(find.byKey(v2.value), findsOneWidget);
    expect(buildCnt[0], 4);

    v2.value = UniqueKey();
    await tester.pump();

    expect(find.byKey(v1.value), findsOneWidget);
    expect(find.byKey(v2.value), findsOneWidget);
    expect(buildCnt[0], 6);

    await tester.pump();

    expect(find.byKey(v1.value), findsOneWidget);
    expect(find.byKey(v2.value), findsOneWidget);
    expect(buildCnt[0], 6);
  });

  testWidgets('ComputedBuilder', (tester) async {
    final v = ValueNotifier(UniqueKey());
    final buildCnt = [0];

    await tester.pumpWidget(ComputedBuilder(builder: (ctx) {
      buildCnt[0]++;
      return SizedBox.shrink(key: v.use);
    }));

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);

    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);

    v.value = UniqueKey();
    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 4);

    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
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
