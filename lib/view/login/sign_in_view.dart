import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onlinegroceries/common/color_extension.dart';
import 'package:onlinegroceries/common_widget/round_button.dart';
import 'package:onlinegroceries/view/login/verification_view.dart';
import 'package:onlinegroceries/view/login/sign_up_view.dart';

import 'login_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController txtMobile = TextEditingController();
  final FlCountryCodePicker countryPicker = const FlCountryCodePicker();
  late CountryCode countryCode;

  @override
  void initState() {
    super.initState();
    countryCode = countryPicker.countryCodes.firstWhere(
          (element) => element.name == "Sri Lanka",
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top banner image
          SizedBox(
            height: media.height * 0.35,
            width: double.infinity,
            child: Image.asset(
              "assets/img/sign_in_top.png",
              fit: BoxFit.cover,
            ),
          ),

          // Card-style content area
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Scan. Shop. Go.",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Get your groceries fast!",
                      style: TextStyle(fontSize: 16, color: TColor.secondaryText),
                    ),
                    const SizedBox(height: 32),

                    // Phone input field
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 16,
                        color: TColor.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final code = await countryPicker.showPicker(context: context);
                              if (code != null) {
                                setState(() {
                                  countryCode = code;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                countryCode.flagImage(),
                                const SizedBox(width: 6),
                                Text(
                                  countryCode.dialCode,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: txtMobile,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your mobile number",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Divider with text
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text("OR"),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Google button
                    _socialButton(
                      title: "Continue with Google",
                      iconPath: "assets/img/google_logo.png",
                      color: const Color(0xff056843),
                        onPressed: () {
                          Get.snackbar("Coming Soon", "Google Sign-In will be added later.",
                            backgroundColor: TColor.primary,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                    ),

                    const SizedBox(height: 16),

                    // Facebook button
                    _socialButton(
                      title: "Continue with Facebook",
                      iconPath: "assets/img/fb_logo.png",
                      color: const Color(0xff4A66AC),
                      onPressed: () {},
                    ),

                    const SizedBox(height: 28),

                    // Login / Register navigation
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Prefer using email? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LogInView()),
                                  );
                                },
                                child: Text(
                                  "Login here",
                                  style: TextStyle(
                                    color: TColor.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
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
                                    color: TColor.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required String title,
    required String iconPath,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 24, width: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
