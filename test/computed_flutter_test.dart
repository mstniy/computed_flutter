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

        final c = Computed(() {
          cCnt++;
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
          expectation = 4;
          v.value = 2;
          expect(cCnt, 4);
          expect(subCnt, 2);
        } finally {
          sub.cancel();
        }
      });

      test('useAll works', () async {
        final v = _TestDataSource(1);

        var cCnt = 0;

        final c = Computed(() {
          cCnt++;
          return v.useAll * 2;
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
          expect(cCnt, 4);
          expect(subCnt, 1);
          expectation = 4;
          v.value = 2;
          expect(cCnt, 6);
          expect(subCnt, 2);
        } finally {
          sub.cancel();
        }
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
}
