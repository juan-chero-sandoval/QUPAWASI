import 'package:flutter/foundation.dart';

import '../../domain/entities/deposit_qr.dart';
import '../../domain/entities/recycling_point.dart';
import '../../domain/errors/local_data_exception.dart';
import '../../domain/policies/demo_scoring_policy.dart';
import '../../domain/usecases/deposit_use_cases.dart';
import '../../domain/usecases/overview_use_cases.dart';

class QrDepositViewModel extends ChangeNotifier {
  QrDepositViewModel({
    required this.deposits,
    required this.overview,
    this.expectedPointId,
  });
  final DepositUseCases? deposits;
  final OverviewUseCases overview;
  final String? expectedPointId;
  DepositQr? receipt;
  RecyclingPoint? point;
  String? error;
  bool busy = false;
  bool _disposed = false;
  int get points => receipt == null
      ? 0
      : receipt!.input.quantity *
            const DemoScoringPolicy().pointsPerUnit(receipt!.input.material);

  Future<void> read(String raw) async {
    if (busy) return;
    busy = true;
    error = null;
    _notify();
    try {
      if (deposits == null) {
        throw const LocalDataException(
          LocalDataError.storage,
          'Lector no disponible.',
        );
      }
      final decoded = deposits!.decode(raw);
      final points = await overview.listPoints();
      final selected = points
          .where((p) => p.id == decoded.input.pointId)
          .firstOrNull;
      if (selected == null) {
        throw const LocalDataException(
          LocalDataError.notFound,
          'Tacho desconocido. Actualiza el catálogo de ubicaciones.',
        );
      }
      if (!selected.isActive) {
        throw const LocalDataException(
          LocalDataError.validation,
          'Este tacho está desactivado. Usa otro punto.',
        );
      }
      if (expectedPointId != null && expectedPointId != selected.id) {
        throw const LocalDataException(
          LocalDataError.validation,
          'El QR corresponde a otro tacho. Escanea el punto seleccionado en el mapa.',
        );
      }
      receipt = decoded;
      point = selected;
    } on LocalDataException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'No se pudo leer el recibo. Intenta nuevamente.';
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<String?> confirm() async {
    if (busy || receipt == null || deposits == null) return null;
    busy = true;
    error = null;
    _notify();
    try {
      return (await deposits!.accept(receipt!)).id;
    } on LocalDataException catch (e) {
      error = e.message;
      return null;
    } catch (_) {
      error = 'No se pudo guardar. Reintenta con el mismo QR.';
      return null;
    } finally {
      busy = false;
      _notify();
    }
  }

  void clear() {
    if (busy) return;
    receipt = null;
    point = null;
    error = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
