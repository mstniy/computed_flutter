import 'dart:async';

import 'package:flutter/foundation.dart';

import '../computed_flutter.dart';

// ignore: implementation_imports
import 'package:computed/src/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/data_source_subscription.dart';

class ValueListenableDataSourceSubscription<T>
    implements DataSourceSubscription<T> {
  final void Function() voidCallback;
  final ComputedImpl<T> c;
  final ValueListenable<T> v;

  ValueListenableDataSourceSubscription(this.v, this.c)
      : voidCallback = (() => c.onDataSourceData(v.value)) {
    v.addListener(voidCallback);
  }

  @override
  Future<void> cancel() {
    v.removeListener(voidCallback);
    return Future.value();
  }
}

class ComputedValueListenableExtensionImpl<T> {
  final ValueListenable<T> v;

  ComputedValueListenableExtensionImpl(this.v);
  T get use {
    final caller = GlobalCtx.currentComputation;
    return caller.useDataSource(
        v,
        () => v.use,
        (router) => ValueListenableDataSourceSubscription<T>(v, router),
        true,
        v.value,
        true);
  }
}
