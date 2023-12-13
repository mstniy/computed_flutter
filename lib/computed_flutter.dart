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
import 'src/computed_value_listenable.dart';

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

  /// Returns a widget that rebuilds when the result of this computation changes.
  ///
  /// If [error] is not specified and this computation throws, will throw the error during build.
  Widget when(Widget Function(BuildContext, T) onValue,
      {Key? key,
      required Widget Function(BuildContext) noValue,
      Widget Function(BuildContext, Object)? error}) {
    final listenable = asListenable;
    return ListenableBuilder(
        builder: (context, child) {
          T value;
          try {
            value = listenable.value;
          } on NoValueException {
            return noValue(context);
          } catch (e) {
            if (error != null) return error(context, e);
            rethrow;
          }
          return onValue(context, value);
        },
        listenable: listenable,
        key: key);
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

  /// As [Stream.mockEmit]
  void mockEmit(T value) {
    GlobalCtx.routerFor(this)?.onDataSourceData(value);
  }

  /// As [Stream.mockEmitError]
  void mockEmitError(Object e) {
    GlobalCtx.routerFor(this)?.onDataSourceError(e);
  }
}

extension ComputedListenableExtension<T> on Listenable {
  /// Returns a computation representing the application of the given function on this Listenable.
  ///
  /// Note that the given function is not called until the computation is eventually listened to.
  Computed<T> select(T Function() user) {
    return Computed(() {
      final caller = GlobalCtx.currentComputation;
      return caller.dataSourceUse(
          this,
          (router) => ListenableDataSourceSubscription<T>(this, router, user),
          () => checkIdempotent(user));
    });
  }
}

mixin ComputedFlutterMixin on StatelessWidget {
  @override
  StatelessElement createElement() => ComputedFlutterElement(this);
  // TODO: Make CFE wrap super.createElement to play ball with other mixins
  //  This will also let us define the mixin on not just StatelessWidget,
  //  but Widget in general
}

abstract class ComputedWidget extends StatelessWidget {
  const ComputedWidget({super.key});

  @override
  StatelessElement createElement() => ComputedFlutterElement(this);
}

class ComputedBuilder extends Builder with ComputedFlutterMixin {
  ComputedBuilder({super.key, required super.builder});
}
