enum LocalDataError {
  validation,
  notFound,
  insufficientPoints,
  committedPoints,
  conflict,
  storage,
}

/// Error de aplicación, independiente de SQLite y de Flutter.
class LocalDataException implements Exception {
  const LocalDataException(this.code, this.message);

  final LocalDataError code;
  final String message;

  @override
  String toString() => message;
}
