import 'package:computed/computed.dart';
import 'package:flutter/widgets.dart';
import 'value_listenable_extension.dart';

mixin _ComputedFlutterElementMixin on ComponentElement {
  final _forceRebuild = ValueNotifier<int>(0);
  ComputedSubscription<void>? _sub;
  Widget? _result;
  Object? _error;
  StackTrace? _trace;
  bool? _lastWasError;

  @override
  Widget build() {
    _sub ??= Computed(() {
      _forceRebuild.use; // So that we can force rebuilds
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
      super
          .markNeedsBuild(); // TODO: Doesn't this lead to an extra, unnecessary frame (not a user build) being drawn?
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
    _forceRebuild.value++;
  }

  // TODO: Do we need update/reassemble hooks also?
}

class ComputedFlutterElement extends StatelessElement
    with _ComputedFlutterElementMixin {
  ComputedFlutterElement(super.widget);
}

class ComputedFlutterStatefulElement extends StatefulElement
    with _ComputedFlutterElementMixin {
  ComputedFlutterStatefulElement(super.widget);
}
