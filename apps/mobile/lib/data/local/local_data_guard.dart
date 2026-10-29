import 'package:sqlite3/sqlite3.dart';

import '../../domain/errors/local_data_exception.dart';

Future<T> guardLocalData<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on LocalDataException {
    rethrow;
  } on SqliteException catch (error) {
    throw mapLocalDataError(error);
  } on Exception catch (error) {
    // Un error SQLite que cruza el isolate puede llegar envuelto por Drift.
    // Conservar el código de negocio sin exponer su mensaje SQL a la vista.
    throw mapLocalDataError(error);
  } on StateError {
    throw const LocalDataException(
      LocalDataError.storage,
      'El almacenamiento local no está disponible.',
    );
  }
}

LocalDataException mapLocalDataError(Object error) {
  final message = error.toString();
  if (message.contains('immutable_qr_record')) {
    return const LocalDataException(
      LocalDataError.conflict,
      'Los datos emitidos por el tacho no se pueden editar.',
    );
  }
  if (message.contains('committed_points')) {
    return const LocalDataException(
      LocalDataError.committedPoints,
      'Cancela primero un canje simulado para liberar puntos.',
    );
  }
  if (message.contains('insufficient_points')) {
    return const LocalDataException(
      LocalDataError.insufficientPoints,
      'No tienes suficientes EcoPuntos simulados.',
    );
  }
  if (message.contains('FOREIGN KEY') || message.contains('CHECK constraint')) {
    return const LocalDataException(
      LocalDataError.validation,
      'Los datos no son válidos para guardarlos.',
    );
  }
  if (message.contains('UNIQUE constraint') ||
      message.contains('immutable_redemption')) {
    return const LocalDataException(
      LocalDataError.conflict,
      'La operación entra en conflicto con un dato ya guardado.',
    );
  }
  return const LocalDataException(
    LocalDataError.storage,
    'No se pudo acceder al almacenamiento local. Intenta nuevamente.',
  );
}

Stream<T> guardLocalStream<T>(Stream<T> stream) =>
    stream.handleError((Object error, StackTrace stack) {
      Error.throwWithStackTrace(
        error is LocalDataException ? error : mapLocalDataError(error),
        stack,
      );
    });
