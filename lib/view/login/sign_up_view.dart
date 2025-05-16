import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => isEmailSelected = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: !isEmailSelected ? Colors.grey.shade300 : Colors.transparent,
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
                                  color: isEmailSelected ? Colors.grey.shade300 : Colors.transparent,
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
                              if (value == null || value.isEmpty) return 'Email is required';
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) return 'Enter valid email';
                              return null;
                            },
                          )
                        else
                          _buildField(
                            "Phone Number",
                            phoneController,
                            inputType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Phone number is required';
                              if (!RegExp(r'^\d{10,15}$').hasMatch(value)) return 'Enter valid phone number';
                              return null;
                            },
                          ),

                        const SizedBox(height: 16),
                        _buildField("First Name", firstNameController, validator: (value) => value!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        _buildField("Last Name", lastNameController, validator: (value) => value!.isEmpty ? 'Required' : null),
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
                                dobController.text = DateFormat('yyyy-MM-dd').format(picked);
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: _buildField("Date of Birth", dobController, validator: (value) => value!.isEmpty ? 'Required' : null),
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
                              .map((branch) => DropdownMenuItem(value: branch, child: Text(branch)))
                              .toList(),
                          onChanged: (value) => setState(() => selectedBranch = value),
                          validator: (value) => value == null ? 'Please select a branch' : null,
                        ),

                        const SizedBox(height: 16),

                        if (isEmailSelected) ...[
                          _buildField("Password", passwordController, obscure: true, validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required';
                            if (value.length < 8) return 'Min 8 characters required';
                            if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Must contain 1 capital letter';
                            if (!RegExp(r'[0-9]').hasMatch(value)) return 'Must contain 1 number';
                            return null;
                          }),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text("min 8 letters", style: TextStyle(fontSize: 12)),
                              Text("1 capital letter", style: TextStyle(fontSize: 12)),
                              Text("1 number", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: receivePromos,
                              activeColor: themeColor,
                              onChanged: (val) => setState(() => receivePromos = val!),
                            ),
                            const Expanded(child: Text("Receive exclusive offers and promotions")),
                          ],
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: termsandcondtions,
                              activeColor: themeColor,
                              onChanged: (val) => setState(() => termsandcondtions = val!),
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
                                      recognizer: TapGestureRecognizer()..onTap = () => debugPrint("Terms & Conditions tapped"),
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
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (!termsandcondtions) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Please agree to the Terms & Conditions")),
                                  );
                                  return;
                                }

                                try {
                                  // 1. Register user with Firebase Auth
                                  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );

                                  // 2. Save user data to Firestore
                                  await FirebaseFirestore.instance.collection('Users').doc(credential.user!.uid).set({
                                    'userID': credential.user!.uid,
                                    'name': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
                                    'email': emailController.text.trim(),
                                    'phoneNumber': phoneController.text.trim(),
                                    'userRole': 'customer',
                                    'dob': dobController.text.trim(),
                                    'preferredBranch': selectedBranch,
                                    'receivePromos': receivePromos,
                                    'favorites': [],
                                    'purchaseHistory': [],
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Registration successful!")),
                                  );

                                  // Optional: Navigate to login or home
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LogInView()));
                                } on FirebaseAuthException catch (e) {
                                  String msg = 'An error occurred';
                                  if (e.code == 'email-already-in-use') {
                                    msg = 'This email is already in use';
                                  } else if (e.code == 'weak-password') {
                                    msg = 'The password is too weak';
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Unexpected error: ${e.toString()}")),
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
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogInView())),
                              child: const Text(
                                "Sign in",
                                style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
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

  Widget _buildField(String label, TextEditingController controller, {TextInputType inputType = TextInputType.text, bool obscure = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      validator: validator,
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
