import 'dart:async';

import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

void main() {
  group('ValueListenable', () {
    test('can be used as a data source', () async {
      final v = ValueNotifier(1);

      // ignore: unnecessary_cast
      final c = Computed(() => (v as ValueListenable).use * 2);

      var expectation = 2;
      var subCnt = 0;

      final sub = c.listen((event) {
        subCnt++;
        expect(event, expectation);
      }, (e) => fail(e.toString()));

      try {
        expect(subCnt, 0);
        await Future.value();
        expect(subCnt, 1);
        v.value = 1;
        expect(subCnt, 1);
        expectation = 4;
        v.value = 2;
        expect(subCnt, 2);
      } finally {
        sub.cancel();
      }
    });
    test('can be used as a data sink', () async {
      final controller = StreamController<int>.broadcast(
          sync: true); // Use a broadcast stream to make debugging easier
      final source = controller.stream;
      final c = Computed(() => source.use);
      final l = c.asValueListenable(0);
      var listenerCnt = 0;
      listener() {
        listenerCnt++;
      }

      l.addListener(listener);
      try {
        expect(l.value, 0);
        await Future.value();
        expect(listenerCnt, 0);
        controller.add(1);
        await Future.value();
        expect(l.value, 1);
        expect(listenerCnt, 1);
        controller.add(1);
        await Future.value();
        expect(l.value, 1);
        expect(listenerCnt, 1);
        controller.add(2);
        await Future.value();
        expect(l.value, 2);
        expect(listenerCnt, 2);
      } finally {
        l.removeListener(listener);
      }
    });
  });
}
