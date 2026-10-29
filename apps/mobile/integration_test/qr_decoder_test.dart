import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qupa_wasi/domain/entities/deposit_qr.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('decodificador nativo Android lee PNG QR y contrato del tacho', (
    tester,
  ) async {
    final bytes = await rootBundle.load('assets/demo/deposit-qr.png');
    final temp = await getTemporaryDirectory();
    final file = File('${temp.path}/qupawasi-qr-decoder-test.png');
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    final controller = MobileScannerController(autoStart: false);
    try {
      final capture = await controller.analyzeImage(
        file.path,
        formats: [BarcodeFormat.qrCode],
      );
      expect(capture, isNotNull);
      final raw = capture!.barcodes
          .map((b) => b.rawValue)
          .whereType<String>()
          .single;
      final receipt = DepositQr.parse(raw);
      expect(receipt.depositId, 'demo-scanner-test-001');
      expect(receipt.input.quantity, 2);
      expect(receipt.latitude, 0);
      expect(receipt.longitude, 0);
    } finally {
      await controller.dispose();
      if (await file.exists()) await file.delete();
    }
  });
}
