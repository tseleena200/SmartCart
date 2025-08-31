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
  final TextEditingController confirmPasswordController = TextEditingController();

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

  // -------- Helpers --------
  // name: allow letters, spaces, hyphen, apostrophe; 2–49 chars
  final RegExp nameRegex = RegExp(r"^[A-Za-z][A-Za-z\s'’-]{1,48}$");

  String normalizedPhone(String raw) =>
      (raw).replaceAll(RegExp(r'\s+'), '');

  double _passwordStrength(String v) {
    if (v.isEmpty) return 0.0;
    double s = 0;
    if (v.length >= 8) s += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(v)) s += 0.25;
    if (RegExp(r'[0-9]').hasMatch(v)) s += 0.25;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=]').hasMatch(v)) s += 0.25;
    return s.clamp(0.0, 1.0);
  }

  String _strengthLabel(double s) {
    if (s <= 0.25) return 'Weak';
    if (s <= 0.5) return 'Okay';
    if (s <= 0.75) return 'Good';
    return 'Strong';
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return Colors.redAccent;
    if (s <= 0.5) return Colors.orange;
    if (s <= 0.75) return Colors.amber[700]!;
    return Colors.green;
  }
  // -------------------------

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength(passwordController.text);

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
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              final v = value.trim();
                              if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$')
                                  .hasMatch(v)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          )
                        else
                          _buildField(
                            "Phone Number",
                            phoneController,
                            inputType: TextInputType.phone,
                            inputFormatters: [PhoneInputFormatter()],
                            hintText: "+94 75 000 0000",
                            validator: (value) {
                              final v = normalizedPhone((value ?? '').trim());
                              if (v.isEmpty) return 'Phone number is required';
                              if (!RegExp(r'^\+94\d{9}$').hasMatch(v)) {
                                return 'Use +94 followed by 9 digits';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 16),
                        _buildField("First Name", firstNameController,
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'First name is required';
                              if (!nameRegex.hasMatch(v)) {
                                return 'Use letters, spaces, - or \' only';
                              }
                              return null;
                            }),
                        const SizedBox(height: 16),
                        _buildField("Last Name", lastNameController,
                            validator: (value) {
                              final v = (value ?? '').trim();
                              if (v.isEmpty) return 'Last name is required';
                              if (!nameRegex.hasMatch(v)) {
                                return 'Use letters, spaces, - or \' only';
                              }
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
                                  final v = (value ?? '').trim();
                                  if (v.isEmpty) return 'Date of birth is required';
                                  final dob = DateTime.tryParse(v);
                                  if (dob == null || dob.isAfter(DateTime.now())) {
                                    return 'Enter a valid date';
                                  }
                                  // minimum age 13+
                                  final today = DateTime.now();
                                  int age = today.year - dob.year;
                                  final hadBirthdayThisYear = (today.month > dob.month) ||
                                      (today.month == dob.month && today.day >= dob.day);
                                  if (!hadBirthdayThisYear) age--;
                                  if (age < 13) return 'You must be at least 13 years old';
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

                        // -------- Password + Confirm + Strength --------
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
                              final v = (value ?? '');
                              if (v.isEmpty) return 'Password is required';
                              if (v.length < 8) return 'Min 8 characters required';
                              if (RegExp(r'\s').hasMatch(v)) return 'No spaces allowed';
                              if (!RegExp(r'[A-Z]').hasMatch(v)) {
                                return 'Must contain 1 capital letter';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(v)) {
                                return 'Must contain 1 number';
                              }
                              if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=]').hasMatch(v)) {
                                return 'Add 1 special character';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Strength bar + label
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: strength,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _strengthColor(strength),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Strength: ${_strengthLabel(strength)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _strengthColor(strength),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Confirm Password
                          _buildField(
                            "Confirm Password",
                            confirmPasswordController,
                            isObscured: true,
                            validator: (v) {
                              final c = (v ?? '');
                              if (c.isEmpty) return 'Please re-enter password';
                              if (c != passwordController.text) {
                                return 'Passwords do not match';
                              }
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
                        // -----------------------------------------------

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

                                final first = firstNameController.text.trim();
                                final last = lastNameController.text.trim();
                                final dob = dobController.text.trim();
                                final branch = selectedBranch!;

                                if (isEmailSelected) {
                                  final email = emailController.text.trim().toLowerCase();
                                  final pwd = passwordController.text;

                                  AuthController.instance.registerWithEmail(
                                    email: email,
                                    password: pwd,
                                    firstName: first,
                                    lastName: last,
                                    phone: "", // email path
                                    dob: dob,
                                    branch: branch,
                                    receivePromos: receivePromos,
                                  );
                                } else {
                                  final phone = normalizedPhone(phoneController.text.trim());

                                  AuthController.instance.sendOTP(
                                    phoneNumber: phone,
                                    firstName: first,
                                    lastName: last,
                                    dob: dob,
                                    branch: branch,
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
        bool obscure = false, // preserved
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
      onChanged: (v) {
        // Update strength/confirm match visuals in real time
        if (controller == passwordController || controller == confirmPasswordController) {
          setState(() {});
        }
      },
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
