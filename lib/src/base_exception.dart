class Severity {
  static final int INFORMATION = 0;
  static final int WARNING = 1;
  static final int ERROR = 2;
}

/// A simple interface for exceptions that are to be forwarded from the backend
/// and then handled by the user interface, by for example showing a message.
abstract class BaseException implements Exception {
  int get severity;
  String get message;
  String toString();
}

/// Exception thrown when an action was attempted, but the target is currently
/// referenced elsewhere in the database, and it could cause unforeseen consequences.
class ReferencedException implements BaseException {
  final int severity = Severity.WARNING;
  final String message;

  ReferencedException([this.message = '']);

  String toString() {
    if (message.isEmpty) return "ReferencedException";
    return "ReferencedException: $message";
  }
}

/// Exception thrown when a value is missing in order to carry out an action.
class MissingValueException implements BaseException {
  final int severity = Severity.WARNING;
  final String message;

  MissingValueException([this.message = '']);

  String toString() {
    if (message.isEmpty) return "MissingValueException";
    return "MissingValueException: $message";
  }
}

/// Exception thrown when a forbidden value is provided to carry out an action.
class ForbiddenValueException implements BaseException {
  final int severity = Severity.WARNING;
  final String message;

  ForbiddenValueException([this.message = '']);

  String toString() {
    if (message.isEmpty) return "ForbiddenValueException";
    return "ForbiddenValueException: $message";
  }
}

/// Exception thrown when an action was completed successfully.
/// Certainly counter-intuitive, but useful nonetheless.
class SuccessfulException implements BaseException {
  final int severity = Severity.INFORMATION;
  final String message;
  final dynamic result;

  SuccessfulException([this.message = '', this.result]);

  String toString() {
    if (message.isEmpty) return "SuccessfulException";
    return "SuccessfulException: $message";
  }
}

/// Exception thrown when an action failed to complete.
class FailedException implements BaseException {
  final int severity = Severity.ERROR;
  final String message;

  FailedException([this.message = '']);

  String toString() {
    if (message.isEmpty) return "FailedException";
    return "FailedException: $message";
  }
}

/// Exception thrown when an action is not allowed.
class ForbiddenException implements BaseException {
  final int severity = Severity.ERROR;
  final String message;

  ForbiddenException([this.message = '']);

  String toString() {
    if (message.isEmpty) return "ForbiddenException";
    return "ForbiddenException: $message";
  }
}
