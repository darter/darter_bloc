import 'outputer.dart';

/// This outputer uses a simple counter to determine whether or not the
/// new value from the server should replace the current local value.
class CounterOutputer<T> extends Outputer<T>{
  int _counter = 0;
  T _server;

  @override
  void add(T event) {
    _counter = _counter + 1;
    delegate.add(event);
  }

  @override
  void update(T event) {
    _server = event;
    if (_counter > 0)
      _counter = _counter - 1;
    if (_counter == 0)
      delegate.add(event);
  }

  @override
  void reset() {
    _counter = 0;
    delegate.add(_server);
  }
}