import 'outputer.dart';

/// This outputer uses a comparator function to determine whether or not the
/// new value from the server should replace the current local value.
class ComparatorOutputer<T> extends Outputer<T>{
  final bool Function(T local, T server) _comparator;

  T _local, _server;

  ComparatorOutputer([bool Function(T local, T server) comparator])
      : _comparator = comparator;

  @override
  void add(T event) {
    _local = event;
    delegate.add(event);
  }

  @override
  void update(T event) {
    _server = event;
    if (_comparator != null) {
      if (_comparator(_local, _server))
        delegate.add(event);
    } else delegate.add(event);
  }

  @override
  void reset() {
    _local = null;
    delegate.add(_server);
  }
}