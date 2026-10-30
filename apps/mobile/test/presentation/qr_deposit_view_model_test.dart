import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/presentation/recycling/qr_deposit_view_model.dart';

import '../helpers/fake_local_services.dart';
import '../helpers/qr_payload.dart';

void main() {
  test(
    'error al guardar conserva recibo y reintentar permite guardar',
    () async {
      final local = FakeLocal();
      final vm = QrDepositViewModel(
        deposits: local.services.deposits,
        overview: local.services.overview,
      );
      await vm.read(qrPayload());
      local.records.failNextWrite = const LocalDataException(
        LocalDataError.storage,
        'Error de disco',
      );
      expect(await vm.confirm(), isNull);
      expect(vm.error, 'Error de disco');
      expect(vm.receipt, isNotNull);
      expect(await vm.confirm(), isNotNull);
      expect(local.records.all, hasLength(1));
      vm.dispose();
    },
  );
  test('doble toque y dispose durante escritura no duplican ni notifican después de dispose', () async {
    final local = FakeLocal();
    final vm = QrDepositViewModel(
      deposits: local.services.deposits,
      overview: local.services.overview,
    );
    await vm.read(qrPayload());
    local.records.writeGate = Completer<void>();
    final first = vm.confirm();
    expect(await vm.confirm(), isNull);
    vm.dispose();
    local.records.writeGate!.complete();
    expect(await first, isNotNull);
    expect(local.records.createCalls, 1);
  });
}
