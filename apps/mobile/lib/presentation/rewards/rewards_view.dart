import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../core/widgets/state_message.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_surfaces.dart';
import '../../core/theme/app_palette.dart';
import '../../core/widgets/app_page.dart';
import '../../domain/entities/reward.dart';
import '../common/confirm_local.dart';
import '../common/local_state.dart';
import '../home/overview_view_model.dart';
import '../recycling/record_format.dart';
import 'rewards_view_model.dart';

String categoryLabel(RewardCategory? value) => switch (value) {
  null => 'Todas',
  RewardCategory.photocopies => 'Fotocopias',
  RewardCategory.mobile => 'Saldo móvil',
  RewardCategory.cafeteria => 'Cafetería',
};

class RewardsView extends StatelessWidget {
  const RewardsView({super.key, this.category});
  final String? category;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    key: ValueKey(category),
    create: (_) {
      final dependencies = context.read<AppDependencies>();
      final vm = RewardsViewModel(
        dependencies.local.rewards,
        dependencies.preferencesRepository,
      );
      vm.category = RewardCategory.values
          .where((c) => c.name == category)
          .firstOrNull;
      return vm;
    },
    child: const _RewardsBody(),
  );
}

class _RewardsBody extends StatelessWidget {
  const _RewardsBody();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RewardsViewModel>();
    final overview = context.watch<OverviewViewModel>();
    final balance = overview.data?.availablePoints;
    final p = AppPalette.of(context);
    final page = AppPage(
      title: 'Recompensas',
      children: [
        BrandSurface(
          child: LocalState(
            vm: overview,
            builder: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: p.accent,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tu saldo',
                      style: TextStyle(color: p.onBrandStrong, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.availablePoints} EcoPuntos',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: p.onBrandStrong),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (vm.busy)
          const LinearProgressIndicator(
            semanticsLabel: 'Procesando canje local',
          ),
        if (!vm.ready && !vm.busy)
          OutlinedButton.icon(
            onPressed: vm.restore,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Recuperar confirmación'),
          ),
        if (vm.pending != null) ...[
          FilledButton.icon(
            onPressed: vm.busy ? null : () => vm.redeem(vm.pending!.rewardId),
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Reintentar canje pendiente'),
          ),
          TextButton(
            onPressed: vm.busy
                ? null
                : () async {
                    if (await confirmLocal(
                      context,
                      'Cerrar confirmación pendiente',
                      'Revisa el historial: un canje ya guardado no se cancela al cerrar esta confirmación.',
                      'Cerrar confirmación',
                    )) {
                      await vm.dismissPending();
                    }
                  },
            child: const Text('Cerrar confirmación pendiente'),
          ),
          const SizedBox(height: 16),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final c in [null, ...RewardCategory.values])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(categoryLabel(c)),
                    selected: vm.category == c,
                    onSelected: (_) => vm.filter(c),
                  ),
                ),
            ],
          ),
        ),
        ListenableBuilder(
          listenable: vm.catalog,
          builder: (context, _) => LocalState(
            vm: vm.catalog,
            builder: (_) => Column(
              children: [
                if (vm.filtered.isEmpty)
                  const StateMessage(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Sin recompensas en esta categoría',
                  ),
                for (final reward in vm.filtered)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              IconBadge(
                                icon: switch (reward.category) {
                                  RewardCategory.photocopies =>
                                    Icons.print_outlined,
                                  RewardCategory.mobile =>
                                    Icons.phone_android_outlined,
                                  RewardCategory.cafeteria =>
                                    Icons.local_cafe_outlined,
                                },
                                size: 48,
                              ),
                              StatusPill(
                                label:
                                    balance != null &&
                                        balance >= reward.costPoints
                                    ? 'Disponible'
                                    : 'Bloqueado',
                                icon:
                                    balance != null &&
                                        balance >= reward.costPoints
                                    ? Icons.check
                                    : Icons.lock_outline,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            reward.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${reward.costPoints} pts',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              color: p.brand,
                            ),
                          ),
                          if (balance != null && balance < reward.costPoints)
                            Text(
                              'Te faltan ${reward.costPoints - balance} puntos',
                              style: TextStyle(
                                fontSize: 13,
                                color: p.textMuted,
                              ),
                            ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed:
                                vm.busy ||
                                    !vm.ready ||
                                    vm.pending != null ||
                                    overview.loading ||
                                    overview.error != null ||
                                    balance == null ||
                                    balance < reward.costPoints
                                ? null
                                : () async {
                                    if (await confirmLocal(
                                      context,
                                      '¿Canjear recompensa?',
                                      '${reward.title}: se descontarán ${reward.costPoints} puntos. Canje simulado, sin entrega real.',
                                      'Confirmar canje',
                                    )) {
                                      await vm.redeem(reward.id);
                                    }
                                  },
                            child: const Text('Canjear'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SectionHeader(title: 'Historial'),
        ListenableBuilder(
          listenable: vm.history,
          builder: (context, _) => LocalState(
            vm: vm.history,
            builder: (history) => Column(
              children: [
                if (history.isEmpty)
                  const StateMessage(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aún no hay canjes',
                  ),
                for (final r in history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r.titleSnapshot,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              StatusPill(
                                label: r.isActive ? 'Activo' : 'Cancelado',
                                icon: r.isActive
                                    ? Icons.check_rounded
                                    : Icons.block_rounded,
                                highlighted: r.isActive,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.costSnapshot} pts · '
                            '${RecordFormat.dateTime(context, r.createdAt)}',
                            style: TextStyle(color: p.textMuted, fontSize: 14),
                          ),
                          if (r.isActive) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: vm.busy
                                  ? null
                                  : () async {
                                      if (await confirmLocal(
                                        context,
                                        '¿Cancelar canje?',
                                        '${r.titleSnapshot}: liberar ${r.costSnapshot} puntos una sola vez.',
                                        'Cancelar canje',
                                      )) {
                                        await vm.cancel(r.id);
                                      }
                                    },
                              child: const Text('Cancelar canje'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
    return ToastListener(
      listenable: vm,
      message: () => vm.message,
      isError: () => vm.messageIsError,
      child: page,
    );
  }
}
