import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/admin_inputs.dart';
import '../../domain/entities/reward.dart';
import '../rewards/rewards_view.dart' show categoryLabel;
import 'admin_form_scaffold.dart';
import 'admin_reward_form_view_model.dart';
import 'admin_rewards_view.dart' show rewardIcon;

/// Crear (`/admin/rewards/new`) o editar (`/admin/rewards/:rewardId`) una
/// recompensa del catálogo de canjes simulados.
class AdminRewardFormView extends StatelessWidget {
  const AdminRewardFormView({super.key, this.rewardId});

  final String? rewardId;

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AppDependencies>().local.admin!;
    return ChangeNotifierProvider(
      key: ValueKey(rewardId),
      create: (_) =>
          AdminRewardFormViewModel(admin: admin, entityId: rewardId)..load(),
      child: const _RewardForm(),
    );
  }
}

class _RewardForm extends StatefulWidget {
  const _RewardForm();

  @override
  State<_RewardForm> createState() => _RewardFormState();
}

class _RewardFormState extends State<_RewardForm> {
  final _title = TextEditingController();
  final _cost = TextEditingController();
  final _description = TextEditingController();

  late final AdminRewardFormViewModel _vm = context
      .read<AdminRewardFormViewModel>();

  void _syncAll() {
    _title.text = _vm.title;
    _cost.text = _vm.costText;
    _description.text = _vm.description;
  }

  @override
  void dispose() {
    for (final c in [_title, _cost, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormScaffold(
      viewModel: _vm,
      newTitle: 'Nueva recompensa',
      editTitle: 'Editar recompensa',
      entityName: 'recompensa',
      onEditingStarted: _syncAll,
      fields: (context) {
        final vm = context.watch<AdminRewardFormViewModel>();
        final error = Theme.of(context).colorScheme.error;
        return [
          TextField(
            key: const Key('reward-title'),
            controller: _title,
            onChanged: vm.setTitle,
            maxLength: AdminLimits.rewardTitleMax,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Título',
              errorText: vm.titleError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Categoría', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final category in RewardCategory.values)
                ChoiceChip(
                  avatar: Icon(rewardIcon(category), size: 18),
                  label: Text(categoryLabel(category)),
                  selected: vm.category == category,
                  onSelected: (_) => vm.setCategory(category),
                ),
            ],
          ),
          if (vm.categoryError != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                vm.categoryError!,
                style: TextStyle(color: error, fontSize: 12),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('reward-cost'),
            controller: _cost,
            onChanged: vm.setCost,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Costo',
              suffixText: 'pts',
              errorText: vm.costError,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            key: const Key('reward-description'),
            controller: _description,
            onChanged: vm.setDescription,
            maxLength: AdminLimits.descriptionMax,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Descripción (opcional)',
              errorText: vm.descriptionError,
              border: const OutlineInputBorder(),
            ),
          ),
        ];
      },
    );
  }
}
