import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class AddProductView extends StatefulWidget {
  const AddProductView({super.key});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _nutritionController = TextEditingController();
  final _unitValueController = TextEditingController();

  String? _selectedCategory;
  String? _status;
  String? _selectedUnitType;
  bool _isLoading = false;

  final _statuses = ["Exclusive", "Popular", "New Arrival"];

  final List<String> _unitOptions = [
    'pcs', 'pack', 'box', 'set', 'g', 'kg', 'ml', 'L','fl oz'
  ];

  String convertToDirectImageLink(String originalUrl) {
    final uri = Uri.tryParse(originalUrl);
    if (uri == null) return originalUrl;
    final regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(originalUrl);
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return originalUrl;
  }

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('Products').doc();
      final imageUrl = convertToDirectImageLink(_imageUrlController.text.trim());

      await docRef.set({
        'productID': docRef.id,
        'productName': _nameController.text.trim(),
        'nutrition': _nutritionController.text.trim(),
        'price': double.parse(_priceController.text),
        'stockLevel': int.parse(_stockController.text),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'imageURL': imageUrl,
        'RFIDCode': 'RFID_${docRef.id.substring(0, 6).toUpperCase()}',
        'isExclusive': _status == "Exclusive",
        'isPopular': _status == "Popular",
        'anomalyFlag': false,
        'tags': [],
        'createdAt': FieldValue.serverTimestamp(),
        'unitValue': _unitValueController.text.trim(),
        'unitType': _selectedUnitType,
        'isNewArrival': _status == "New Arrival",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: \${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text("Add Product"),
          backgroundColor: secondaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Scrollbar(
            thickness: 6,
            radius: const Radius.circular(12),
            thumbVisibility: true,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: "Google Drive Image URL"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Product Name"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Price"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _unitValueController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(labelText: "Unit Value (e.g., 500, 1)"),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnitType,
                            items: _unitOptions
                                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedUnitType = val),
                            decoration: const InputDecoration(labelText: "Unit Type"),
                            validator: (val) => val == null ? "Select a unit" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nutritionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Nutrition Info (e.g. Calories, Protein)"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Stock Level"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Discount (%) - optional"),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Categories').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        final categoryList = snapshot.data!.docs
                            .map((doc) => doc['name'].toString())
                            .where((name) => name.isNotEmpty)
                            .toSet()
                            .toList();


                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: categoryList
                              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                          decoration: const InputDecoration(labelText: "Category"),
                          validator: (val) => val == null ? "Select a category" : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: _statuses.map((stat) => DropdownMenuItem(value: stat, child: Text(stat))).toList(),
                      onChanged: (val) => setState(() => _status = val),
                      decoration: const InputDecoration(labelText: "Display Tag (Optional)"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Description"),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitProduct,
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text("Add Product", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
