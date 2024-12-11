class EngineNotInitializedException implements Exception {
  final String message;
  EngineNotInitializedException(this.message);

  @override
  String toString() => 'EngineNotInitializedException: $message';
}