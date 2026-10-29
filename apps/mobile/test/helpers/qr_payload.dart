import 'dart:convert';

import 'package:qupa_wasi/data/local/demo_seed.dart';

String qrPayload({
  String id = 'test-deposit-1',
  String point = DemoSeed.architectureId,
  String material = 'pet',
  int quantity = 2,
  String timestamp = '2026-10-28T10:00:00-05:00',
  double latitude = 0,
  double longitude = 0,
}) => jsonEncode({
  'type': 'qupawasi.deposit',
  'version': 1,
  'depositId': id,
  'pointId': point,
  'material': material,
  'quantity': quantity,
  'occurredAt': timestamp,
  'latitude': latitude,
  'longitude': longitude,
});
