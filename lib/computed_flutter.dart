export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/computed.dart';
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
        true,
        value);
  }

  /// As [Stream.react]
  void react(void Function(T) onData, [void Function(Object)? onError]) {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceReact<T>(
        this,
        (router) => ValueListenableDataSourceSubscription<T>(this, router),
        true,
        value,
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
