import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/salesman/salesman_state.dart';
import 'package:shopx/domain/salesman/salesman.dart';
import 'package:shopx/infrastructure/salesman/salesman_api.dart';
import 'package:shopx/infrastructure/salesman/salesman_repositary.dart';

final salesmanRepositoryProvider = Provider<SalesmanRepository>((ref) {
  return SalesmanRepository(ref.read(salesmanApiProvider));
});

class SalesmanNotifier extends Notifier<SalesmanState> {
  @override
  SalesmanState build() {
    return SalesmanState();
  }

  // CREATE
  Future<void> createSalesman(Salesman salesman) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final created = await ref
          .read(salesmanRepositoryProvider)
          .createSalesman(salesman);

      state = state.copyWith(
        isLoading: false,
        success: true,
        salesmen: [...state.salesmen, created], // 🔥 append new item
      );
    } catch (e) {
      String errorMessage = "Something went wrong";

      if (e is DioException) {
        final status = e.response?.statusCode;
        final data = e.response?.data;

        if (status == 409) {
          if (data?["code"] == "USERNAME_ALREADY_EXISTS") {
            errorMessage = "Salesman name already exists";
          } else if (data?["code"] == "USER_ALREADY_EXISTS") {
            errorMessage = "Email already exists";
          }
        } else {
          errorMessage = "Server error. Please try again.";
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        success: false,
      );
    }
  }
  

  // GET ALL
  Future<void> fetchSalesmen() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await ref.read(salesmanRepositoryProvider).getAllSalesmen();
      state = state.copyWith(isLoading: false, salesmen: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // GET BY ID
  Future<Salesman> fetchSalesmanById(int id) async {
    return await ref.read(salesmanRepositoryProvider).getSalesmanById(id);
  }

  // UPDATE
  Future<void> updateSalesman(int id, Salesman salesman) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      final updated = await ref
          .read(salesmanRepositoryProvider)
          .updateSalesman(id, salesman);

      // 🔥 Update UI instantly by replacing the old salesman
      final updatedList = state.salesmen.map((s) {
        return s.id == id ? updated : s;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        success: true,
        salesmen: updatedList,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // DELETE
  Future<void> deleteSalesman(int id) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await ref.read(salesmanRepositoryProvider).deleteSalesman(id);

      final updatedList = state.salesmen
          .where((s) => s.id != id)
          .toList(); // 🔥 remove item

      state = state.copyWith(
        isLoading: false,
        success: true,
        salesmen: updatedList,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final salesmanNotifierProvider =
    NotifierProvider<SalesmanNotifier, SalesmanState>(SalesmanNotifier.new);
