import 'package:computed/computed.dart';
import 'package:flutter/widgets.dart';
// ignore: implementation_imports

mixin _ComputedFlutterElementMixin on ComponentElement {
  ComputedSubscription<int>? _sub;
  Widget? _result;
  Object? _error;
  int _buildCnt = 0;
  bool? _lastWasError;

  @override
  Widget build() {
    _sub ??= Computed(() {
      try {
        final newResult = super.build();
        if (_lastWasError == false && newResult == _result) {
          return _buildCnt;
        }
        _result = newResult;
        _lastWasError = false;
      } catch (e) {
        _lastWasError = true;
        _error = e;
      }
      return _buildCnt + 1;
    }).listen((newBuildCnt) {
      _buildCnt = newBuildCnt;
      markNeedsBuild();
    }, null);
    if (_lastWasError == true) {
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
