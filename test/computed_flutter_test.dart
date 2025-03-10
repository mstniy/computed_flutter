import 'dart:async';

import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';

class _TestDataSource<T> implements ValueListenable<T> {
  T _value;
  final _listeners = <void Function()>{};

  _TestDataSource(this._value);

  @override
  T get value => _value;
  set value(T newValue) {
    _value = newValue;
    for (var l in _listeners) {
      l();
    }
  }

  @override
  void addListener(void Function() l) {
    _listeners.add(l);
  }

  @override
  void removeListener(void Function() l) {
    _listeners.remove(l);
  }
}

void main() {
  group('ValueListenable', () {
    group('data source', () {
      test('use works', () async {
        final v = _TestDataSource(1);

        var cCnt = 0;
        int? prevExpectation; // If null, expect NVE

        final c = Computed(() {
          cCnt++;
          try {
            expect(v.prev, prevExpectation);
          } on NoValueException {
            expect(prevExpectation, null);
          }
          return v.use * 2;
        });

        var expectation = 2;
        var subCnt = 0;

        final sub = c.listen((event) {
          subCnt++;
          expect(event, expectation);
        }, (e) => fail(e.toString()));

        try {
          expect(cCnt, 2);
          expect(subCnt, 0);
          await Future.value();
          expect(cCnt, 2);
          expect(subCnt, 1);
          v.value = 1;
          expect(cCnt, 2);
          expect(subCnt, 1);
          prevExpectation = 1;
          expectation = 4;
          v.value = 2;
          expect(cCnt, 4);
          expect(subCnt, 2);
        } finally {
          sub.cancel();
        }
      });

      test('react works', () async {
        final v = _TestDataSource(1);

        var reactExpectation = 1;
        var cCnt = 0;

        final c = Computed(() {
          cCnt++;
          var flag = false;
          v.react((p0) {
            expect(flag, false);
            flag = true;
            expect(p0, reactExpectation);
          });
          expect(flag, true);
        });

        final sub = c.listen((event) {}, (e) => fail(e.toString()));

        expect(cCnt, 2);
        v.value = 1;
        expect(cCnt, 4);
        reactExpectation = 2;
        v.value = 2;
        expect(cCnt, 6);

        sub.cancel();
      });
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

  group('Listenable', () {
    group('data source', () {
      test('watch works', () async {
        final v = _TestDataSource(1);

        var cCnt = 0;

        // ignore: unnecessary_cast
        final c = $(() {
          cCnt++;
          return v.watch.value * 2;
        });

        var expectation = 2;
        var subCnt = 0;

        await Future.value(0);
        expect(cCnt, 0);

        final sub = c.listen((event) {
          subCnt++;
          expect(event, expectation);
        }, (e) => fail(e.toString()));

        expect(cCnt, 2);
        expect(subCnt, 0);
        await Future.value();
        expect(cCnt, 2);
        expect(subCnt, 1);
        v.value = 1;
        expect(cCnt, 4);
        expect(subCnt, 1);
        expectation = 4;
        v.value = 2;
        expect(cCnt, 6);
        expect(subCnt, 2);

        sub.cancel();
      });
    });
    group('data sink', () {
      test('asListenable works', () async {
        final controller = StreamController.broadcast(sync: true);
        final stream = controller.stream;
        var cCnt = 0;
        final c = $(() {
          cCnt++;
          return stream.use;
        });
        final l = c.asListenable;
        await Future.value();
        expect(cCnt, 0);
        var lCnt = 0;
        int? expectation; // If null, expect an exception
        int? errExpectation;
        l.addListener(() {
          lCnt++;
          if (expectation != null) {
            expect(l.value, expectation);
          } else {
            try {
              l.value;
              fail("Expected throw");
            } catch (e) {
              expect(e, errExpectation);
            }
          }
        });
        await Future.value();
        expect(cCnt, 2);
        expect(lCnt, 0);
        expectation = 0;
        controller.add(0);
        expect(cCnt, 4);
        expect(lCnt, 1);
        expectation = 1;
        controller.add(1);
        expect(cCnt, 6);
        expect(lCnt, 2);
        expectation = 2;
        expectation = null;
        errExpectation = 3;
        controller.addError(3);
        expect(cCnt, 7);
        expect(lCnt, 3);
      });
    });
  });
}
