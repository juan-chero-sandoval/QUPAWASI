import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/errors/local_data_exception.dart';

/// Owns one domain stream and suppresses callbacks after disposal/retry.
class LocalStreamViewModel<T> extends ChangeNotifier {
  LocalStreamViewModel(this._watch) {
    reload();
  }
  final Stream<T> Function() _watch;
  StreamSubscription<T>? _subscription;
  T? data;
  String? error;
  bool loading = true;
  int _generation = 0;

  void reload() {
    final generation = ++_generation;
    unawaited(_subscription?.cancel());
    loading = true;
    error = null;
    _subscription = _watch().listen(
      (value) {
        if (generation != _generation) return;
        data = value;
        loading = false;
        notifyListeners();
      },
      onError: (Object failure) {
        if (generation != _generation) return;
        error = localMessage(failure);
        loading = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _generation++;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}

String localMessage(Object error) => error is LocalDataException
    ? error.message
    : 'No se pudo acceder al almacenamiento local. Intenta de nuevo.';
