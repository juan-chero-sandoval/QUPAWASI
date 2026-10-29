import '../entities/deposit_qr.dart';
import '../entities/recycling_record.dart';
import '../policies/demo_scoring_policy.dart';
import '../repositories/deposits_repository.dart';

class DepositUseCases {
  DepositUseCases(this._repository, {Clock? clock})
    : _clock = clock ?? DateTime.now;
  final DepositsRepository _repository;
  final Clock _clock;
  DepositQr decode(String raw) => DepositQr.parse(raw, now: _clock());
  Future<RecyclingRecord> accept(DepositQr receipt) =>
      _repository.accept(receipt);
}
