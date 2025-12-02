import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopx/application/products/product_notifier.dart';
import 'package:shopx/core/constants.dart';
import 'package:shopx/domain/products/product.dart';

class AddProductScreen extends HookConsumerWidget {
  const AddProductScreen({super.key});

 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks for TextFields
    final nameController = useTextEditingController();
    final priceController = useTextEditingController();
    final categoryController = useTextEditingController();
    final codeController = useTextEditingController();
    final quantityController = useTextEditingController();
    final selectedUnit = useState("Kg"); // default

    // Color Constants extracted from the image
    const Color primaryBlue = Color(0xFF1E75D5); // The AppBar and Button blue
    const Color darkBlueButton = Color(
      0xFF2B3A55,
    ); // The "Choose a photo" button
    const Color inputFillColor = Color(
      0xFFF3F4F6,
    ); // Light grey background for inputs
    const Color labelColor = Color(0xFF333333); // Dark text color
    const Color removeRed = Color(0xFFE53935);

    final pickedImages = useState<List<Uint8List>>([]);
    Future<void> pickFileOrImage() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: true,
        withData: true, // VERY IMPORTANT FOR WEB
      );

      if (result != null) {
        pickedImages.value = [
          ...pickedImages.value, //keep old image
          ...result.files
              .where((file) => file.bytes != null)
              .map((file) => file.bytes!),
        ];

        print("Picked ${pickedImages.value.length} images");
      }
    }

    void cancelAddProduct() {
      nameController.clear();
      priceController.clear();
      categoryController.clear();
      codeController.clear();
      quantityController.clear();
      selectedUnit.value = "Kg"; // Reset to default
      pickedImages.value = []; // ✅ ADD THIS LINE - Clear images

      Navigator.pop(context); // go back
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
          ),
          child: Row(
            children: [
              // LEFT BACK BUTTON
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Color(0xFF1E75D5),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // TITLE (CENTERED)
              const Expanded(
                child: Center(
                  child: Text(
                    'Add a product',
                    style: TextStyle(
                      color: Color(0xFF1E75D5),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // RIGHT SIDE DUMMY BUTTON (invisible but same size as back button)
              Opacity(
                opacity: 0, // fully invisible
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.transparent,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section: Product Details ---
            const Text(
              'Product Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            kHeight16,

            // Field: Product Name
            _buildLabel('Product Name'),
            _buildTextField(
              controller: nameController,
              hintText: 'Enter product name',
              fillColor: inputFillColor,
            ),
            kHeight16,

            // Field: Selling Price
            _buildLabel('Selling price'),
            _buildTextField(
              controller: priceController,
              hintText: 'Enter selling price',
              fillColor: inputFillColor,
            ),
            kHeight16,

            // Field: Categories
            _buildLabel('Categories'),
            _buildTextField(
              controller: categoryController,
              hintText: 'Choose a category',
              fillColor: inputFillColor,
              // In a real app, you might want readOnly: true and onTap to show a modal
            ),
            kHeight16,

            // Field: Unit
            _buildLabel('Unit'),
            Row(
              children: [
                // QUANTITY TEXT FIELD
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: quantityController,
                    hintText: 'Enter Quantity',
                    fillColor: inputFillColor,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // UNIT DROPDOWN
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUnit.value,
                        items: const [
                          DropdownMenuItem(value: "Kg", child: Text("Kg")),
                          DropdownMenuItem(value: "Nos", child: Text("Nos")),
                        ],
                        onChanged: (value) {
                          selectedUnit.value = value!;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            kHeight16,

            // Field: Code
            _buildLabel('Code'),
            _buildTextField(
              controller: codeController,
              hintText: 'Enter product code',
              fillColor: inputFillColor,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Image.asset(
                  "assets/images/bar-code.png",
                  height: 20,
                  width: 20,
                  color: Colors.black,
                ),
              ),
            ),
            kHeight24,
            // --- Section: More Details ---
            const Text(
              'More details (optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            kHeight12,

            // Image Picker Widget
            Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // If NO images picked → show placeholder
                  pickedImages.value.isEmpty
                      ? Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: inputFillColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey.shade700,
                              size: 30,
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: pickedImages.value.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final imgBytes = pickedImages.value[index];

                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(
                                      imgBytes,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Delete Button
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        final newList = List<Uint8List>.from(
                                          pickedImages.value,
                                        );
                                        newList.removeAt(index);
                                        pickedImages.value = newList;
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                  const SizedBox(width: 10),

                  // Choose photo button
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: pickFileOrImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlueButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Choose a photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            kHeight40,

            // --- Footer Buttons ---

            // Add Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
final images = pickedImages.value; // <-- already bytes

                  final product = Product(
                    name: nameController.text,
                    price: double.parse(priceController.text),
                    category: categoryController.text,
                    description: codeController.text,
                    unit: "${quantityController.text} ${selectedUnit.value}",
                  );
                  await ref
                      .read(productNotifierProvider.notifier)
                      .addProductWithImages(product, images);

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add a new product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            kHeight20,
            // Remove Button
            Center(
              child: TextButton.icon(
                onPressed: cancelAddProduct,
                style: TextButton.styleFrom(foregroundColor: removeRed),
                icon: const Icon(Icons.delete_outline, size: 20),
                label: const Text(
                  'Remove product',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            kHeight20,
          ],
        ),
      ),
    );
  }

  // Helper widget for Labels
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A4A4A),
        ),
      ),
    );
  }

  // Helper widget for TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Color fillColor,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF1E75D5), width: 1),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          maxHeight: 24,
          maxWidth: 40,
        ),
      ),
    );
  }
}
