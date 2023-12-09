import 'dart:async';

import 'package:flutter/foundation.dart';

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
