import 'package:computed/computed.dart';
import 'package:flutter/foundation.dart';

class ComputedListenable<T> extends ChangeNotifier {
  final Computed<T> _parent;
  ComputedSubscription<T>? _parentSubscription;

  @protected
  bool? lastWasError;
  @protected
  T? lastValue;
  @protected
  Object? lastError;

  /// If the computation has no value yet, throws [NoValueException].
  /// If the computation produced an error, throws it.
  T get value {
    if (lastWasError == null) throw NoValueException();
    if (lastWasError == false) return lastValue!;
    throw lastError!;
  }

  ComputedListenable(this._parent);

  @override
  void addListener(VoidCallback listener) {
    var firstListener = !hasListeners;
    super.addListener(listener);
    if (firstListener) {
      assert(_parentSubscription == null);
      _parentSubscription = _parent.listen((event) {
        lastWasError = false;
        lastValue = event;
        notifyListeners();
      }, (error) {
        lastWasError = true;
        lastError = error;
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
