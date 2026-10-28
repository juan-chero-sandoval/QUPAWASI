import '../entities/recycling_draft.dart';

abstract interface class DraftRepository {
  Future<RecyclingDraft?> load(String key);
  Future<void> save(RecyclingDraft draft);
  Future<void> clear(String key);
}
