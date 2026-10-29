import '../../domain/entities/admin_inputs.dart';
import '../../domain/entities/reward.dart';
import 'admin_form_view_model.dart';

/// Formulario de recompensa: título, categoría, costo en puntos y descripción.
class AdminRewardFormViewModel extends AdminFormViewModel<Reward> {
  AdminRewardFormViewModel({
    required super.admin,
    super.entityId,
    super.clock,
    super.debounce,
  });

  String title = '';
  RewardCategory? category;
  String costText = '';
  String description = '';

  String? titleError;
  String? categoryError;
  String? costError;
  String? descriptionError;

  @override
  String get draftPrefix => 'admin-reward';

  void setTitle(String value) {
    title = value;
    titleError = null;
    changed();
  }

  void setCategory(RewardCategory value) {
    category = value;
    categoryError = null;
    changed();
  }

  void setCost(String value) {
    costText = value;
    costError = null;
    changed();
  }

  void setDescription(String value) {
    description = value;
    descriptionError = null;
    changed();
  }

  @override
  Future<Reward?> loadEntity(String id) => admin.getReward(id);

  @override
  bool entityIsActive(Reward entity) => entity.isActive;

  @override
  void applyEntity(Reward entity) {
    title = entity.title;
    category = entity.category;
    costText = '${entity.costPoints}';
    description = entity.description;
  }

  @override
  Map<String, Object?> toDraft() => {
    'title': title,
    'category': category?.name,
    'cost': costText,
    'description': description,
  };

  @override
  void applyDraft(Map<String, Object?> draft) {
    if (draft['title'] case final String value) title = value;
    if (draft['cost'] case final String value) costText = value;
    if (draft['description'] case final String value) description = value;
    category = RewardCategory.values
        .where((c) => c.name == draft['category'])
        .firstOrNull;
  }

  @override
  bool validate() {
    final trimmed = title.trim();
    titleError =
        trimmed.length < AdminLimits.rewardTitleMin ||
            trimmed.length > AdminLimits.rewardTitleMax
        ? 'Entre ${AdminLimits.rewardTitleMin} y ${AdminLimits.rewardTitleMax} '
              'caracteres.'
        : null;
    categoryError = category == null ? 'Elige una categoría.' : null;
    final cost = int.tryParse(costText.trim());
    costError =
        !RegExp(r'^\d+$').hasMatch(costText.trim()) ||
            cost == null ||
            cost < AdminLimits.costMin ||
            cost > AdminLimits.costMax
        ? 'Número entero entre ${AdminLimits.costMin} y ${AdminLimits.costMax}.'
        : null;
    descriptionError = description.trim().length > AdminLimits.descriptionMax
        ? 'Hasta ${AdminLimits.descriptionMax} caracteres.'
        : null;
    return titleError == null &&
        categoryError == null &&
        costError == null &&
        descriptionError == null;
  }

  RewardInput get _input => RewardInput(
    title: title.trim(),
    category: category!,
    costPoints: int.parse(costText.trim()),
    description: description.trim(),
  );

  @override
  Future<void> persist() async {
    if (isEditing) {
      await admin.updateReward(entityId!, _input);
    } else {
      await admin.createReward(_input);
    }
  }

  @override
  Future<void> deleteEntity(String id) => admin.deleteReward(id);

  @override
  Future<void> setEntityActive(String id, {required bool active}) =>
      admin.setRewardActive(id, active: active);
}
