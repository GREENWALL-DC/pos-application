import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/core/constants.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Controllers
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final emailController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    

    //Focus node
    final usernameFocus = useFocusNode();
    final passwordFocus = useFocusNode();
    final emailFocus = useFocusNode();
    final confirmPasswordFocus = useFocusNode();

    // State variables
    final isUsernameFocused = useState(false);
    final isPasswordFocused = useState(false);
    final passwordError = useState<String?>(null);
    final isEmailFocused = useState(false);
    final emailError = useState<String?>(null);
    final isConfirmPasswordFocused = useState(false);
    final confirmPasswordError = useState<String?>(null);

    // Listen focus changes
    useEffect(() {
      usernameFocus.addListener(() {
        isUsernameFocused.value = usernameFocus.hasFocus;
      });

      passwordFocus.addListener(() {
        isPasswordFocused.value = passwordFocus.hasFocus;
      });

      emailFocus.addListener(() {
        isEmailFocused.value = emailFocus.hasFocus;
      });
      return null;
    }, []); // Run only once when screen first loads

    // Listen to password changes
    useEffect(() {
      void listener() {
        if (passwordController.text.isEmpty) {
          passwordError.value = null;
        } else if (passwordController.text.length < 6) {
          passwordError.value = "Minimum 6 characters";
        } else {
          passwordError.value = null;
        }
      }

      passwordController.addListener(listener);
      return () => passwordController.removeListener(listener);
    }, []);

    // Listen to email changes
    useEffect(() {
      void listener() {
        final text = emailController.text.trim();

        if (text.isEmpty) {
          emailError.value = null;
        }
        // Basic email pattern (standard)
        else if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(text)) {
          emailError.value = "Enter a valid email";
        } else {
          emailError.value = null;
        }
      }

      emailController.addListener(listener);
      return () => emailController.removeListener(listener);
    }, []);

    // Listen to confirm password changes
    useEffect(() {
      void listener() {
        final pass = passwordController.text;
        final confirm = confirmPasswordController.text;

        if (confirm.isEmpty) {
          confirmPasswordError.value = null;
        } else if (confirm != pass) {
          confirmPasswordError.value = "Passwords do not match";
        } else {
          confirmPasswordError.value = null;
        }
      }

      confirmPasswordController.addListener(listener);
      passwordController.addListener(
        listener,
      ); // 👈 important because both fields affect validation

      return () {
        confirmPasswordController.removeListener(listener);
        passwordController.removeListener(listener);
      };
    }, []);

    return Scaffold(
      // The background behind the curve is dark
      backgroundColor: const Color(0xFF2C2C2C),
      body: Column(
        children: [
          // This creates the gap at the top so the curve is visible
          // Adjust height to move the white card up/down
          kHeight80,
          // The White Card Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE), // Light grey background for the card
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80), // The specific Top-Left curve
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    kHeight30,

                    // Header Row (Back Icon + Title)
                    Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.black87,
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 28,
                                fontFamily: 'Serif', // Matches the design font
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        // Empty SizedBox to balance the center alignment
                        kwidth20,
                      ],
                    ),

                    kHeight40,

                    // Form Fields
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildInputField(
                              label: "Name",
                              controller: usernameController,
                              focusNode: usernameFocus,
                              isFocused: isUsernameFocused.value,
                            ),
                            kHeight20,

                            _buildInputField(
                              label: "Email",
                              controller: emailController,
                              focusNode: emailFocus,
                              isFocused: isEmailFocused.value,
                              errorText: emailError.value,
                            ),
                            kHeight20,
                            // Password Field
                            _buildInputField(
                              label: "Password",
                              controller: passwordController,
                              focusNode: passwordFocus,
                              isFocused: isPasswordFocused.value,
                              obscureText: true,
                              errorText: passwordError.value,
                            ),
                            kHeight20,
                            _buildInputField(
                              label: "Confirm Password",
                              controller: confirmPasswordController,
                              focusNode: confirmPasswordFocus,
                              isFocused: isConfirmPasswordFocused.value,
                              obscureText: true,
                              errorText: confirmPasswordError.value,
                            ),

                            kHeight40,

                           GestureDetector(
                            onTap: (){
                               print("Register pressed");
    // TODO: Navigate to register page or call API
                            },
                            child:  // Register Button
                            Container(
                              width: 180, // Slightly wider per design
                              height: 55,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2C), // Dark button
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 4),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Serif',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                           ),
                            kHeight30,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    bool obscureText = false,
    String? errorText,
  }) {
    Color borderColor = Colors.black54;

    if (errorText != null)
      borderColor = Colors.red;
    else if (isFocused)
      borderColor = Colors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        kHeight5,
        Container(
          height: 50,
          // padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: controller,
            focusNode: focusNode, // Connects to focus tracking
            obscureText: obscureText,
decoration: const InputDecoration(
  border: InputBorder.none,
  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        if (errorText != null)
          Text(errorText, style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
