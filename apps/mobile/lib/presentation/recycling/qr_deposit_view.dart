import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/dependencies.dart';
import '../../app/routes.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/app_page.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_surfaces.dart';
import '../../core/theme/app_palette.dart';
import 'qr_camera_view.dart';
import 'qr_deposit_view_model.dart';
import 'record_format.dart';

class QrDepositView extends StatelessWidget {
  const QrDepositView({super.key, this.pointId});
  final String? pointId;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => QrDepositViewModel(
      deposits: context.read<AppDependencies>().local.deposits,
      overview: context.read<AppDependencies>().local.overview,
      expectedPointId: pointId,
    ),
    child: const _Body(),
  );
}

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool scanning = false;
  Future<void> scan() async {
    if (scanning) return;
    setState(() => scanning = true);
    final vm = context.read<QrDepositViewModel>();
    final adapter = context.read<AppDependencies>().scanQr;
    try {
      final raw = adapter != null
          ? await adapter()
          : await Navigator.of(context, rootNavigator: true).push<String>(
              MaterialPageRoute(builder: (_) => const QrCameraView()),
            );
      if (raw != null && mounted) {
        await vm.read(raw);
        if (mounted && vm.error != null) AppToast.error(context, vm.error!);
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'No se pudo abrir la cámara. Reintenta.');
      }
    } finally {
      if (mounted) setState(() => scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<QrDepositViewModel>();
    final receipt = vm.receipt;
    return AppPage(
      title: 'Registrar reciclaje',
      showBack: true,
      bottomAction: receipt == null
          ? FilledButton.icon(
              onPressed: scanning || vm.busy ? null : scan,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Escanear QR'),
            )
          : FilledButton.icon(
              onPressed: vm.busy
                  ? null
                  : () async {
                      final id = await vm.confirm();
                      if (!context.mounted) return;
                      if (id != null) {
                        AppToast.success(context, 'Reciclaje registrado');
                        context.go(AppRoutes.recordDetail(id));
                      } else if (vm.error != null) {
                        AppToast.error(context, vm.error!);
                      }
                    },
              icon: const Icon(Icons.check_rounded),
              label: Text(vm.busy ? 'Guardando…' : 'Confirmar reciclaje'),
            ),
      children: [
        Row(
          children: [
            Expanded(
              child: _ScanStep(
                number: '01',
                label: 'Escanea',
                active: receipt == null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ScanStep(
                number: '02',
                label: 'Confirma',
                active: receipt != null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (receipt == null) ...[
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Center(child: ScanEmblem()),
                const SizedBox(height: 24),
                Text(
                  'Escanea el recibo QR del tacho',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ] else ...[
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.point!.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  RecordFormat.quantity(
                    receipt.input.material,
                    receipt.input.quantity,
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                StatusPill(
                  label: '+${vm.points} EcoPuntos',
                  icon: Icons.eco_outlined,
                  highlighted: true,
                ),
                const SizedBox(height: 20),
                const Divider(),
                _ReceiptLine(
                  icon: Icons.schedule_outlined,
                  label: 'Fecha y hora',
                  value: RecordFormat.dateTime(
                    context,
                    receipt.input.occurredAt,
                  ),
                ),
                _ReceiptLine(
                  icon: Icons.location_on_outlined,
                  label: 'Ubicación',
                  value: '${receipt.latitude}, ${receipt.longitude}',
                ),
                _ReceiptLine(
                  icon: Icons.receipt_long_outlined,
                  label: 'Depósito',
                  value: receipt.depositId,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: vm.busy ? null : vm.clear,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Leer otro QR'),
          ),
        ],
      ],
    );
  }
}

class _ScanStep extends StatelessWidget {
  const _ScanStep({
    required this.number,
    required this.label,
    required this.active,
  });
  final String number;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      selected: active,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? p.notice : p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? p.brand : p.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: p.brand,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 20, color: p.brand)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: p.textMuted)),
                Text(value, style: TextStyle(fontSize: 14, color: p.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
