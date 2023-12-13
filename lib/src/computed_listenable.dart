import 'package:computed/computed.dart';
import 'package:flutter/foundation.dart';

class ComputedListenable<T> extends ChangeNotifier {
  final Computed<T> _parent;
  ComputedSubscription<T>? _parentSubscription;

  bool? _lastWasError;
  T? _lastValue;
  Object? _lastError;

  /// If the computation has no value yet, throws [NoValueException].
  /// If the computation produced an error, throws it.
  T get value {
    if (_lastWasError == null) throw NoValueException();
    if (_lastWasError == false) return _lastValue!;
    throw _lastError!;
  }

  ComputedListenable(this._parent);

  @override
  void addListener(VoidCallback listener) {
    var firstListener = !hasListeners;
    super.addListener(listener);
    if (firstListener) {
      assert(_parentSubscription == null);
      _parentSubscription = _parent.listen((event) {
        _lastWasError = false;
        _lastValue = event;
        notifyListeners();
      }, (error) {
        _lastWasError = true;
        _lastError = error;
        notifyListeners();
      });
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!hasListeners) return;
    assert(_parentSubscription != null);
    super.removeListener(listener);
    if (!hasListeners) {
      _parentSubscription!.cancel();
      _parentSubscription = null;
    }
  }
}

class ComputedValueListenable<T> extends ComputedListenable<T>
    implements ValueListenable<T> {
  ComputedValueListenable(super.parent, T initial) {
    _lastWasError = false;
    _lastValue = initial;
  }
}
