import 'package:flutter/foundation.dart';

import '../../domain/entities/local_suggestion.dart';
import '../../domain/usecases/suggestions_use_cases.dart';
import '../common/local_stream_view_model.dart';

class SuggestionsViewModel extends ChangeNotifier {
  SuggestionsViewModel(this._suggestions) {
    load();
  }
  final SuggestionsUseCases _suggestions;
  List<LocalSuggestion> items = const [];
  bool loading = true;
  bool busy = false;
  bool _disposed = false;
  String? error;
  String? fieldError;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      items = await _suggestions.list();
    } catch (e) {
      error = localMessage(e);
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<bool> save(String text) async {
    if (busy) return false;
    busy = true;
    fieldError = null;
    error = null;
    _notify();
    var saved = false;
    try {
      await _suggestions.create(text);
      saved = true;
      await load();
    } catch (e) {
      fieldError = localMessage(e);
    } finally {
      busy = false;
      _notify();
    }
    return saved;
  }

  Future<void> delete(String id) async {
    if (busy) return;
    busy = true;
    _notify();
    try {
      await _suggestions.delete(id);
      await load();
    } catch (e) {
      error = localMessage(e);
    } finally {
      busy = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
