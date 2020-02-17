import 'package:darter_bloc/darter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ExampleBloc extends BaseBloc {
  // When many different streams can emit events asynchronously and then add
  // new events to just as many sinks, closing said streams and sinks in the
  // correct order when disposing of the BLoC is important, for avoiding
  // unexpected errors in your application. This can be a bit of a chore
  // for the programmer, but it can be avoided by using LenientSubject.
  LenientSubject<String> _first, _second, _third, _output;

  // Returns a stream of the desired output.
  Observable<String> get outputStream => _output.stream;

  // Consumes the first of the required parameters (REQUIRED).
  Sink<String> get firstSink => _first.sink;

  // Consumes the second of the required parameters (REQUIRED).
  Sink<String> get secondSink => _second.sink;

  // Consumes the third of the required parameters (REQUIRED).
  Sink<String> get thirdSink => _third.sink;

  @override
  void initialize() {
    // By initializing the variables inside of this method, instead of when we
    // first declare them or in the constructor, we avoid memory leaks.
    _first = LenientSubject(ignoreRepeated: true);
    _second = LenientSubject(ignoreRepeated: true);
    _third = LenientSubject(ignoreRepeated: true);
    _output = LenientSubject(ignoreRepeated: false);
    // As the LenientSubject have been configured to ignore repeated values,
    // these listeners will only trigger when new values are received. In this
    // way we can avoid unnecessary calls to our server, and are performant.
    _first.stream.listen((String first) =>
        _update(first, _second.value, _third.value));
    _second.stream.listen((String second) =>
        _update(_first.value, second, _third.value));
    _third.stream.listen((String third) =>
        _update(_first.value, _second.value, third));
    super.initialize();
  }

  void _update(String first, String second, String third) {
    // We generally want to have received a value for all required parameters.
    if (first != null && second != null && third != null) {
      // Here we would have made a call to our database manager, using the
      // various inputs for retrieving the value for the BLoC output.
      Stream.value("example").listen((value) => _output.add(value));
    }
  }

  @override
  Future dispose() {
    List<Future> futures = List();
    futures.add(_first.close());
    futures.add(_second.close());
    futures.add(_third.close());
    futures.add(_output.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}