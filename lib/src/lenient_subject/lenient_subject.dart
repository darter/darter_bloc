import 'dart:async';

import 'package:rxdart/rxdart.dart';

import 'start_with_error.dart';

/// Identical to [BehaviorSubject] other than it ignores all errors thrown when
/// calling a method after the [LenientSubject] has been closed. The idea is to
/// avoid having to handle said errors, when they can be safely ignored.
class LenientSubject<T> extends Subject<T?> implements Stream<T?> {
  final _Wrapper<T> _wrapper;
  final bool _ignoreRepeated;

  bool _allowNext = false;

  LenientSubject._(
    StreamController<T> controller,
    Stream<T> observable,
    this._wrapper,
    this._ignoreRepeated,
  ) : super(controller, observable);

  /// Constructs a [LenientSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// The [ignoreRepeated] parameter can be used so that, when adding a value
  /// that is identical to the previous one, the listeners are not triggered.
  ///
  /// See also [StreamController.broadcast]
  factory LenientSubject({
    Function()? onListen,
    Function()? onCancel,
    bool sync = false,
    bool ignoreRepeated = false,
  }) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>();

    return LenientSubject<T>._(
      controller,
      DeferStream<T>(_deferStream(wrapper, controller), reusable: true),
      wrapper,
      ignoreRepeated,
    );
  }

  /// Constructs a [LenientSubject], optionally pass handlers for
  /// [onListen], [onCancel] and a flag to handle events [sync].
  ///
  /// [seedValue] becomes the current [value] and is emitted immediately.
  ///
  /// The [ignoreRepeated] parameter can be used so that, when adding a value
  /// that is identical to the previous one, the listeners are not triggered.
  ///
  /// See also [StreamController.broadcast]
  factory LenientSubject.seeded(
    T seedValue, {
    Function()? onListen,
    Function()? onCancel,
    bool sync = false,
    bool ignoreRepeated = false,
  }) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast(
      onListen: onListen,
      onCancel: onCancel,
      sync: sync,
    );

    final wrapper = _Wrapper<T>.seeded(seedValue);

    return LenientSubject<T>._(
      controller,
      DeferStream<T>(_deferStream(wrapper, controller), reusable: true),
      wrapper,
      ignoreRepeated,
    );
  }

  static Stream<T> Function() _deferStream<T>(
      _Wrapper<T> wrapper, StreamController<T> controller) {
    return () {
      if (wrapper.latestIsError) {
        return controller.stream.transform(StartWithErrorStreamTransformer(
            wrapper.latestError, wrapper.latestStackTrace));
      } else if (wrapper.latestIsValue) {
        return controller.stream
            .transform(StartWithStreamTransformer(wrapper.latestValue!));
      }

      return controller.stream;
    };
  }

  @override
  void onAdd(T? event) => _wrapper.setValue(event);

  @override
  void onAddError(Object error, [StackTrace? stackTrace]) =>
      _wrapper.setError(error, stackTrace);

  @override
  Stream<T?> get stream => this;

  bool get hasValue => _wrapper.latestIsValue;

  T? get value => _wrapper.latestValue;

  /// Set and emit the new value
  set value(T? newValue) => add(newValue);

  /// Ignore the [_ignoreRepeated] flag.
  void allowNext() => _allowNext = true;

  @override
  void add(T? event) {
    try {
      if (_ignoreRepeated) {
        if (value != event || _allowNext) super.add(event);
      } else
        super.add(event);
      _allowNext = false;
    } catch (e) {
      return;
    }
  }

  @override
  Future<dynamic> close() {
    try {
      return super.close();
    } catch (e) {
      return Future(
        () => null,
      );
    }
  }
}

class _Wrapper<T> {
  T? latestValue;
  Object? latestError;
  StackTrace? latestStackTrace;

  bool latestIsValue = false, latestIsError = false;

  /// Non-seeded constructor
  _Wrapper();

  _Wrapper.seeded(this.latestValue) : latestIsValue = true;

  void setValue(T? event) {
    latestIsValue = true;
    latestIsError = false;

    latestValue = event;

    latestError = null;
    latestStackTrace = null;
  }

  void setError(Object error, [StackTrace? stackTrace]) {
    latestIsValue = false;
    latestIsError = true;

    latestValue = null;

    latestError = error;
    latestStackTrace = stackTrace;
  }
}
