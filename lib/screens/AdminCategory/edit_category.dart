import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class EditCategoryView extends StatefulWidget {
  final DocumentSnapshot categoryDoc;
  const EditCategoryView({super.key, required this.categoryDoc});

  @override
  State<EditCategoryView> createState() => _EditCategoryViewState();
}

class _EditCategoryViewState extends State<EditCategoryView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subController;
  late TextEditingController _aisleController;
  late TextEditingController _colorHexController;
  late TextEditingController _driveLinkController;

  bool _isLoading = false;
  Color? _previewColor;

  @override
  void initState() {
    super.initState();
    final data = widget.categoryDoc.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name'] ?? '');
    _subController = TextEditingController(text: data['sub'] ?? '');
    _aisleController = TextEditingController(text: data['aisle'] ?? '');
    _colorHexController = TextEditingController(text: data['colorHex'] ?? '');
    _driveLinkController = TextEditingController(text: data['imageURL'] ?? '');

    // Live preview for color hex
    _colorHexController.addListener(() {
      final hex = _colorHexController.text.replaceAll('#', '');
      if (hex.length == 6 || hex.length == 8) {
        try {
          final value = int.parse(hex.length == 6 ? "FF$hex" : hex, radix: 16);
          setState(() => _previewColor = Color(value));
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

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final imageURL = _convertDriveLink(_driveLinkController.text.trim());

    try {
      await widget.categoryDoc.reference.update({
        'name': _nameController.text.trim(),
        'sub': _subController.text.trim(),
        'aisle': _aisleController.text.trim(),
        'colorHex': _colorHexController.text.trim(),
        'imageURL': imageURL,
        'updatedAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
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

              // Color hex with preview
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _driveLinkController,
                decoration: const InputDecoration(
                  labelText: 'Google Drive Image Link',
                  filled: true,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                child: SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _updateCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB79BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Category',
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
