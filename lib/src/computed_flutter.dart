import 'dart:async';

import 'package:flutter/foundation.dart';

import '../computed_flutter.dart';

// ignore: implementation_imports
import 'package:computed/src/computed.dart';

class ComputedValueListenable<T> extends ValueListenable<T> {
  final ComputedImpl<T> _parent;
  final Set<VoidCallback> _listeners = {};
  StreamSubscription<T>? _parentSubscription;

  ComputedValueListenable(this._parent);

  void _onData(T data) {
    for (var listener in _listeners) {
      listener();
    }
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    if (_listeners.length == 1) {
      // TODO: Use a lower-level integration instead of asStream
      // To keep a single source of truth for the listeners of the computation, inside ComputedImpl
      _parentSubscription = _parent.asStream.listen((event) => _onData(event));
      // ValueListenable does not propagate exceptions
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (_listeners.remove(listener)) {
      if (_listeners.isEmpty) {
        _parentSubscription!.cancel();
      }
    }
  }

  @override
  T get value {
    return _parent.value;
  }
}

class ComputedAsValueListenableExtensionImpl<T> {
  final Computed<T> c;

  ComputedAsValueListenableExtensionImpl(this.c);

  ValueListenable<T> get asValueListenable {
    return ComputedValueListenable(c as ComputedImpl<T>);
  }
}

class ValueListenableDataSourceSubscription<T>
    implements DataSourceSubscription<T> {
  final void Function() voidCallback;
  final ValueListenable<T> v;

  ValueListenableDataSourceSubscription(this.v, void Function(T data) onData)
      : voidCallback = (() => onData(v.value)) {
    v.addListener(voidCallback);
  }

  @override
  Future<void> cancel() {
    v.removeListener(voidCallback);
    return Future.value();
  }

  @override
  bool get isPaused => false;

  @override
  void pause([Future<void>? resumeSignal]) {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  void resume() {
    // TODO: implement resume
    throw UnimplementedError();
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
        (onData) => ValueListenableDataSourceSubscription<T>(v, onData),
        true,
        v.value);
  }
}
