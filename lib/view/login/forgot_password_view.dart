import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';
import 'ForgotPasswordEmailScreen.dart';
import 'ForgotPasswordPhoneScreen.dart';


class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  String selectedMethod = "email";

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Select which contact details should we use to reset your password",
                style: TextStyle(fontSize: 14, color: TColor.secondaryText),
              ),
              const SizedBox(height: 24),

              // Email option
              GestureDetector(
                onTap: () => setState(() => selectedMethod = "email"),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedMethod == "email"
                          ? TColor.primary
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedMethod == "email"
                        ? TColor.primary.withOpacity(0.05)
                        : Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/img/email.png", width: 28, height: 28),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Email",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text("Send to your email",
                              style:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Phone option
              GestureDetector(
                onTap: () => setState(() => selectedMethod = "phone"),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedMethod == "phone"
                          ? TColor.primary
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: selectedMethod == "phone"
                        ? TColor.primary.withOpacity(0.05)
                        : Colors.grey.shade100,
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/img/phone.png", width: 28, height: 28),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Phone Number",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text("Send to your phone number",
                              style:
                              TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Continue button
              RoundButton(
                title: "Continue",
                onPressed: () {
                  if (selectedMethod == "email") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordEmailView(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPhoneView(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
