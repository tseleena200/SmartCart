import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart';

class PaymentMethodView extends StatefulWidget {
  const PaymentMethodView({super.key});

  @override
  State<PaymentMethodView> createState() => _PaymentMethodViewState();
}

class _PaymentMethodViewState extends State<PaymentMethodView> {
  final _formKey = GlobalKey<FormState>();
  bool saveCard = true;

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  String? selectedCardType;

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      final type = _detectCardType(_cardNumberController.text.replaceAll(' ', ''));
      setState(() => selectedCardType = type);
    });
    _prefillCardInfo();
  }

  Future<void> _prefillCardInfo() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final doc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    final data = doc.data();
    if (data != null && data['savedCard'] != null) {
      final card = data['savedCard'];
      _nameController.text = card['name'] ?? '';
      _cardNumberController.text = card['maskedNumber'] ?? '';
      selectedCardType = card['type'];
    }
  }

  String _detectCardType(String number) {
    if (number.startsWith('4')) return 'visa';
    if (number.startsWith('5')) return 'master';
    if (number.startsWith('3')) return 'amex';
    return 'unknown';
  }

  Widget _buildCardIcon(String? type) {
    String asset = 'assets/img/master.png';
    if (type == 'visa') asset = 'assets/img/visa.png';
    if (type == 'amex') asset = 'assets/img/amex.png';
    return Image.asset(asset, width: 40, height: 30);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: TColor.primaryText),
        title: Text("Add Card Details",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Card Number"),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cardNumberController,
                      hint: "1234 5678 9012 3456",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        CardNumberInputFormatter(),
                      ],
                      validator: (value) =>
                      value == null || value.isEmpty ? "Card number is required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildCardIcon(selectedCardType),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Expiry Date"),
                        _buildTextField(
                          controller: _expiryController,
                          hint: "MM/YY",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpiryDateInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Expiry required";
                            final parts = value.split('/');
                            if (parts.length != 2) return "Invalid format";
                            final m = int.tryParse(parts[0]);
                            final y = int.tryParse(parts[1]);
                            if (m == null || y == null || m < 1 || m > 12) return "Invalid date";
                            final expiry = DateTime(2000 + y, m);
                            final now = DateTime.now();
                            if (expiry.isBefore(DateTime(now.year, now.month))) return "Expired";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("CVV"),
                        _buildTextField(
                          controller: _cvvController,
                          hint: "123",
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscure: true,
                          validator: (value) =>
                          value == null || value.length < 3 ? "Invalid CVV" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel("Cardholder Name"),
              _buildTextField(
                controller: _nameController,
                hint: "John Doe",
                validator: (value) =>
                value == null || value.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 30),
              CheckboxListTile(
                value: saveCard,
                onChanged: (value) => setState(() => saveCard = value ?? true),
                contentPadding: EdgeInsets.zero,
                title: const Text("Save this card for future purchases"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              RoundButton(
                title: "Continue",
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String last4 = _cardNumberController.text.replaceAll(" ", "");
                    if (last4.length >= 4) {
                      last4 = last4.substring(last4.length - 4);
                    }
                    final type = selectedCardType ?? 'master';
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
                      if (saveCard) {
                        await userDoc.update({
                          'savedCard': {
                            'type': type,
                            'maskedNumber': '**** $last4',
                            'name': _nameController.text.trim(),
                            'expiry': _expiryController.text.trim(),
                            'lastSaved': DateTime.now().toIso8601String(),
                          }
                        });
                      } else {
                        await userDoc.update({ 'savedCard': FieldValue.delete() });
                      }
                    }
                    Navigator.pop(context, {
                      'summary': "Credit/Debit Card (**** $last4)",
                      'cardType': type,
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(fontSize: 14, color: TColor.secondaryText, fontWeight: FontWeight.w500),
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 2) text = '${text.substring(0, 2)}/${text.substring(2)}';
    if (text.length > 5) text = text.substring(0, 5);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
