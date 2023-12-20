import 'package:computed/computed.dart';
import 'package:flutter/widgets.dart';
import 'value_listenable_extension.dart';

class _Token {}

mixin _ComputedFlutterElementMixin on ComponentElement {
  final _forceRebuild = ValueNotifier(_Token());
  var _ignoreListener = true;
  ComputedSubscription<void>? _sub;
  Widget? _result;
  Object? _error;
  StackTrace? _trace;
  bool? _lastWasError; // If null: no cached result

  @override
  Widget build() {
    if (_lastWasError == null) {
      _ignoreListener = true;
      _forceRebuild.value = _Token();
    }
    _sub ??= Computed(() {
      _forceRebuild.react((p0) {}); // So that we can force rebuilds
      try {
        _result = super.build();
        _lastWasError = false;
      } catch (e, s) {
        _lastWasError = true;
        _error = e;
        _trace = s;
      }
    }, memoized: false)
        .listen((_) {
      if (!_ignoreListener) super.markNeedsBuild();
      _ignoreListener = false;
    }, null);
    assert(_lastWasError != null);
    try {
      if (_lastWasError == true) {
        Error.throwWithStackTrace(_error!, _trace!);
      } else {
        return _result!;
      }
    } finally {
      _lastWasError = null; // Delete the cached result
    }
  }

  @override
  void unmount() {
    _sub?.cancel();
    _sub = null;
    super.unmount();
  }

  @override
  void markNeedsBuild() {
    _lastWasError = null;
    super.markNeedsBuild();
  }
}

class ComputedFlutterElement extends StatelessElement
    with _ComputedFlutterElementMixin {
  ComputedFlutterElement(super.widget);
}

class ComputedFlutterStatefulElement extends StatefulElement
    with _ComputedFlutterElementMixin {
  ComputedFlutterStatefulElement(super.widget);
}
