import 'package:computed/computed.dart';
import 'package:flutter/widgets.dart';
// ignore: implementation_imports

mixin _ComputedFlutterElementMixin on ComponentElement {
  ComputedSubscription<void>? _sub;
  Widget? _result;
  Object? _error;
  bool? _lastWasError;

  @override
  Widget build() {
    _sub ??= Computed(() {
      try {
        _result = super.build();
        _lastWasError = false;
      } catch (e) {
        _lastWasError = true;
        _error = e;
      }
    }, memoized: false)
        .listen((_) {
      markNeedsBuild();
    }, null);
    if (_lastWasError == null) {
      return const SizedBox
          .shrink(); // TODO: Allow .listen to return the result in the same microtask
    } else if (_lastWasError == true) {
      throw _error!;
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

  // TODO: Do we need update/reassemble hooks also?
}

class ComputedFlutterElement extends StatelessElement
    with _ComputedFlutterElementMixin {
  ComputedFlutterElement(super.widget);
}
