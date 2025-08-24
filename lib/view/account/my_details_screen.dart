import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDetailsView extends StatefulWidget {
  const MyDetailsView({super.key});

  @override
  State<MyDetailsView> createState() => _MyDetailsViewState();
}

class _MyDetailsViewState extends State<MyDetailsView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? selectedBranch;
  bool receivePromos = false;

  final List<String> storeBranches = [
    "Colombo - Liberty Plaza",
    "Kandy City Center",
    "Galle - Dutch Market",
    "Negombo - Main Road"
  ];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
    final data = doc.data();

    if (data != null) {
      setState(() {
        firstNameController.text = data['name']?.split(' ').first ?? '';
        lastNameController.text = data['name']?.split(' ').skip(1).join(' ') ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        dobController.text = data['dob'] ?? '';
        selectedBranch = data['preferredBranch'];
        receivePromos = data['receivePromos'] ?? false;
        _loading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
      'name': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      'email': emailController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'dob': dobController.text.trim(),
      'preferredBranch': selectedBranch,
      'receivePromos': receivePromos,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Details")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("First Name", firstNameController),
              const SizedBox(height: 16),
              _buildField("Last Name", lastNameController),
              const SizedBox(height: 16),
              _buildField("Email", emailController,
                  inputType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField("Phone Number", phoneController,
                  inputType: TextInputType.phone),
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
                  child: _buildField("Date of Birth", dobController),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBranch,
                decoration: const InputDecoration(
                  labelText: "Preferred Store Branch",
                  border: OutlineInputBorder(),
                ),
                items: storeBranches
                    .map((branch) => DropdownMenuItem(
                  value: branch,
                  child: Text(branch),
                ))
                    .toList(),
                onChanged: (value) => setState(() => selectedBranch = value),
                validator: (value) => value == null ? 'Please select a branch' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: receivePromos,
                    onChanged: (val) => setState(() => receivePromos = val!),
                  ),
                  const Text("Receive exclusive offers")
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      validator: (value) =>
      (value == null || value.isEmpty) ? '$label is required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
