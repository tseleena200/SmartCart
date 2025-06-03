import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';

class AddCategoryView extends StatefulWidget {
  const AddCategoryView({super.key});

  @override
  State<AddCategoryView> createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subController = TextEditingController();
  final TextEditingController _aisleController = TextEditingController();
  final TextEditingController _colorHexController = TextEditingController();
  final TextEditingController _driveLinkController = TextEditingController();

  bool _isLoading = false;
  Color? _previewColor;

  @override
  void initState() {
    super.initState();

    _colorHexController.addListener(() {
      final hex = _colorHexController.text.replaceAll('#', '');
      if (hex.length == 6 || hex.length == 8) {
        try {
          final value = int.parse(hex.length == 6 ? "FF$hex" : hex, radix: 16);
          setState(() {
            _previewColor = Color(value);
          });
        } catch (_) {
          setState(() => _previewColor = null);
        }
      } else {
        setState(() => _previewColor = null);
      }
    });
  }

  String _convertDriveLink(String url) {
    final regExp = RegExp(r'd/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(url);
    if (match != null) {
      final fileId = match.group(1);
      return "https://drive.google.com/uc?export=view&id=$fileId";
    }
    return url;
  }

  Future<void> _submitCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final String imageURL = _convertDriveLink(_driveLinkController.text.trim());

    try {
      await FirebaseFirestore.instance.collection('Categories').add({
        'name': _nameController.text.trim(),
        'sub': _subController.text.trim(),
        'aisle': _aisleController.text.trim(),
        'colorHex': _colorHexController.text.trim(),
        'imageURL': imageURL,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add category: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category"),
        backgroundColor: secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  filled: true,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _driveLinkController,
                decoration: const InputDecoration(
                  labelText: 'Google Drive Share Link (Image)',
                  filled: true,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _subController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  filled: true,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _aisleController,
                decoration: const InputDecoration(
                  labelText: 'Aisle',
                  filled: true,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Hex Color Input with Preview
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _colorHexController,
                      decoration: const InputDecoration(
                        labelText: 'Color Hex (e.g. #FFECE4)',
                        filled: true,
                      ),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _previewColor ?? Colors.grey.shade300,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB79BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Category',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
