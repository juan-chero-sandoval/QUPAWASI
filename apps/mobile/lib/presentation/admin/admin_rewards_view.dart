import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/brand_surfaces.dart';
import '../../core/widgets/state_message.dart';
import '../../domain/entities/reward.dart';
import '../common/local_state.dart';
import '../common/local_stream_view_model.dart';
import '../rewards/rewards_view.dart' show categoryLabel;

IconData rewardIcon(RewardCategory category) => switch (category) {
  RewardCategory.photocopies => Icons.print_outlined,
  RewardCategory.mobile => Icons.phone_android_outlined,
  RewardCategory.cafeteria => Icons.local_cafe_outlined,
};

/// Catálogo completo de recompensas para el administrador simulado.
class AdminRewardsView extends StatelessWidget {
  const AdminRewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AppDependencies>().local.admin!;
    return ChangeNotifierProvider(
      create: (_) => LocalStreamViewModel<List<Reward>>(admin.watchRewards),
      child: Consumer<LocalStreamViewModel<List<Reward>>>(
        builder: (context, vm, _) => AppPage(
          title: 'Recompensas',
          showBack: true,
          bottomAction: FilledButton.icon(
            onPressed: () => context.push(AppRoutes.newAdminReward()),
            icon: const Icon(Icons.add_card_outlined),
            label: const Text('Nueva recompensa'),
          ),
          children: [
            LocalState(
              vm: vm,
              builder: (rewards) => rewards.isEmpty
                  ? const StateMessage(
                      icon: Icons.card_giftcard_outlined,
                      title: 'Aún no hay recompensas',
                    )
                  : Column(
                      children: [
                        for (final reward in rewards)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _RewardTile(reward: reward),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.reward});

  final Reward reward;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AppCard(
      onTap: () => context.push(AppRoutes.editAdminReward(reward.id)),
      child: Row(
        children: [
          IconBadge(icon: rewardIcon(reward.category)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${categoryLabel(reward.category)} · ${reward.costPoints} pts',
                  style: TextStyle(color: palette.textMuted, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusPill(
            label: reward.isActive ? 'Activa' : 'Inactiva',
            icon: reward.isActive ? Icons.check_rounded : Icons.block_rounded,
            highlighted: reward.isActive,
          ),
        ],
      ),
    );
  }
}
