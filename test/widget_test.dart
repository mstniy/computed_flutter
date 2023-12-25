import 'dart:async';

import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
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

  testWidgets('widgets are built at build() time', (tester) async {
    final v = ValueNotifier(0);
    var nonReactive = UniqueKey();

    await tester.pumpWidget(ComputedBuilder(builder: (ctx) {
      v.use;
      return SizedBox.shrink(key: nonReactive);
    }));

    expect(find.byKey(nonReactive), findsOneWidget);

    v.value = 1;
    nonReactive = UniqueKey();

    await tester.pump();

    expect(find.byKey(nonReactive), findsOneWidget);
  });

  testWidgets('nested computed widgets work', (tester) async {
    final v = ValueNotifier(UniqueKey());
    final buildCnt = [0, 0];

    await tester.pumpWidget(ComputedBuilder(builder: (ctx) {
      buildCnt[0]++;
      v.use;
      return ComputedBuilder(builder: (ctx) {
        buildCnt[1]++;
        return SizedBox.shrink(key: v.use);
      });
    }));

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);
    expect(buildCnt[1], 2);

    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);
    expect(buildCnt[1], 2);

    v.value = UniqueKey();
    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 4);
    expect(buildCnt[1], 4);

    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 4);
    expect(buildCnt[1], 4);
  });

  testWidgets('swapping widgets on the same element works', (tester) async {
    final v = ValueNotifier(UniqueKey());
    final buildCnt = [0];

    builder() {
      final c = $(() => v.use);
      return ComputedBuilder(builder: (ctx) {
        buildCnt[0]++;
        return SizedBox.shrink(key: c.use);
      });
    }

    await tester.pumpWidget(builder());

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 2);

    await tester.pumpWidget(builder());

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 4);

    v.value = UniqueKey();
    await tester.pump();

    expect(find.byKey(v.value), findsOneWidget);
    expect(buildCnt[0], 6);
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

  testWidgets('unmounting elements cancels its listeners', (tester) async {
    final controller = StreamController(sync: true);
    final stream = controller.stream;

    await tester.pumpWidget(ComputedBuilder(builder: (ctx) {
      stream.useOr(0);
      return const SizedBox.shrink();
    }));

    expect(controller.hasListener, true);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(controller.hasListener, false);
  });
}
