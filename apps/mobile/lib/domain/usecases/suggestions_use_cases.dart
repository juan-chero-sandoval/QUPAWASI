import '../entities/local_suggestion.dart';
import '../policies/local_validation.dart';
import '../repositories/suggestions_repository.dart';

class SuggestionsUseCases {
  const SuggestionsUseCases(this._suggestions);
  final SuggestionsRepository _suggestions;

  Future<List<LocalSuggestion>> list() => _suggestions.list();
  Future<LocalSuggestion> create(String message) async =>
      _suggestions.create(LocalValidation.suggestion(message));
  Future<void> delete(String id) async {
    LocalValidation.id(id);
    await _suggestions.delete(id);
  }
}
