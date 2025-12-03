import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/infrastructure/sales/sales_api.dart';
import 'package:shopx/domain/sales/sale.dart';
import 'package:shopx/infrastructure/core/dio_provider.dart';

// ----------------------------------------------------------
// REPOSITORY
// ----------------------------------------------------------

class SalesRepository {
  final SalesApi api;

  SalesRepository(this.api);

Future<int> createSale({
  required int customerId,
  required List<Map<String, dynamic>> items,
  required String paymentMethod,
}) async {
  final response = await api.createSale({
    "customer_id": customerId,
    "items": items,
    "payment_method": paymentMethod,
  });

  return response["sale"]["id"];   // <-- backend returns this
}


  Future<Sale> getSaleById(int id) async {
    final json = await api.getSaleById(id);
    return Sale.fromJson(json);
  }

  Future<List<Sale>> getAllSales() async {
    final list = await api.getAllSales();
    return list.map((e) => Sale.fromJson(e)).toList();
  }
}

// ----------------------------------------------------------
// PROVIDERS (THE PART YOU MISSED)
// ----------------------------------------------------------

// 1️⃣ Sales API Provider
final salesApiProvider = Provider<SalesApi>((ref) {
  return SalesApi(ref.read(dioProvider));
});

// 2️⃣ Sales Repository Provider  (THIS FIXES YOUR ERROR)
final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.read(salesApiProvider));
});
