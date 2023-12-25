// ignore: implementation_imports
import 'package:computed/src/computed.dart';
import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/widgets.dart';

class _FlutterComputedImpl extends ComputedImpl<void> {
  final ComponentElement _element;
  _FlutterComputedImpl(this._element, void Function() build)
      : super(build, false, false);

  @override
  void onDependencyUpdated() {
    // Delay until reeval() is called
    _element.markNeedsBuild();
  }

  void reeval() {
    super.onDependencyUpdated();
  }
}

class _Token {}

mixin _ComputedFlutterElementMixin on ComponentElement {
  final _forceRebuild = ValueNotifier(_Token());
  _FlutterComputedImpl? _c;
  ComputedSubscription<void>? _sub;
  Widget? _result;
  Object? _error;
  StackTrace? _trace;
  bool? _lastWasError; // If null: no cached result

  @override
  Widget build() {
    if (_lastWasError == null) {
      _forceRebuild.value = _Token();
    }
    _c ??= _FlutterComputedImpl(this, () {
      _forceRebuild.react((p0) {}); // So that we can force rebuilds
      try {
        _result = super.build();
        _lastWasError = false;
      } catch (e, s) {
        _lastWasError = true;
        _error = e;
        _trace = s;
      }
    });
    _sub ??= _c!.listen(null, null);
    _c!.reeval();
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
    _c = null;
    super.unmount();
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
