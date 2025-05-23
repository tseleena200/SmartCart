import 'package:flutter/material.dart';
import '../../common_widget/round_button.dart';
import '../../controllers/auth_controller.dart';
import 'PasswordResetSuccessView.dart';
import 'login_view.dart';

class ForgotPasswordEmailView extends StatefulWidget {
  const ForgotPasswordEmailView({super.key});

  @override
  State<ForgotPasswordEmailView> createState() => _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends State<ForgotPasswordEmailView> {
  final TextEditingController emailController = TextEditingController();
  final Color themeColor = const Color(0xFF03452C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your registered email",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email Address",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            RoundButton(
              title: "Continue",
              onPressed: () {
                final email = emailController.text.trim();

                if (email.isEmpty || !email.contains("@")) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid email address")),
                  );
                  return;
                }

                AuthController.instance.sendPasswordResetEmail(email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("If this email exists, a reset link will be sent."),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("If this email is registered, a reset link has been sent."),
                    duration: Duration(seconds: 2),
                  ),
                );

// Navigate to login after short delay
                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PasswordResetSuccessView()),
                  );
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
