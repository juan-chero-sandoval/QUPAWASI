import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
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
    return AppPage(
      title: 'Recompensas',
      children: [
        BrandSurface(
          child: LocalState(
            vm: overview,
            builder: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.card_giftcard_outlined, color: p.accent, size: 28),
                const SizedBox(height: 16),
                Text(
                  'Tu saldo: ${stats.availablePoints} EcoPuntos',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: p.onBrandStrong),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige tu próxima recompensa.',
                  style: TextStyle(color: p.onBrandStrong, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Canjes simulados: sin entrega comercial, pagos ni transferencia de dinero.',
            style: TextStyle(
              color: p.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (vm.message != null)
          Semantics(liveRegion: true, child: Text(vm.message!)),
        if (vm.busy)
          const LinearProgressIndicator(
            semanticsLabel: 'Procesando canje local',
          ),
        if (!vm.ready && !vm.busy)
          OutlinedButton(
            onPressed: vm.restore,
            child: const Text('Recuperar confirmación'),
          ),
        if (vm.pending != null) ...[
          const Text(
            'Hay una confirmación pendiente. Reintentar recupera el mismo canje, incluso tras reiniciar.',
          ),
          FilledButton(
            onPressed: vm.busy ? null : () => vm.redeem(vm.pending!.rewardId),
            child: const Text('Reintentar canje pendiente'),
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
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in [null, ...RewardCategory.values])
              ChoiceChip(
                label: Text(categoryLabel(c)),
                selected: vm.category == c,
                onSelected: (_) => vm.filter(c),
              ),
          ],
        ),
        ListenableBuilder(
          listenable: vm.catalog,
          builder: (context, _) => LocalState(
            vm: vm.catalog,
            builder: (_) => Column(
              children: [
                if (vm.filtered.isEmpty)
                  const Text('No hay recompensas en esta categoría.'),
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
                          const SizedBox(height: 8),
                          Text(
                            reward.description,
                            style: TextStyle(fontSize: 14, color: p.textMuted),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${reward.costPoints} pts simulados',
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
                                      'Confirmar canje simulado',
                                      '${reward.title}: ${reward.costPoints} puntos. No entrega productos ni dinero.',
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
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Historial de canjes locales'),
        ),
        ListenableBuilder(
          listenable: vm.history,
          builder: (context, _) => LocalState(
            vm: vm.history,
            builder: (history) => Column(
              children: [
                if (history.isEmpty) const Text('Aún no hay canjes simulados.'),
                for (final r in history)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(r.titleSnapshot),
                        Text(
                          '${r.costSnapshot} pts · ${r.isActive ? "Activo" : "Cancelado"}',
                        ),
                        Text(RecordFormat.dateTime(context, r.createdAt)),
                        if (r.isActive)
                          OutlinedButton(
                            onPressed: vm.busy
                                ? null
                                : () async {
                                    if (await confirmLocal(
                                      context,
                                      'Cancelar canje simulado',
                                      '${r.titleSnapshot}: liberar ${r.costSnapshot} puntos una sola vez.',
                                      'Cancelar canje',
                                    )) {
                                      await vm.cancel(r.id);
                                    }
                                  },
                            child: const Text('Cancelar canje'),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
