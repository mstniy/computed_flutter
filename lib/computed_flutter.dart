export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/computed.dart';
import 'package:computed_flutter/src/computed_flutter.dart';
import 'package:computed_flutter/src/listenable_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'src/computed_listenable.dart';
import 'src/value_listenable_extension.dart';

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
  ListenableType get watch {
    final caller = GlobalCtx.currentComputation;
    caller.dataSourceUse<ComputedListenableExtensionUpdateToken>(
        this,
        (router) => ListenableDataSourceSubscription(this, router),
        () => ComputedListenableExtensionUpdateToken());
    return this;
  }
}

extension ComputedValueListenableExtension<T> on ValueListenable<T> {
  /// As [Stream.use]
  T get use {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceUse(
        this,
        (router) => ValueListenableDataSourceSubscription<T>(this, router),
        () => value);
  }

  /// As [Stream.react]
  void react(void Function(T) onData, [void Function(Object)? onError]) {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourceReact<T>(
        this,
        (router) => ValueListenableDataSourceSubscription<T>(this, router),
        () => value,
        onData,
        onError);
  }

  /// As [Stream.prev]
  T get prev {
    final caller = GlobalCtx.currentComputation;
    return caller.dataSourcePrev(this);
  }
}

mixin ComputedFlutterMixin on StatelessWidget {
  @override
  StatelessElement createElement() => ComputedFlutterElement(this);
}

abstract class ComputedWidget extends StatelessWidget {
  const ComputedWidget({super.key});

  @override
  StatelessElement createElement() => ComputedFlutterElement(this);
}

abstract class ComputedStatefulWidget extends StatefulWidget {
  const ComputedStatefulWidget({super.key});

  @override
  StatefulElement createElement() => ComputedFlutterStatefulElement(this);
}

class ComputedBuilder extends Builder with ComputedFlutterMixin {
  ComputedBuilder({super.key, required super.builder});
}
