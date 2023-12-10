import 'package:flutter/foundation.dart';

import 'computed_listenable.dart';

class ComputedValueListenable<T> extends ComputedListenable<T>
    implements ValueListenable<T> {
  ComputedValueListenable(super.parent, T initial) {
    lastWasError = false;
    lastValue = initial;
  }
}
