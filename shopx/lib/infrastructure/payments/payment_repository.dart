import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';
import 'package:shopx/infrastructure/payments/payments_api.dart';

class PaymentsRepository {
  final PaymentsApi api;

  PaymentsRepository(this.api);

  Future<void> markPaymentAsPaid(int saleId) async {
    await api.markPaymentAsPaid(saleId);
  }
}

// 🔌 Providers
final paymentsApiProvider = Provider<PaymentsApi>((ref) {
  return PaymentsApi(ref.read(dioProvider));
});

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.read(paymentsApiProvider));
});
