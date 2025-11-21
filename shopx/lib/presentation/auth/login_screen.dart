import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shopx/core/constants.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shopx/presentation/auth/register_screen.dart';

class LoginScreen extends HookConsumerWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Controllers
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();

    //Focus node
    final usernameFocus = useFocusNode();
    final passwordFocus = useFocusNode();

    // State variables
    final isUsernameFocused = useState(false);
    final isPasswordFocused = useState(false);
    final passwordError = useState<String?>(null);
    final isPasswordVisible = useState(false);

    // Listen focus changes
    useEffect(() {
      usernameFocus.addListener(() {
        isUsernameFocused.value = usernameFocus.hasFocus;
      });

      passwordFocus.addListener(() {
        isPasswordFocused.value = passwordFocus.hasFocus;
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

    // Getting screen size for responsive layout
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Dark background for the gap
      body: Stack(
        children: [
          Column(
            children: [
              // Top White Section with "Coffee" text
              Container(
                width: double.infinity,
                height: size.height * 0.22,
                padding: const EdgeInsets.only(left: 30, bottom: 20),
                color: const Color(0xFFF2F2F2),
                alignment: Alignment.bottomLeft,
                child: const Text(
                  "Coffee",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // The Dark Gap with "house" text
              Container(
                width: double.infinity,
                height: size.height * 0.12,
                padding: const EdgeInsets.only(left: 30, top: 10),
                alignment: Alignment.topLeft,
                child: const Text(
                  "house",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              // The Bottom White Section (Curved)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      kHeight40,

                      // Name Field
                      _buildInputField(
                        label: "Username",
                        controller: usernameController,
                        focusNode: usernameFocus,
                        isFocused: isUsernameFocused.value,
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

                      // Links Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Forgot password ?",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          //Make this clickable
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Create an account ?",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Sign In Button
                     GestureDetector(
                      onTap: (){
                        //functionality Here
                      },
                      child:  Center(
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Sign in",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                     ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // The Floating Coffee Cup Image
          Positioned(
            top: size.height * 0.17, // Adjust based on screen height
            right: 40,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                image: const DecorationImage(
                  fit: BoxFit.cover,

                  image: AssetImage("assets/images/coffee.jpg"),
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

/*
useTextEditingController() → controls text

useFocusNode() → detects focus

useState() → stores errors & state

useEffect() → listens to changes 
*/
