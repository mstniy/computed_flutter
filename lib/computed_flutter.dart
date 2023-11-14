export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
import 'package:flutter/foundation.dart';

import 'src/computed_flutter.dart';

extension ComputedAsValueListenableExtension<T> on Computed<T> {
  ValueListenable<T> get asValueListenable =>
      ComputedAsValueListenableExtensionImpl<T>(this).asValueListenable;
}

extension ComputedValueListenableExtension<T> on ValueListenable<T> {
  T get use => ComputedValueListenableExtensionImpl<T>(this).use;
}
