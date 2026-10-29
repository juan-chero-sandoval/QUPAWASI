import 'dart:async';

import 'package:qupa_wasi/app/local_services.dart';
import 'package:qupa_wasi/data/local/demo_seed.dart';
import 'package:qupa_wasi/domain/entities/local_suggestion.dart';
import 'package:qupa_wasi/domain/entities/recycling_draft.dart';
import 'package:qupa_wasi/domain/entities/recycling_point.dart';
import 'package:qupa_wasi/domain/entities/recycling_record.dart';
import 'package:qupa_wasi/domain/entities/recycling_statistics.dart';
import 'package:qupa_wasi/domain/entities/reward.dart';
import 'package:qupa_wasi/domain/errors/local_data_exception.dart';
import 'package:qupa_wasi/domain/policies/demo_scoring_policy.dart';
import 'package:qupa_wasi/domain/repositories/draft_repository.dart';
import 'package:qupa_wasi/domain/repositories/points_repository.dart';
import 'package:qupa_wasi/domain/repositories/records_repository.dart';
import 'package:qupa_wasi/domain/repositories/rewards_repository.dart';
import 'package:qupa_wasi/domain/repositories/statistics_repository.dart';
import 'package:qupa_wasi/domain/repositories/suggestions_repository.dart';
import 'package:qupa_wasi/domain/usecases/draft_use_cases.dart';
import 'package:qupa_wasi/domain/usecases/overview_use_cases.dart';
import 'package:qupa_wasi/domain/usecases/recycling_use_cases.dart';
import 'package:qupa_wasi/domain/usecases/rewards_use_cases.dart';
import 'package:qupa_wasi/domain/usecases/suggestions_use_cases.dart';

/// Dobles controlados para pruebas de widgets (sin isolate de SQLite ni
/// temporizadores de Drift). La persistencia real se prueba en
/// `test/presentation/record_form_view_model_test.dart`, `test/data/` e
/// `integration_test/`.
class FakeLocal {
  FakeLocal() {
    services = LocalServices.fromUseCases(
      recycling: RecyclingUseCases(records, clock: () => now),
      overview: OverviewUseCases(
        const _FakePoints(),
        _FakeStatistics(records, () => now),
      ),
      rewards: const RewardsUseCases(_FakeRewards()),
      drafts: DraftUseCases(drafts),
      suggestions: const SuggestionsUseCases(_FakeSuggestions()),
    );
  }

  /// Hora real: la vista usa `DateTime.now` y la validación rechaza fechas
  /// futuras, así que el doble no puede quedarse con un reloj fijo anterior.
  DateTime get now => DateTime.now().toUtc();
  final records = FakeRecordsRepository();
  final drafts = FakeDraftRepository();
  late final LocalServices services;

  Future<RecyclingRecord> seedRecord({
    int quantity = 2,
    RecyclingMaterial material = RecyclingMaterial.pet,
    String pointId = DemoSeed.architectureId,
    String note = 'prueba',
  }) => records.create(
    RecordInput(
      pointId: pointId,
      material: material,
      quantity: quantity,
      occurredAt: now,
      note: note,
    ),
  );
}

class FakeRecordsRepository implements RecordsRepository {
  final Map<String, RecyclingRecord> _rows = {};
  final _changes = StreamController<void>.broadcast();
  int _nextId = 1;
  int createCalls = 0;
  int activeWatchers = 0;

  /// Si no es null, la siguiente escritura falla con este error.
  LocalDataException? failNextWrite;

  /// Retrasa create/update para simular una escritura lenta (doble tap).
  Completer<void>? writeGate;

  List<RecyclingRecord> get all => _rows.values.toList();

  @override
  Stream<List<RecyclingRecord>> watchAll({RecordsFilter? filter}) {
    late StreamController<List<RecyclingRecord>> controller;
    StreamSubscription<void>? changes;
    List<RecyclingRecord> current() => List.unmodifiable(
      _rows.values.where(
        (r) => filter?.material == null || r.material == filter!.material,
      ),
    );
    controller = StreamController<List<RecyclingRecord>>(
      onListen: () {
        activeWatchers++;
        controller.add(current());
        changes = _changes.stream.listen((_) => controller.add(current()));
      },
      onCancel: () async {
        activeWatchers--;
        await changes?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<RecyclingRecord?> getById(String id) async => _rows[id];

  @override
  Future<RecyclingRecord> create(RecordInput input) async {
    createCalls++;
    await _beforeWrite();
    final id = '00000000-0000-4000-9000-${'${_nextId++}'.padLeft(12, '0')}';
    final record = _build(id, input, input.occurredAt);
    _rows[id] = record;
    _changes.add(null);
    return record;
  }

  @override
  Future<RecyclingRecord> update(String id, RecordInput input) async {
    await _beforeWrite();
    final existing = _rows[id];
    if (existing == null) {
      throw const LocalDataException(
        LocalDataError.notFound,
        'El registro ya no existe.',
      );
    }
    final record = _build(id, input, existing.createdAt);
    _rows[id] = record;
    _changes.add(null);
    return record;
  }

  @override
  Future<void> delete(String id) async {
    await _beforeWrite();
    if (_rows.remove(id) == null) {
      throw const LocalDataException(
        LocalDataError.notFound,
        'El registro ya no existe.',
      );
    }
    _changes.add(null);
  }

  Future<void> _beforeWrite() async {
    if (writeGate case final gate?) await gate.future;
    if (failNextWrite case final error?) {
      failNextWrite = null;
      throw error;
    }
  }

  RecyclingRecord _build(String id, RecordInput input, DateTime createdAt) =>
      RecyclingRecord(
        id: id,
        pointId: input.pointId,
        material: input.material,
        quantity: input.quantity,
        unitPoints: const DemoScoringPolicy().pointsPerUnit(input.material),
        occurredAt: input.occurredAt,
        note: input.note.trim(),
        createdAt: createdAt,
        updatedAt: input.occurredAt,
      );
}

class FakeDraftRepository implements DraftRepository {
  final Map<String, RecyclingDraft> rows = {};
  final List<String> savedQuantities = [];

  @override
  Future<RecyclingDraft?> load(String key) async => rows[key];

  @override
  Future<void> save(RecyclingDraft draft) async {
    savedQuantities.add(draft.quantityText);
    rows[draft.key] = draft;
  }

  @override
  Future<void> clear(String key) async => rows.remove(key);
}

class _FakePoints implements PointsRepository {
  const _FakePoints();

  @override
  Future<List<RecyclingPoint>> listPoints() async => DemoSeed.points;

  @override
  Stream<List<RecyclingPoint>> watchPoints() => Stream.value(DemoSeed.points);
}

class _FakeStatistics implements StatisticsRepository {
  _FakeStatistics(this._records, this._clock);

  final FakeRecordsRepository _records;
  final Clock _clock;

  @override
  Future<RecyclingStatistics> getStatistics() async =>
      const DemoScoringPolicy().summarize(_records.all, [], now: _clock());

  @override
  Stream<RecyclingStatistics> watchStatistics() =>
      _records.watchAll().asyncMap((_) => getStatistics());
}

class _FakeRewards implements RewardsRepository {
  const _FakeRewards();

  @override
  Stream<List<Reward>> watchCatalog({RewardCategory? category}) => Stream.value(
    DemoSeed.rewards
        .where((r) => category == null || r.category == category)
        .toList(),
  );

  @override
  Stream<List<Redemption>> watchRedemptions() => Stream.value(const []);

  @override
  Future<Redemption> redeem(String rewardId, String operationId) =>
      throw UnimplementedError('Canjes fuera del alcance de estas pruebas');

  @override
  Future<void> cancelRedemption(String id) =>
      throw UnimplementedError('Canjes fuera del alcance de estas pruebas');
}

class _FakeSuggestions implements SuggestionsRepository {
  const _FakeSuggestions();

  @override
  Future<List<LocalSuggestion>> list() async => const [];

  @override
  Future<LocalSuggestion> create(String message) =>
      throw UnimplementedError('Sugerencias fuera del alcance (F04)');

  @override
  Future<void> delete(String id) async {}
}
