export 'package:computed/computed.dart';
import 'package:computed/computed.dart';
// ignore: implementation_imports
import 'package:computed/src/computed.dart';
import 'package:computed_flutter/src/listenable_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'src/computed_listenable.dart';
import 'src/value_listenable_extension.dart';
import 'src/computed_value_listenable.dart';

class _ComputedMetadata<T> {
  bool? _lastWasValue;
  T? _lastValue;
  Object? _lastError;
}

class _ComputedFlutterCtx {
  static final _computations = <Computed, _ComputedMetadata>{};
  static final _listeners =
      <BuildContext, Map<Computed, ComputedSubscription>>{};
  static var _postFrameCallbackScheduled = false;
}

void _postFrameCallback(Duration _) {
  // TODO: Also garbage collect individual listeners, in case a widget stop listening a computation from one frame to another
  // "Garbage-collect" unmounted BuildContexts
  for (var kv in _ComputedFlutterCtx._listeners.entries) {
    if (kv.key.mounted == false) {
      for (var sub in kv.value.values) {
        sub.cancel();
      }
      _ComputedFlutterCtx._listeners.remove(kv.key);
    }
  }
}

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

  /// Runs the given builders whenever the result of this computation changes.
  ///
  /// If [error] is not specified, will throw the error if this computation throws.
  Widget when(BuildContext context, Widget Function(T) onValue,
      {Key? key,
      required Widget Function() noValue,
      Widget Function(Object)? error}) {
    final listenable = asListenable;
    return ListenableBuilder(
        builder: (context, child) {
          T value;
          try {
            value = listenable.value;
          } on NoValueException {
            return noValue();
          } catch (e) {
            if (error != null) return error(e);
            rethrow;
          }
          return onValue(value);
        },
        listenable: listenable,
        key: key);
  }

  /// Returns the current result of the computation, or [or] if it has no result yet, and marks the current widget for re-builds whenever it changes.
  ///
  /// If [or] is not provided and the computation has no value, throws [NoValueException].
  T watch(BuildContext context, {T Function()? or}) {
    var metadata = _ComputedFlutterCtx._computations[this];
    if (metadata == null) {
      metadata = _ComputedMetadata();
      _ComputedFlutterCtx._computations[this] = metadata;
    }
    listenerCommon() {
      assert(
          SchedulerBinding.instance.schedulerPhase !=
              SchedulerPhase.persistentCallbacks,
          'Do not mutate state (by setting the value of the ValueNotifier '
          'that you are subscribed to) during a `build` method. If you need '
          'to schedule a value update after `build` has completed, use '
          '`SchedulerBinding.instance.scheduleTask(updateTask, Priority.idle)`, '
          '`SchedulerBinding.addPostFrameCallback(updateTask)`, '
          'or similar.');
      // Mark the element as needing to be rebuilt
      (context as Element).markNeedsBuild();
    }

    valueListener(T event) {
      listenerCommon();
      metadata!._lastWasValue = true;
      metadata._lastValue = event;
    }

    errorListener(Object error) {
      listenerCommon();
      metadata!._lastWasValue = false;
      metadata._lastError = error;
    }

    _ComputedFlutterCtx._listeners
        .putIfAbsent(context, () => <Computed, ComputedSubscription>{})
        .putIfAbsent(this, () => listen(valueListener, errorListener));

    if (!_ComputedFlutterCtx._postFrameCallbackScheduled) {
      _ComputedFlutterCtx._postFrameCallbackScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _ComputedFlutterCtx._postFrameCallbackScheduled = false;
        SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
      });
    }

    if (metadata._lastWasValue == null) {
      if (or != null) {
        return or();
      } else {
        throw NoValueException();
      }
    } else if (metadata._lastWasValue == true) {
      return metadata._lastValue;
    } else {
      throw metadata._lastError!;
    }
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
