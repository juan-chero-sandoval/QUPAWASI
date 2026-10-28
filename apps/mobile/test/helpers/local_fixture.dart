import 'dart:io';

import 'package:qupa_wasi/app/local_services.dart';
import 'package:qupa_wasi/data/local/app_database.dart' show AppDatabase;
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';

/// SQLite real en un archivo distinto por prueba, nunca la DB de la aplicación.
class LocalFixture {
  LocalFixture._(this.directory, this.now, this.db, this.services);

  final Directory directory;
  DateTime now;
  AppDatabase db;
  LocalServices services;

  static Future<LocalFixture> open() async {
    final directory = await Directory.systemTemp.createTemp('qupawasi-f02-');
    final now = DateTime.utc(2026, 10, 28, 15);
    final db = AppDatabase.inFile(File('${directory.path}/test.sqlite'));
    await db.ensureReady();
    late final LocalFixture fixture;
    final services = LocalServices.withDatabase(db, clock: () => fixture.now);
    fixture = LocalFixture._(directory, now, db, services);
    return fixture;
  }

  RecordInput input({
    int quantity = 2,
    RecyclingMaterial material = RecyclingMaterial.pet,
    String pointId = DemoSeed.architectureId,
    String note = 'prueba',
    DateTime? occurredAt,
  }) => RecordInput(
    pointId: pointId,
    material: material,
    quantity: quantity,
    occurredAt: occurredAt ?? now,
    note: note,
  );

  Future<void> reopen() async {
    await services.close();
    db = AppDatabase.inFile(File('${directory.path}/test.sqlite'));
    await db.ensureReady();
    services = LocalServices.withDatabase(db, clock: () => now);
  }

  Future<void> dispose() async {
    await services.close();
    // Solo el directorio que creó esta fixture, dentro del temporal del sistema.
    final target = directory.absolute.path;
    final parent = Directory.systemTemp.absolute.path;
    if (!target.startsWith('$parent${Platform.pathSeparator}') ||
        !directory.uri.pathSegments
            .where((s) => s.startsWith('qupawasi-f02-'))
            .any((_) => true)) {
      throw StateError('Directorio temporal inesperado; no se elimina.');
    }
    await directory.delete(recursive: true);
  }
}
