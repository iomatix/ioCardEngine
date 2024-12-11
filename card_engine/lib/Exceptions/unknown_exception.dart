class UnknownException implements Exception {
  final String message;
  final dynamic cause;
  final StackTrace? stackTrace;

  UnknownException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() {
    if (cause != null && stackTrace != null) {
      return '''
UnknownException: $message
Caused by: ${cause.toString()}
StackTrace:
$stackTrace
''';
    } else if (cause != null) {
      return '''
UnknownException: $message
Caused by: ${cause.toString()}
''';
    } else if (stackTrace != null) {
      return '''
UnknownException: $message
StackTrace:
$stackTrace
''';
    } else {
      return 'UnknownException: $message';
    }
  }
}
