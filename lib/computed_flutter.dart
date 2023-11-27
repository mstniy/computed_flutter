export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
import 'package:flutter/foundation.dart';

import 'src/value_listenable_extension.dart';
import 'src/computed_value_listenable.dart';

extension ComputedAsValueListenableExtension<T> on Computed<T> {
  ValueListenable<T> asValueListenable(T initial) =>
      ComputedAsValueListenableExtensionImpl<T>(this)
          .asValueListenable(initial);
}

extension ComputedValueListenableExtension<T> on ValueListenable<T> {
  T get use => ComputedValueListenableExtensionImpl<T>(this).use;
  T get useAll => ComputedValueListenableExtensionImpl<T>(this).useAll;
}
