import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'demo_seed.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Abrir explícitamente una conexión de prueba en memoria o archivo temporal.
  factory AppDatabase.inFile(File file) =>
      AppDatabase(NativeDatabase.createInBackground(file));

  static Future<AppDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final db = AppDatabase.inFile(
      File(p.join(directory.path, 'qupawasi.sqlite')),
    );
    try {
      await db.ensureReady();
      return db;
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement(
          'ALTER TABLE recycling_records ADD COLUMN qr_deposit_id TEXT',
        );
        await customStatement(
          'ALTER TABLE recycling_records ADD COLUMN latitude REAL',
        );
        await customStatement(
          'ALTER TABLE recycling_records ADD COLUMN longitude REAL',
        );
        await customStatement(
          'CREATE UNIQUE INDEX records_qr_id ON recycling_records(qr_deposit_id)',
        );
        await m.createTable(depositReceipts);
        await m.createTrigger(immutableQrRecord);
      }
      if (from < 3) {
        await customStatement(
          'ALTER TABLE recycling_points ADD COLUMN is_active INTEGER NOT NULL '
          'DEFAULT 1 CHECK (is_active IN (0, 1))',
        );
        await m.createTable(formDrafts);
        await m.createTable(appFlags);
        // Una base anterior ya recibió la siembra: no repetirla.
        await customStatement(
          "INSERT OR IGNORE INTO app_flags (key) VALUES ('seeded')",
        );
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
      await transaction(() async {
        // Sembrar una sola vez: lo que el administrador borre no reaparece.
        final seeded = await customSelect(
          "SELECT 1 FROM app_flags WHERE key='seeded'",
        ).getSingleOrNull();
        if (seeded != null) return;
        for (final point in DemoSeed.points) {
          await customStatement(
            'INSERT OR IGNORE INTO recycling_points '
            '(id,name,description,occupancy,is_demo) VALUES (?,?,?,?,1)',
            [point.id, point.name, point.description, point.occupancy],
          );
        }
        for (final reward in DemoSeed.rewards) {
          await customStatement(
            'INSERT OR IGNORE INTO rewards '
            '(id,title,category,cost_points,description,is_active) VALUES (?,?,?,?,?,1)',
            [
              reward.id,
              reward.title,
              reward.category.name,
              reward.costPoints,
              reward.description,
            ],
          );
        }
        await customStatement(
          "INSERT OR IGNORE INTO app_flags (key) VALUES ('seeded')",
        );
      });
    },
  );

  Future<void> ensureReady() async {
    await customSelect('SELECT 1').get();
  }
}
