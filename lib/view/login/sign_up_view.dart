import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../common_widget/round_button.dart';
import '../../controllers/auth_controller.dart';
import 'login_view.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';


class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 2),
                        const Center(
                          child: Text(
                            "Registration",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  setState(() => isEmailSelected = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
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
                              onTap: () =>
                                  setState(() => isEmailSelected = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
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
                        if (isEmailSelected)
                          _buildField(
                            "Email",
                            emailController,
                            inputType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Email is required';
                              if (!RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-z]+\.[a-z]{2,}$')
                                  .hasMatch(value))
                                return 'Enter a valid email';
                              return null;
                            },
                          )
                        else
                          _buildField(
                            "Phone Number",
                            phoneController,
                            inputType: TextInputType.phone,
                            inputFormatters: [PhoneInputFormatter()], // <-- Add this
                            hintText: "+94 75 000 0000",              // <-- Add this
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Phone number is required';
                              if (!RegExp(r'^\+94\s?\d{2}\s?\d{3}\s?\d{4}$').hasMatch(value))
                                return 'Enter a valid number like +94 75 000 0000';
                              return null;
                            },
                          ),
                        const SizedBox(height: 16),
                        _buildField("First Name", firstNameController,
                            validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'First name is required';
                          if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value))
                            return 'Only letters allowed';
                          return null;
                        }),
                        const SizedBox(height: 16),
                        _buildField("Last Name", lastNameController,
                            validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Last name is required';
                          if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value))
                            return 'Only letters allowed';
                          return null;
                        }),
                        const SizedBox(height: 16),
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
                            child: _buildField("Date of Birth", dobController,
                                validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Date of birth is required';
                              final dob = DateTime.tryParse(value);
                              if (dob == null || dob.isAfter(DateTime.now()))
                                return 'Enter a valid date';
                              return null;
                            }),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                  value: branch, child: Text(branch)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedBranch = value),
                          validator: (value) =>
                              value == null ? 'Please select a branch' : null,
                        ),
                        const SizedBox(height: 16),
                        if (isEmailSelected) ...[
                          _buildField(
                            "Password",
                            passwordController,
                            isObscured: !isPasswordVisible,
                            showToggle: true,
                            onToggleVisibility: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Password is required';
                              if (value.length < 8)
                                return 'Min 8 characters required';
                              if (!RegExp(r'[A-Z]').hasMatch(value))
                                return 'Must contain 1 capital letter';
                              if (!RegExp(r'[0-9]').hasMatch(value))
                                return 'Must contain 1 number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text("min 8 letters",
                                  style: TextStyle(fontSize: 12)),
                              Text("1 capital letter",
                                  style: TextStyle(fontSize: 12)),
                              Text("1 number", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: receivePromos,
                              activeColor: themeColor,
                              onChanged: (val) =>
                                  setState(() => receivePromos = val!),
                            ),
                            const Expanded(
                                child: Text(
                                    "Receive exclusive offers and promotions")),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: termsandcondtions,
                              activeColor: themeColor,
                              onChanged: (val) =>
                                  setState(() => termsandcondtions = val!),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.black),
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
                                        ..onTap = () => debugPrint(
                                            "Terms & Conditions tapped"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RoundButton(
                          title: "Register",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (!termsandcondtions) {
                                Get.snackbar(
                                  "Terms Required",
                                  "Please agree to the Terms & Conditions",
                                  backgroundColor: themeColor,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                );
                                return;
                              }

                              if (isEmailSelected) {
                                // Email-based registration
                                AuthController.instance.registerWithEmail(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  firstName: firstNameController.text.trim(),
                                  lastName: lastNameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  dob: dobController.text.trim(),
                                  branch: selectedBranch!,
                                  receivePromos: receivePromos,
                                );
                              } else {
                                // Phone-based OTP registration
                                AuthController.instance.sendOTP(
                                  phoneNumber: phoneController.text.trim(),
                                  firstName: firstNameController.text.trim(),
                                  lastName: lastNameController.text.trim(),
                                  dob: dobController.text.trim(),
                                  branch: selectedBranch!,
                                  receivePromos: receivePromos,
                                );
                              }
                            }
                          }
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Do you have already account? "),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LogInView())),
                              child: const Text(
                                "Sign in",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget _buildField(
      String label,
      TextEditingController controller, {
        TextInputType inputType = TextInputType.text,
        bool obscure = false,
        bool isObscured = false,
        bool showToggle = false,
        void Function()? onToggleVisibility,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
        String? hintText,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isObscured,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: showToggle
            ? IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        )
            : null,
      ),
    );
  }

}
