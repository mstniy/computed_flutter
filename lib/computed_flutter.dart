export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/computed.dart';
import 'package:computed_flutter/src/computed_flutter.dart';
import 'package:computed_flutter/src/listenable_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'src/computed_listenable.dart';
export 'src/value_listenable_extension.dart';

extension ComputedAsValueListenableExtension<T> on Computed<T> {
  /// Returns a [ValueListenable] tracking this computation.
  ///
  /// Note that the value listenable will not be updated if the computation throws an exception.
  ValueListenable<T> asValueListenable(T initial) {
    return ComputedValueListenable(this, initial);
  }

  /// Returns a [ComputedListenable] tracking this computation.
  ///
  /// Note that this is more powerful than [asValueListenable] in that
  /// it makes it possible to handle errors and no-value cases.
  ComputedListenable<T> get asListenable {
    return ComputedListenable(this);
  }
}

extension ComputedListenableExtension<ListenableType extends Listenable>
    on ListenableType {
  /// Subscribes the current computation to this [Listenable] and returns it.
  ListenableType get watch {
    final caller = GlobalCtx.currentComputation;
    caller.dataSourceUse<ComputedListenableExtensionUpdateToken>(
        this,
        (router) => ListenableDataSourceSubscription(this, router),
        () => ComputedListenableExtensionUpdateToken());
    return this;
  }
}

/// Allows Computed to track reactive dependencies of the build method.
mixin ComputedFlutterMixin on StatelessWidget {
  @override
  StatelessElement createElement() => ComputedFlutterElement(this);
}

/// Allows Computed to track reactive dependencies of the build method.
mixin ComputedFlutterStatefulMixin on StatefulWidget {
  @override
  StatefulElement createElement() => ComputedFlutterStatefulElement(this);
}

/// A [StatelessWidget] the build method of which is tracked by Computed.
abstract class ComputedWidget extends StatelessWidget
    with ComputedFlutterMixin {
  const ComputedWidget({super.key});
}

/// A [StatefulWidget] the build method of which is tracked by Computed.
abstract class ComputedStatefulWidget extends StatefulWidget
    with ComputedFlutterStatefulMixin {
  const ComputedStatefulWidget({super.key});
}

/// As [Builder], but the builder is tracked by Computed.
class ComputedBuilder extends Builder with ComputedFlutterMixin {
  ComputedBuilder({super.key, required super.builder});
}
