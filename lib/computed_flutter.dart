export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/computed.dart';
import 'package:computed_flutter/src/listenable_extension.dart';
import 'package:flutter/foundation.dart';

import 'src/value_listenable_extension.dart';
import 'src/computed_value_listenable.dart';

extension ComputedAsValueListenableExtension<T> on Computed<T> {
  ValueListenable<T> asValueListenable(T initial) {
    return ComputedValueListenable(this, initial);
  }
}

extension ComputedValueListenableExtension<T> on ValueListenable<T> {
  /// As [Stream.use]
  T get use {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceUse(
        this,
        (router) => ValueListenableDataSourceSubscription<T>(this, router),
        () => value);
  }

  /// As [Stream.react]
  void react(void Function(T) onData, [void Function(Object)? onError]) {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceReact<T>(
        this,
        (router) => ValueListenableDataSourceSubscription<T>(this, router),
        () => value,
        onData,
        onError);
  }

  /// As [Stream.prev]
  T get prev {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourcePrev(this);
  }

  /// As [Stream.mockEmit]
  void mockEmit(T value) {
    GlobalCtx.routerFor(this)?.onDataSourceData(value);
  }

  /// As [Stream.mockEmitError]
  void mockEmitError(Object e) {
    GlobalCtx.routerFor(this)?.onDataSourceError(e);
  }
}

extension ComputedListenableExtension<T> on Listenable {
  Computed<T> select(T Function() user) {
    return Computed(() {
      final caller = GlobalCtx.currentComputation;
      return caller.dataSourceUse(
          this,
          (router) => ListenableDataSourceSubscription<T>(this, router, user),
          () => checkIdempotent(user));
    });
  }
}
