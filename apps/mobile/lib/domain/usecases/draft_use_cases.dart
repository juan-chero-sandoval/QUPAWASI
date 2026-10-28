import '../entities/recycling_draft.dart';
import '../policies/local_validation.dart';
import '../repositories/draft_repository.dart';

class DraftUseCases {
  const DraftUseCases(this._drafts);
  final DraftRepository _drafts;

  Future<RecyclingDraft?> load(String key) async {
    LocalValidation.id(key);
    return _drafts.load(key);
  }

  Future<void> save(RecyclingDraft draft) async {
    LocalValidation.draft(draft);
    await _drafts.save(draft);
  }

  Future<void> clear(String key) async {
    LocalValidation.id(key);
    await _drafts.clear(key);
  }
}
