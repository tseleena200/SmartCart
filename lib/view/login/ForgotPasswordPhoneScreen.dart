import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common_widget/round_button.dart';
import '../../controllers/auth_controller.dart';
import 'verification_view.dart';

class ForgotPasswordPhoneView extends StatefulWidget {
  const ForgotPasswordPhoneView({super.key});

  @override
  State<ForgotPasswordPhoneView> createState() => _ForgotPasswordPhoneViewState();
}

class _ForgotPasswordPhoneViewState extends State<ForgotPasswordPhoneView> {
  final TextEditingController phoneController = TextEditingController();
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
              "Enter your registered phone number",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "+94 75 000 0000",
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
                final phone = phoneController.text.trim();
                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Enter your phone number")),
                  );
                  return;
                }

                AuthController.instance.sendOTP(
                  phoneNumber: phone,
                  firstName: '',
                  lastName: '',
                  dob: '',
                  branch: '',
                  receivePromos: false,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
