import 'package:flutter/material.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/view/login/forgot_password_view.dart';
import 'package:onlinegroceries/view/login/sign_up_view.dart';
import 'package:onlinegroceries/view/login/verification_view.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isRememberMe = false;
  bool isPasswordVisible = false;
  bool isEmailSelected = true;

  final Color themeColor = const Color(0xFF03452C);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Logo
              Center(
                child: Image.asset(
                  "assets/img/logo-transparent.png",
                  height: 120,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Center(
                child: Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Please sign in to continue",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),

              // Toggle: Email or Phone
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isEmailSelected = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isEmailSelected ? Colors.grey.shade300 : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Email"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => isEmailSelected = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: !isEmailSelected ? Colors.grey.shade300 : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("Phone"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Email or Phone field
              TextField(
                controller: inputController,
                keyboardType:
                isEmailSelected ? TextInputType.emailAddress : TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isEmailSelected ? "Email" : "Phone Number",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              if (isEmailSelected) ...[
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => isPasswordVisible = !isPasswordVisible);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Remember + Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isRememberMe,
                          activeColor: themeColor,
                          onChanged: (val) {
                            setState(() => isRememberMe = val!);
                          },
                        ),
                        const Text("Remember me"),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordView()),
                        );
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(color: themeColor),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Sign In
              RoundButton(
                title: "Sign In",
                onPressed: () {
                  if (isEmailSelected) {
                    // Handle email login (placeholder)
                    debugPrint("Login with Email: ${inputController.text}");
                  } else {
                    // Go to OTP screen (no backend yet)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerificationView()),
                    );
                  }
                },
              ),

              const SizedBox(height: 24),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Are you new? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpView()),
                      );
                    },
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // OR Divider
              Row(
                children: const [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),

              const SizedBox(height: 16),

              // Social
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon("assets/img/google.png"),
                  const SizedBox(width: 16),
                  _buildSocialIcon("assets/img/facebook-logo-png.png"),
                  const SizedBox(width: 16),
                  _buildSocialIcon("assets/img/appleidl.png"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(assetPath, width: 24, height: 24),
      ),
    );
  }
}
