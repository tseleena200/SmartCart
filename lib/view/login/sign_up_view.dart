import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../common_widget/round_button.dart';
import 'login_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isEmailSelected = true;
  bool receivePromos = false;
  bool termsandcondtions = false;
  String? selectedBranch;

  final List<String> storeBranches = [
    "Colombo - Liberty Plaza",
    "Kandy City Center",
    "Galle - Dutch Market",
    "Negombo - Main Road"
  ];

  final Color themeColor = const Color(0xFF03452C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      const Center(
                        child: Text(
                          "Registration",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => isEmailSelected = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: !isEmailSelected
                                    ? Colors.grey.shade300
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("Phone number"),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => isEmailSelected = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isEmailSelected
                                    ? Colors.grey.shade300
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("Email"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email or Phone
                      if (isEmailSelected)
                        _buildField("Email", emailController, TextInputType.emailAddress)
                      else
                        _buildField("Phone Number", phoneController, TextInputType.phone),

                      const SizedBox(height: 16),
                      _buildField("First Name", firstNameController),
                      const SizedBox(height: 16),
                      _buildField("Last Name", lastNameController),
                      const SizedBox(height: 16),

                      // DOB with date picker
                      GestureDetector(
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              dobController.text =
                                  DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: _buildField("Date of Birth", dobController),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Preferred Branch
                      DropdownButtonFormField<String>(
                        value: selectedBranch,
                        decoration: InputDecoration(
                          labelText: "Preferred Store Branch",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: storeBranches
                            .map((branch) => DropdownMenuItem(
                          value: branch,
                          child: Text(branch),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBranch = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password
                      if (isEmailSelected) ...[
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
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            Text("min 8 letters", style: TextStyle(fontSize: 12)),
                            Text("1 capital letter", style: TextStyle(fontSize: 12)),
                            Text("1 number", style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: receivePromos,
                                activeColor: themeColor,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (val) {
                                  setState(() => receivePromos = val!);
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  "Receive exclusive offers and promotions",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: termsandcondtions,
                                activeColor: themeColor,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (val) {
                                  setState(() => termsandcondtions = val!);
                                },
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                    children: [
                                      const TextSpan(text: "I agree to the "),
                                      TextSpan(
                                        text: "Terms & Conditions",
                                        style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            debugPrint("Terms & Conditions tapped");
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      RoundButton(
                        title: "Next",
                        onPressed: () {
                          // Handle registration here
                        },
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Do you have already account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LogInView()));
                            },
                            child: const Text(
                              "Sign in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Center(child: Text("Sign in")),
                      const SizedBox(height: 12),

                      // Socials
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
