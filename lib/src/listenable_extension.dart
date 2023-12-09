import 'dart:async';

import 'package:flutter/foundation.dart';

// ignore: implementation_imports
import 'package:computed/src/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/data_source_subscription.dart';

T checkIdempotent<T>(T Function() f) {
  final res = f(); // TODO: What if the function throws?

  bool ast() {
    return f() == res;
  }

  assert(ast(), "Listenable selectors must be purely functional.");

  return res;
}

class ListenableDataSourceSubscription<T> implements DataSourceSubscription<T> {
  final ComputedImpl<T> c;
  final T Function() user;
  final Listenable l;

  void callback() {
    c.onDataSourceData(checkIdempotent(user));
  }

  ListenableDataSourceSubscription(this.l, this.c, this.user) {
    l.addListener(callback);
  }

  @override
  Future<void> cancel() {
    l.removeListener(callback);
    return Future.value();
  }
}
