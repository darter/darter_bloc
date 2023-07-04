import 'lenient_subject/lenient_subject.dart';
import 'base_exception.dart';

/// A BLoC especially configured to be acceded exclusively through
/// a [BaseProvider] or a [MultiBaseProvider], representing the core
/// concepts behind a proper BLoC. Only the fact that said BLoC should
/// have a [Stream] that forwards exceptions to be handled in the user
/// interface has been abstracted. The remaining concepts are in the example.
abstract class BaseBloc {
  LenientSubject<BaseException>? _exception;

  Stream<BaseException?>? get exceptionStream => _exception?.stream;

  dynamic forwardException(dynamic e) {
    if (e is BaseException?) {
      _exception?.add(e);
      return e;
    }
    throw e;
  }

  void initialize() => _exception = LenientSubject();

  Future dispose() => _exception?.close() ?? Future(() {});
}
