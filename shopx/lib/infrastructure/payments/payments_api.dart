import 'package:dio/dio.dart';

class PaymentsApi {
  final Dio dio;

  PaymentsApi(this.dio);

  // POST /payments/:saleId/mark-paid
  Future<void> markPaymentAsPaid(int saleId) async {
    await dio.post(
      '/payments/$saleId/mark-paid',
    );
  }
}
