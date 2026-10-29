import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/widgets/simulation_chip.dart';

class QrCameraView extends StatefulWidget {
  const QrCameraView({super.key});
  @override
  State<QrCameraView> createState() => _QrCameraViewState();
}

class _QrCameraViewState extends State<QrCameraView>
    with WidgetsBindingObserver {
  final controller = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );
  bool finished = false;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(start());
  }

  Future<void> start() async {
    try {
      await controller.start();
    } catch (_) {
      if (mounted) {
        setState(
          () => error = 'No se pudo activar la cámara. Revisa el permiso en Ajustes y reintenta.',
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // El diálogo de permiso también genera inactive. No reiniciar sin permiso.
    if (!controller.value.hasCameraPermission) return;
    if (state == AppLifecycleState.resumed && !finished) {
      unawaited(start());
    } else if (state != AppLifecycleState.resumed) {
      unawaited(controller.stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Escanear QR'),
      actions: const [SimulationChip(), SizedBox(width: 8)],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: error != null
                ? Center(child: Text(error!))
                : MobileScanner(
                    controller: controller,
                    errorBuilder: (context, exception) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Cámara no disponible. Habilita el permiso de cámara en Ajustes y reintenta.',
                        ),
                      ),
                    ),
                    onDetect: (capture) {
                      final raw = capture.barcodes
                          .map((b) => b.rawValue)
                          .whereType<String>()
                          .firstOrNull;
                      if (finished || raw == null) return;
                      finished = true;
                      unawaited(controller.stop());
                      Navigator.of(context).pop(raw);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => error = null);
                unawaited(start());
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar cámara'),
            ),
          ),
        ],
      ),
    ),
  );
}
