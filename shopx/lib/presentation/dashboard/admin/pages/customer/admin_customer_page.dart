import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/application/customers/customer_notifier.dart';
import 'package:shopx/domain/customers/customer.dart';

class AdminCustomerPage extends HookConsumerWidget {
  final Customer? customer; // If null = Add mode. If not = Edit mode.

  const AdminCustomerPage({super.key, this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = customer != null;

    // FORM KEY
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final customerState = ref.watch(customerNotifierProvider);

    // -----------------------------
    // CONTROLLERS (correct place!)
    // -----------------------------
    final nameController = useTextEditingController(text: customer?.name ?? "");
    final phoneController = useTextEditingController(text: customer?.phone ?? "");
    final tinController = useTextEditingController(text: customer?.tin ?? "");
    final addressController = useTextEditingController(text: customer?.address ?? "");

    // -----------------------------
    // STATES FOR BUTTON ACTIVATION
    // -----------------------------
    final name = useState(customer?.name ?? "");
    final phone = useState(customer?.phone ?? "");
    final tin = useState(customer?.tin ?? "");
    final address = useState(customer?.address ?? "");

    // -----------------------------
    // LISTENERS (correct placement!)
    // -----------------------------
    useEffect(() {
      nameController.addListener(() => name.value = nameController.text);
      phoneController.addListener(() => phone.value = phoneController.text);
      tinController.addListener(() => tin.value = tinController.text);
      addressController.addListener(() => address.value = addressController.text);
      return null;
    }, []);

    // BUTTON ENABLED?
   bool isValidPhone(String phone) =>
    RegExp(r'^[0-9]{10}$').hasMatch(phone);

bool isValidTin(String tin) => tin.length >= 6;

final isButtonEnabled =
    name.value.trim().isNotEmpty &&
    isValidPhone(phone.value.trim()) &&
    isValidTin(tin.value.trim()) &&
    address.value.trim().isNotEmpty;

    // -----------------------------
    // LISTENER FOR SUCCESS/ERROR
    // -----------------------------
    ref.listen(customerNotifierProvider, (previous, next) {
      if (next.success == true && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditMode ? "Customer updated!" : "Customer added!")),
        );
        Navigator.pop(context);
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.error}"), backgroundColor: Colors.red),
        );
      }
    });

    // -----------------------------
    // SAVE CUSTOMER FUNCTION
    // -----------------------------
    void saveCustomer() async {
      if (!formKey.currentState!.validate()) return;

      final updatedCustomer = Customer(
        id: isEditMode ? customer!.id : 0,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
       tin: tinController.text.trim(),
        address: addressController.text.trim(),
        createdAt: isEditMode ? customer!.createdAt : DateTime.now(),
      );

      if (isEditMode) {
        await ref.read(customerNotifierProvider.notifier)
            .updateCustomer(customer!.id, updatedCustomer);
      } else {
        await ref.read(customerNotifierProvider.notifier)
            .createCustomer(updatedCustomer);
      }
    }

    // -----------------------------
    // UI STARTS HERE
    // -----------------------------
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditMode ? "Edit Customer" : "Add Customer",
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Name"),
                      _buildTextField(nameController, "Example: John Doe", required: true),

                      const SizedBox(height: 20),

                      _buildLabel("Phone"),
                      _buildTextField(phoneController, "Example: 9876543210", required: true, isPhone: true),

                      const SizedBox(height: 20),

                      _buildLabel("Tin"),
                      _buildTextField(tinController, "Example: tin no"),

                      const SizedBox(height: 20),

                      _buildLabel("Address"),
                      _buildTextField(addressController, "Example: Bannerghatta Road", required: true, maxLines: 3),
                    ],
                  ),
                ),
              ),
            ),

            // -----------------------------
            //  SAVE BUTTON
            // -----------------------------
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isButtonEnabled
                        ? const Color(0xFF1976D2)
                        : const Color(0xFFD1E4FA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      (!isButtonEnabled || customerState.isLoading)
                          ? null
                          : saveCustomer,
                  child: customerState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          isEditMode ? "Save changes" : "Save customer",
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // REUSABLE WIDGETS
  // -----------------------------
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    {bool required = false, bool isPhone = false, int maxLines = 1}
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,

validator: (value) {
  final text = value?.trim() ?? "";

  if (required && text.isEmpty) {
    return "This field is required";
  }

  if (isPhone) {
    if (!RegExp(r'^[0-9]{10}$').hasMatch(text)) {
      return "Phone number must be exactly 10 digits";
    }
  }

  if (hint.toLowerCase().contains("tin")) {
    if (text.length < 6) {
      return "TIN must be at least 6 characters";
    }
  }

  return null;
},



        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
