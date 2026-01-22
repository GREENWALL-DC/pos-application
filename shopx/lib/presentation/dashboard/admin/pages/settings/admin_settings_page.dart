import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopx/application/settings/settings_notifier.dart';
import 'package:shopx/core/constants.dart';
import 'package:shopx/domain/settings/company_settings.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: AdminSettingsScreen())));
}

class AdminSettingsScreen extends HookConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);

    // Text Controllers
    final nameEnController = useTextEditingController();
    final nameArController = useTextEditingController();
    final addressEnController = useTextEditingController();
    final addressArController = useTextEditingController();
    final mobileController = useTextEditingController();
    final emailController = useTextEditingController();
    final accountController = useTextEditingController();
    final ibanController = useTextEditingController();
    final vatController = useTextEditingController();
    final crController = useTextEditingController();

    // Logo State
    final imagePath = useState<String?>(null);
    final imageBytes = useState<Uint8List?>(null);

    final picker = useMemoized(() => ImagePicker());

    useEffect(() {
      final settings = settingsState.settings;
      if (settings != null) {
        nameEnController.text = settings.companyNameEn;
        nameArController.text = settings.companyNameAr;
        addressEnController.text = settings.companyAddressEn;
        addressArController.text = settings.companyAddressAr;
        mobileController.text = settings.phone ?? '';
        emailController.text = settings.email ?? '';
        accountController.text = settings.accountNumber ?? '';
        ibanController.text = settings.iban ?? '';
        vatController.text = settings.vatNumber;
        crController.text = settings.crNumber;
        imagePath.value = settings.logoUrl;
      }
      return null;
    }, [settingsState.settings]);

    // Form Key for validation
    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Image Picker Logic
    Future<void> pickImage() async {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        imageBytes.value = await pickedFile.readAsBytes();
        imagePath.value = null; // clear old URL
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 2. Logo Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.5),
                                width: 2,
                              ),

                              image: imageBytes.value != null
                                  ? DecorationImage(
                                      image: MemoryImage(imageBytes.value!),
                                      fit: BoxFit.cover,
                                    )
                                  : imagePath.value != null
                                  ? DecorationImage(
                                      image: NetworkImage(imagePath.value!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                (imageBytes.value == null &&
                                    imagePath.value == null)
                                ? const Icon(
                                    Icons.business,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  imagePath.value == null
                                      ? Icons.camera_alt
                                      : Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    kHeight30,

                    // 4. Form Fields

                    // Company Name (English)
                    _buildTextField(
                      label: "Company Name (English)",
                      controller: nameEnController,
                      isRequired: true,
                    ),
                    const SizedBox(height: 10),

                    // Company Name (Arabic)
                    _buildTextField(
                      label: "Company Name (Arabic)",
                      controller: nameArController,
                      isRequired: true,
                      isRtl: true,
                    ),
                    const SizedBox(height: 10),

                    // Address(English )
                    _buildTextField(
                      label: "Company Address(English)",
                      controller: addressEnController,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      label: "Company Address(Arabic)",
                      controller: addressArController,
                    ),
                    const SizedBox(height: 10),

                    // Mobile
                    _buildTextField(
                      label: "Mobile",
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),

                    // Email
                    _buildTextField(
                      label: "Email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),

                    // Account Number
                    _buildTextField(
                      label: "Account Number",
                      controller: accountController,
                    ),
                    const SizedBox(height: 10),

                    // IBAN
                    _buildTextField(
                      label: "International Bank Account Number (IBAN)",
                      controller: ibanController,
                    ),
                    const SizedBox(height: 10),

                    // VAT Number
                    _buildTextField(
                      label: "VAT Number",
                      controller: vatController,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // CR Number
                    _buildTextField(
                      label: "CR Number",
                      controller: crController,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 30),

                    // 6. Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(



                       onPressed: () async {
  if (!formKey.currentState!.validate()) return;

  final notifier = ref.read(settingsNotifierProvider.notifier);

  String? finalLogoUrl = imagePath.value;

  // 🔥 STEP 1: upload logo if a new image was selected
  if (imageBytes.value != null) {
    finalLogoUrl = await notifier.uploadCompanyLogo(
      imageBytes.value!,
    );
  }

  // 🔥 STEP 2: save settings with REAL backend logoUrl
  final settings = CompanySettings(
    id: settingsState.settings?.id ?? 0,
    companyNameEn: nameEnController.text.trim(),
    companyNameAr: nameArController.text.trim(),
    companyAddressEn: addressEnController.text.trim(),
    companyAddressAr: addressArController.text.trim(),
    vatNumber: vatController.text.trim(),
    crNumber: crController.text.trim(),
    phone: mobileController.text.trim().isEmpty
        ? null
        : mobileController.text.trim(),
    email: emailController.text.trim().isEmpty
        ? null
        : emailController.text.trim(),
    accountNumber: accountController.text.trim().isEmpty
        ? null
        : accountController.text.trim(),
    iban: ibanController.text.trim().isEmpty
        ? null
        : ibanController.text.trim(),
    logoUrl: finalLogoUrl, // ✅ BACKEND URL
    createdAt: DateTime.now(),
  );

  await notifier.saveSettings(settings);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Settings saved successfully")),
    );
  }
}
,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper widget to build standard text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool isRtl = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return "This field is required";
        }
        return null;
      },
    );
  }
}
