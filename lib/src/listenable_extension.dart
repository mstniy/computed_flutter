import 'dart:async';

import 'package:flutter/foundation.dart';

// ignore: implementation_imports
import 'package:computed/src/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/data_source_subscription.dart';

class ComputedListenableExtensionUpdateToken {}

class ListenableDataSourceSubscription
    implements DataSourceSubscription<ComputedListenableExtensionUpdateToken> {
  final ComputedImpl<ComputedListenableExtensionUpdateToken> c;
  final Listenable l;

  void callback() {
    c.onDataSourceData(ComputedListenableExtensionUpdateToken());
  }

  ListenableDataSourceSubscription(this.l, this.c) {
    l.addListener(callback);
  }

  @override
  Future<void> cancel() {
    l.removeListener(callback);
    return Future.value();
  }
}
