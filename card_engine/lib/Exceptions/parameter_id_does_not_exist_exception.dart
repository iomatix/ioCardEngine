class ParameterIdDoesNotExistException implements Exception {
  final String message;
  final String keyId;
  ParameterIdDoesNotExistException(this.message, {required this.keyId});

  @override
  String toString() => 'ParameterIdDoesNotExistException: $message [Id: $keyId]';
}