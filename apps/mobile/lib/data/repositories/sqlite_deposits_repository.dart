import 'package:drift/drift.dart';

import '../../domain/entities/deposit_qr.dart';
import '../../domain/entities/recycling_record.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/policies/local_validation.dart';
import '../../domain/repositories/deposits_repository.dart';
import '../local/app_database.dart' show AppDatabase;
import '../local/local_data_guard.dart';
import 'sqlite_records_repository.dart';

class SqliteDepositsRepository implements DepositsRepository {
  SqliteDepositsRepository(this.db, {Clock? clock})
    : clock = clock ?? DateTime.now;
  final AppDatabase db;
  final Clock clock;

  @override
  Future<RecyclingRecord> accept(DepositQr receipt) => guardLocalData(() async {
    LocalValidation.record(receipt.input, clock());
    LocalValidation.id(receipt.depositId);
    LocalValidation.require(
      validCoordinates(receipt.latitude, receipt.longitude),
      'Coordenadas inválidas.',
    );
    return db.transaction(() async {
      final records = SqliteRecordsRepository(db, clock: clock);
      final previous = await db
          .customSelect(
            'SELECT * FROM deposit_receipts WHERE deposit_id=?',
            variables: [Variable<String>(receipt.depositId)],
          )
          .getSingleOrNull();
      if (previous != null) {
        if (previous.read<String>('payload') != receipt.canonical) {
          throw const LocalDataException(
            LocalDataError.conflict,
            'Este ID de QR ya se usó con otros datos.',
          );
        }
        final record = await records.getById(
          previous.read<String>('record_id'),
        );
        if (record == null) {
          throw const LocalDataException(
            LocalDataError.conflict,
            'Este QR ya fue registrado y eliminado. No se puede acreditar otra vez.',
          );
        }
        return record;
      }
      final point = await db
          .customSelect(
            'SELECT * FROM recycling_points WHERE id=?',
            variables: [Variable<String>(receipt.input.pointId)],
          )
          .getSingleOrNull();
      if (point == null) {
        throw const LocalDataException(
          LocalDataError.notFound,
          'Tacho desconocido. Actualiza el catálogo de ubicaciones.',
        );
      }
      final lat = point.readNullable<double>('latitude');
      final lon = point.readNullable<double>('longitude');
      LocalValidation.require(
        !validCoordinates(lat, lon) ||
            ((lat! - receipt.latitude).abs() <= 0.00001 &&
                (lon! - receipt.longitude).abs() <= 0.00001),
        'La ubicación del QR no coincide con el tacho del catálogo.',
      );
      final record = await records.create(receipt.input);
      await db.customUpdate(
        'UPDATE recycling_records SET qr_deposit_id=?, latitude=?, longitude=? WHERE id=?',
        variables: [
          Variable<String>(receipt.depositId),
          Variable<double>(receipt.latitude),
          Variable<double>(receipt.longitude),
          Variable<String>(record.id),
        ],
        updates: {db.recyclingRecords},
      );
      await db.customInsert(
        'INSERT INTO deposit_receipts (deposit_id,record_id,payload) VALUES (?,?,?)',
        variables: [
          Variable<String>(receipt.depositId),
          Variable<String>(record.id),
          Variable<String>(receipt.canonical),
        ],
        updates: {db.depositReceipts},
      );
      return (await records.getById(record.id))!;
    });
  });
}
