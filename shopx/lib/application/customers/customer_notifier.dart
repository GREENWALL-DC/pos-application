import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopx/application/customers/customer_state.dart';
import 'package:shopx/domain/customers/customer.dart';
import 'package:shopx/infrastructure/customers/customer_repository.dart';
import 'package:shopx/infrastructure/customers/customer_api.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.read(customerApiProvider));
});

class CustomerNotifier extends Notifier<CustomerState> {
  @override
  CustomerState build() {
    return CustomerState();
  }

  // CREATE
  // Future<void> createCustomer(Customer customer) async {
  //   state = state.copyWith(isLoading: true, error: null, success: false);

  //   try {
  //     await ref.read(customerRepositoryProvider).createCustomer(customer);

  //      // FIX: refresh list
  //   await fetchMyCustomers();

  //     state = state.copyWith(isLoading: false, success: true);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }


Future<void> createCustomer(Customer customer) async {
  state = state.copyWith(isLoading: true, error: null, success: false);

  try {
    final createdCustomer =
        await ref.read(customerRepositoryProvider).createCustomer(customer);

    state = state.copyWith(
      isLoading: false,
      success: true,
      customers: [...state.customers, createdCustomer], // 🔥 ADD LOCALLY
    );
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}




// 🔒 Manage Customers screen
Future<void> fetchMyCustomers() async {
  state = state.copyWith(isLoading: true, error: null, success: false);

  try {
    final data =
        await ref.read(customerRepositoryProvider).getMyCustomers();
    state = state.copyWith(isLoading: false, customers: data);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}

// 🧾 Cart screen (billing anyone)
Future<void> fetchAllCustomers() async {
  state = state.copyWith(isLoading: true, error: null, success: false);

  try {
    final data =
        await ref.read(customerRepositoryProvider).getAllCustomers();
    state = state.copyWith(isLoading: false, customers: data);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}



    // GET SINGLE CUSTOMER BY ID
  Future<Customer> fetchCustomerById(int id) async {
    try {
      final result =
          await ref.read(customerRepositoryProvider).getCustomerById(id);
      return result;
    } catch (e) {
      throw Exception("Failed to fetch customer: $e");
    }
  }


  // UPDATE
  // Future<void> updateCustomer(int id, Customer customer) async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   try {
  //     await ref.read(customerRepositoryProvider).updateCustomer(id, customer);
  //      // FIX: refresh list
  //   await fetchMyCustomers();
  //     state = state.copyWith(isLoading: false, success: true);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }
Future<void> updateCustomer(int id, Customer customer) async {
  state = state.copyWith(isLoading: true, error: null, success: false);

  try {
    final updatedCustomer =
        await ref.read(customerRepositoryProvider).updateCustomer(id, customer);

    final updatedList = state.customers
        .map((c) => c.id == id ? updatedCustomer : c)
        .toList();

    state = state.copyWith(
      isLoading: false,
      success: true,
      customers: updatedList, // 🔥 REPLACE LOCALLY
    );
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}



  // DELETE
  // Future<void> deleteCustomer(int id) async {
  //   state = state.copyWith(isLoading: true, error: null);

  //   try {
  //     await ref.read(customerRepositoryProvider).deleteCustomer(id);
  //      // FIX: refresh list
  //   await fetchMyCustomers();
  //     state = state.copyWith(isLoading: false, success: true);
  //   } catch (e) {
  //     state = state.copyWith(isLoading: false, error: e.toString());
  //   }
  // }

  // DELETE (FIXED)
Future<void> deleteCustomer(int id) async {
  state = state.copyWith(isLoading: true, error: null, success: false);

  try {
    await ref.read(customerRepositoryProvider).deleteCustomer(id);

    // ✅ REMOVE ONLY THE DELETED CUSTOMER
    final updatedCustomers =
        state.customers.where((c) => c.id != id).toList();

    state = state.copyWith(
      isLoading: false,
      success: true,
      customers: updatedCustomers, // 🔥 KEY FIX
    );
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}

}

final customerNotifierProvider =
    NotifierProvider<CustomerNotifier, CustomerState>(CustomerNotifier.new);
