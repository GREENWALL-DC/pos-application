import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/core/constants.dart';
import 'package:shopx/presentation/auth/owner/widgets/otp_selection_button.dart';

class OwnerLoginScreen extends HookConsumerWidget {
  const OwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Define Controllers using Hooks (Auto-disposed)
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // 2. Define State for OTP Selection
    // 'Email' is selected by default based on the design
    final selectedOtpMethod = useState<String>('Email');

    // 3. Theme Colors
    const primaryBlue = Color(0xFF1976D2);
    const inputFillColor = Color(0xFFF3F4F6); // Light grey for inputs
    const textLabelColor = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Back Button
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/backbutton.png",
                      height: 35,
                      width: 35,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // CENTER: Title
                  const Expanded(
                    child: Text(
                      'Log in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // RIGHT: Invisible Box Matching Back Button Size
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

             kHeight40,

              // --- Email/Phone Input ---
              const Text(
                'Email or Phone Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textLabelColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email or Phone Number',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  filled: true,
                  fillColor: inputFillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Password Input ---
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textLabelColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Minimum 8 characters',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  filled: true,
                  fillColor: inputFillColor,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

                   kHeight30,

              // --- Send an OTP Section ---
              const Text(
                'send an OTP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // Darker text
                ),
              ),
              const SizedBox(height: 12),
              
              // OTP Options Layout
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OtpSelectionButton(
                          label: 'Email',
                          icon: Icons.email,
                          isSelected: selectedOtpMethod.value == 'Email',
                          onTap: () => selectedOtpMethod.value = 'Email',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OtpSelectionButton(
                          label: 'WhatsApp',
                          icon:Image.asset(
                            "assets/images/WhatsApp.png",
                           
                          ) , 
                          isSelected: selectedOtpMethod.value == 'WhatsApp',
                          onTap: () => selectedOtpMethod.value = 'WhatsApp',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OtpSelectionButton(
                          label: 'SMS',
                          icon: Icons.sms,
                          isSelected: selectedOtpMethod.value == 'SMS',
                          onTap: () => selectedOtpMethod.value = 'SMS',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OtpSelectionButton(
                          label: 'Missed call',
                          icon: Icons.phone_missed,
                          isSelected: selectedOtpMethod.value == 'Missed call',
                          onTap: () => selectedOtpMethod.value = 'Missed call',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // --- Log In Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Login Logic Here
                    // Access values: emailController.text, passwordController.text
                    // Selected OTP: selectedOtpMethod.value
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

                    kHeight20,

              // --- Forgot Password ---
              Center(
                child: InkWell(
                  onTap: () {
                    // Navigate to Forgot Password
                  },
                  child: const Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: primaryBlue,
                    ),
                  ),
                ),
              ),
              
                    kHeight20,
            ],
          ),
        ),
      ),
    );
  }
}

