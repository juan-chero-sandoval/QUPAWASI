import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qupa_wasi/app/routes.dart';

import 'helpers/native_app.dart';
import '../test/helpers/qr_payload.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'QR: confirmar, reabrir SQLite, reescanear y eliminar sin duplicar puntos',
    (tester) async {
      final app = NativeApp();
      final depositId = 'native-qr-${DateTime.now().microsecondsSinceEpoch}';
      final raw = qrPayload(id: depositId);
      await app.open(tester, AppRoutes.home);
      await app.settings.completeOnboarding();
      final baseline =
          (await app.deps.local.overview.getStatistics()).availablePoints;
      await app.close(tester);
      await app.open(tester, AppRoutes.newRecord(), scanQr: () async => raw);
      await tapVisible(tester, find.text('Escanear QR'));
      await waitVisible(tester, find.text('Confirmar reciclaje'));
      expect(find.text('PET × 2'), findsOneWidget);
      expect(find.byKey(const Key('quantity-field')), findsNothing);
      await tapVisible(tester, find.text('Confirmar reciclaje'));
      await waitVisible(tester, find.text('Detalle del registro'));
      final records = await app.deps.local.recycling.watch().first;
      final record = records.singleWhere((r) => r.depositId == depositId);
      expect(
        (await app.deps.local.overview.getStatistics()).availablePoints,
        baseline + 20,
      );
      expect(find.text('Editar'), findsNothing);
      await tapVisible(tester, find.text('Editar nota'));
      await enterNativeText(
        tester,
        find.byType(TextField),
        'Nota QR persistente',
      );
      await tapVisible(tester, find.text('Guardar nota'));
      await waitVisible(tester, find.text('Nota QR persistente'));
      await app.close(tester);

      await app.open(tester, AppRoutes.newRecord(), scanQr: () async => raw);
      await tapVisible(tester, find.text('Escanear QR'));
      await tapVisible(tester, find.text('Confirmar reciclaje'));
      await waitVisible(tester, find.text('Detalle del registro'));
      expect(
        (await app.deps.local.recycling.watch().first).where(
          (r) => r.depositId == depositId,
        ),
        hasLength(1),
      );
      expect(
        (await app.deps.local.overview.getStatistics()).availablePoints,
        baseline + 20,
      );
      await tapVisible(tester, find.text('Eliminar'));
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await waitVisible(tester, find.text('Mis registros'));
      await app.close(tester);

      await app.open(tester, AppRoutes.newRecord(), scanQr: () async => raw);
      await tapVisible(tester, find.text('Escanear QR'));
      await tapVisible(tester, find.text('Confirmar reciclaje'));
      await waitVisible(tester, find.textContaining('registrado y eliminado'));
      expect(await app.deps.local.recycling.get(record.id), isNull);
      expect(
        (await app.deps.local.overview.getStatistics()).availablePoints,
        baseline,
      );
      await app.close(tester);
    },
  );
}
