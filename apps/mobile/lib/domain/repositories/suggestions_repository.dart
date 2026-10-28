import '../entities/local_suggestion.dart';

abstract interface class SuggestionsRepository {
  Future<List<LocalSuggestion>> list();
  Future<LocalSuggestion> create(String message);
  Future<void> delete(String id);
}
