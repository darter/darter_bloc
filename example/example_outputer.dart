import 'package:darter_bloc/darter_bloc.dart';
import 'package:rxdart/rxdart.dart';

/// This way of handling user interactions with the interface assumes that your
/// server sends a new value through the channel, for every change on the data
/// that you are listening to. If that is not the case, you might want to use
/// a [ComparatorOutputer] instead of a [CounterOutputer], as in this example.
class OutputerBloc extends BaseBloc {
  // When many different streams can emit events asynchronously and then add
  // new events to just as many sinks, closing said streams and sinks in the
  // correct order when disposing of the BLoC is important, for avoiding
  // unexpected errors in your application. This can be a bit of a chore
  // for the programmer, but it can be avoided by using LenientSubject.
  LenientSubject<String> _first, _second;

  // The outputer will allow us to update the interface immediately after a
  // user interaction, while making sure to still reflect the actual server's
  // state on the interface, in real-time.
  CounterOutputer<String> _outputer;

  // Returns a stream of the desired output.
  Observable<String> get outputStream => _outputer.stream;

  // Consumes a required parameter (REQUIRED).
  Sink<String> get firstSink => _first.sink;

  // Consumes a parameter that will update the BLoC output.
  Sink<String> get secondSink => _second.sink;

  @override
  void initialize() {
    // By initializing the variables inside of this method, instead of when we
    // first declare them or in the constructor, we avoid memory leaks.
    _first = LenientSubject(ignoreRepeated: true);
    _second = LenientSubject(ignoreRepeated: true);
    _outputer = CounterOutputer();
    // As the LenientSubject has been configured to ignore repeated values,
    // this listener will only trigger when new values are received. In this
    // way we can avoid unnecessary calls to our server, and are performant.
    _first.stream.listen((String first) => _update(first));
    // User interactions are ignored if the changes they make are identical.
    _second.stream.listen((String second) {
      // We start by modifying the output according to the user input.
      _outputer.add(_outputer.value.replaceAll("example", second));
      // Then we make the call to our database manager that applies the changes
      // in the server. If the method call is successful, the output will be
      // updated with the new value from the server, thanks to the listener we
      // set up previous to this one. If not, we will undo the local changes,
      // as well as allow a single repeated value through the user input, as
      // it's possible that the user might want to make the same action again.
      Future.value(second).catchError((e)  {
        _outputer.reset();
        _second.allowNext();
        forwardException(e);
      });
    });

    super.initialize();
  }

  void _update(String first) {
    if (first != null) {
      // Here we would have made a call to our database manager, using the
      // various inputs for retrieving the value for the BLoC output.
      Stream.value("example").listen((value) => _outputer.update(value));
    }
  }

  @override
  Future dispose() {
    List<Future> futures = List();
    futures.add(_first.close());
    futures.add(_second.close());
    futures.add(_outputer.close());
    futures.add(super.dispose());
    return Future.wait(futures);
  }
}