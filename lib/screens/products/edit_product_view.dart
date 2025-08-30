import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class EditProductView extends StatefulWidget {
  final DocumentSnapshot productDoc;
  const EditProductView({super.key, required this.productDoc});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;
  late TextEditingController _nutritionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _unitValueController;

  String? _selectedCategory;
  String? _status;
  String? _selectedUnitType;
  bool _isLoading = false;

  final List<String> _unitTypes = ['pcs', 'pack', 'box', 'set', 'g', 'kg', 'ml', 'L','fl oz'];
  final List<String> _statuses = ["Exclusive", "Popular", "New Arrival"];
  final List<String> _categories = [
    "Fruits & Vegetables", "Fishes & Meat", "Dairy", "Bakery", "Canned Goods",
    "Pantry Supplies", "Herbs & Spices", "Frozen Foods", "Ice Cream & Desserts",
    "Breakfast & Cereals", "Snacks Item", "Beverages", "Wine & Spirits",
    "Baby Products", "Feminine Care", "Personal Care", "Health & Wellness",
    "Cleaning Supplies", "Household Essentials", "Pet Supplies",
    "Stationery & Office", "Offers"
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

  @override
  void initState() {
    super.initState();
    final data = widget.productDoc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['productName']);
    _priceController = TextEditingController(text: data['price'].toString());
    _stockController = TextEditingController(text: data['stockLevel'].toString());
    _descriptionController = TextEditingController(text: data['description']);
    _discountController = TextEditingController(text: (data['discount'] ?? 0).toString());
    _nutritionController = TextEditingController(text: data['nutrition'] ?? '');
    _imageUrlController = TextEditingController(text: data['imageURL']);
    _unitValueController = TextEditingController(text: (data['unitValue'] ?? '').toString());
    _selectedUnitType = data['unitType'];
    _selectedCategory = data['category'];

    if (data['isExclusive'] == true) {
      _status = "Exclusive";
    } else if (data['isPopular'] == true) {
      _status = "Popular";
    } else {
      _status = "New Arrival";
    }
  }

  void _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final imageUrl = convertToDirectImageLink(_imageUrlController.text.trim());

      await widget.productDoc.reference.update({
        'productName': _nameController.text.trim(),
        'nutrition': _nutritionController.text.trim(),
        'price': double.parse(_priceController.text),
        'stockLevel': int.parse(_stockController.text),
        'description': _descriptionController.text.trim(),
        'discount': double.tryParse(_discountController.text) ?? 0,
        'category': _selectedCategory,
        'unitValue': _unitValueController.text.trim(),
        'unitType': _selectedUnitType,
        'isExclusive': _status == "Exclusive",
        'isPopular': _status == "Popular",
        'imageURL': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'isNewArrival': _status == "New Arrival",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
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
          title: const Text("Edit Product"),
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
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Unit Value"),
                            validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnitType,
                            items: _unitTypes.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) => setState(() => _selectedUnitType = val),
                            decoration: const InputDecoration(labelText: "Unit Type"),
                            validator: (val) => val == null ? "Select unit" : null,
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
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      decoration: const InputDecoration(labelText: "Category"),
                      validator: (val) => val == null ? "Select a category" : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                        onPressed: _isLoading ? null : _updateProduct,
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text("Update Product", style: TextStyle(fontSize: 16)),
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
