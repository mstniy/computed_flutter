import 'dart:async';

import 'package:flutter/foundation.dart';

// ignore: implementation_imports
import 'package:computed/src/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/data_source_subscription.dart';

class _ValueListenableDataSourceSubscription<T>
    implements DataSourceSubscription<T> {
  final void Function() voidCallback;
  final ComputedImpl<T> c;
  final ValueListenable<T> v;

  _ValueListenableDataSourceSubscription(this.v, this.c)
      : voidCallback = (() => c.onDataSourceData(v.value)) {
    v.addListener(voidCallback);
  }

  @override
  Future<void> cancel() {
    v.removeListener(voidCallback);
    return Future.value();
  }
}

extension ComputedValueListenableExtension<T> on ValueListenable<T> {
  /// As [Stream.use]
  T get use {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceUse(
        this,
        (router) => _ValueListenableDataSourceSubscription<T>(this, router),
        () => value);
  }

  /// As [Stream.react]
  void react(void Function(T) onData, [void Function(Object)? onError]) {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceReact<T>(
        this,
        (router) => _ValueListenableDataSourceSubscription<T>(this, router),
        () => value,
        onData,
        onError);
  }

  /// As [Stream.prev]
  T get prev {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourcePrev(this);
  }
}
