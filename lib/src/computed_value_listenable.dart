import 'package:computed/computed.dart';
import 'package:flutter/foundation.dart';

class ComputedValueListenable<T> extends ValueNotifier<T> {
  final Computed<T> _parent;
  ComputedSubscription<T>? _parentSubscription;

  ComputedValueListenable(this._parent, T initial) : super(initial);

  @override
  void addListener(VoidCallback listener) {
    var firstListener = !hasListeners;
    super.addListener(listener);
    if (firstListener) {
      assert(_parentSubscription == null);
      _parentSubscription = _parent.listen((event) => value = event, null);
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
