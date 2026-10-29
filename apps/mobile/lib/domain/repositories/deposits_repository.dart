import '../entities/deposit_qr.dart';
import '../entities/recycling_record.dart';

abstract interface class DepositsRepository {
  Future<RecyclingRecord> accept(DepositQr receipt);
}
