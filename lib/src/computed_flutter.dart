import 'package:computed/computed.dart';
import 'package:flutter/widgets.dart';
import 'value_listenable_extension.dart';

class _Token {}

mixin _ComputedFlutterElementMixin on ComponentElement {
  final _forceRebuild = ValueNotifier(_Token());
  var _buildToken = _Token(); // Hack to keep Computed from undoing the DAG
  var _dirty = false;
  var _ignoreListener = true;
  ComputedSubscription<_Token>? _sub;
  Widget? _result;
  Object? _error;
  StackTrace? _trace;
  bool? _lastWasError;

  @override
  Widget build() {
    if (_dirty) {
      _ignoreListener = true;
      _forceRebuild.value = _Token();
      _dirty = false;
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
      return _buildToken;
    }).listen((_) {
      _buildToken = _Token();
      if (!_ignoreListener) super.markNeedsBuild();
      _ignoreListener = false;
    }, null);
    if (_lastWasError == true) {
      Error.throwWithStackTrace(_error!, _trace!);
    } else {
      return _result!;
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
    _dirty = true;
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
