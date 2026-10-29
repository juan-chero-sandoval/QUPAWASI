import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:qupa_wasi/domain/entities/deposit_qr.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';

import '../helpers/qr_payload.dart';

void main() {
  final now = DateTime.utc(2026, 10, 28, 15);
  test(
    'QR completo respeta zona horaria; ignora puntos declarados por el emisor',
    () {
      final json = jsonDecode(qrPayload()) as Map<String, dynamic>;
      json['points'] = 999999;
      final receipt = DepositQr.parse(jsonEncode(json), now: now);
      expect(receipt.input.occurredAt, now);
      expect(receipt.input.quantity, 2);
    },
  );
  for (final change in <Map<String, Object?>>[
    {'type': 'other'},
    {'version': 2},
    {'quantity': 0},
    {'quantity': 101},
    {'quantity': 1.5},
    {'material': 'glass'},
    {'depositId': ''},
    {'pointId': null},
    {'occurredAt': '2026-10-28T15:00:00'},
    {'occurredAt': '2026-10-28T15:00:01Z'},
    {'occurredAt': '2026-02-30T00:00:00Z'},
    {'occurredAt': '2026-10-28T00:00:00+25:00'},
    {'latitude': 91},
    {'longitude': -181},
    {'latitude': null},
  ]) {
    test('rechaza QR inválido $change', () {
      final json = jsonDecode(qrPayload()) as Map<String, dynamic>;
      json.addAll(change);
      expect(
        () => DepositQr.parse(jsonEncode(json), now: now),
        throwsA(isA<LocalDataException>()),
      );
    });
  }
  for (final raw in ['https://example.org', '[]', '{}', '{', 'a' * 4097]) {
    test('no interpreta texto o URLs como depósitos (${raw.length})', () {
      expect(
        () => DepositQr.parse(raw, now: now),
        throwsA(isA<LocalDataException>()),
      );
    });
  }
}
