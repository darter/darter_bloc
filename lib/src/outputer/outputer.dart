import '../lenient_subject/lenient_subject.dart';

/// This class is meant to be used as the output of a [BaseBloc] when said
/// output comes from a server, but can at the same time be affected by user
/// interactions with the interface. For example, if the BLoC is meant to
/// communicate a list of elements retrieved from the server to the interface,
/// but the user can interact with said elements, from that same interface,
/// causing changes to the elements in the server, then an outputer class would
/// be used as a wrapper around the typical [LenientSubject].
abstract class Outputer<T> {
  final LenientSubject<T> delegate;

  Outputer() : delegate = LenientSubject(ignoreRepeated: true);

  Stream<T?> get stream => delegate.stream;

  bool get hasValue => delegate.hasValue;

  T? get value => delegate.value;

  set value(T? newValue) => delegate.add(newValue);

  // Add a new local value (created by a user interaction).
  void add(T event);

  // Add a new server value (created by changes in the server's database).
  void update(T event);

  // Discard the local value and use the last server value instead.
  void reset();

  Future<dynamic> close() => delegate.close();
}
