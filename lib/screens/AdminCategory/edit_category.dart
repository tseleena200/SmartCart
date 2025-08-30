import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants.dart'; // <- uses primaryColor, secondaryColor, etc.

class EditCategoryView extends StatefulWidget {
  final DocumentSnapshot categoryDoc; // must be a real doc
  const EditCategoryView({super.key, required this.categoryDoc});

  @override
  State<EditCategoryView> createState() => _EditCategoryViewState();
}

class _EditCategoryViewState extends State<EditCategoryView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _subController;
  late final TextEditingController _aisleController;
  late final TextEditingController _colorHexController;
  late final TextEditingController _driveLinkController;

  bool _isLoading = false;
  Color? _previewColor;

  // -------- HELPERS --------
  String? _validateRequired(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _validateHex(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final hexPattern = RegExp(r'^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    if (!hexPattern.hasMatch(value.trim())) {
      return 'Invalid hex (use #RRGGBB or #AARRGGBB)';
    }
    return null;
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

  void _updatePreviewFromHex(String hexText) {
    final text = hexText.replaceAll('#', '');
    if (text.length == 6 || text.length == 8) {
      try {
        final value = int.parse(text.length == 6 ? "FF$text" : text, radix: 16);
        setState(() => _previewColor = Color(value));
      } catch (_) {
        setState(() => _previewColor = null);
      }
    } else {
      setState(() => _previewColor = null);
    }
  }

  // -------- LIFECYCLE --------
  @override
  void initState() {
    super.initState();
    final data = Map<String, dynamic>.from(
        (widget.categoryDoc.data() ?? {}) as Map<String, dynamic>);

    _nameController = TextEditingController(text: data['name'] ?? '');
    _subController = TextEditingController(text: data['sub'] ?? '');
    _aisleController = TextEditingController(text: data['aisle'] ?? '');
    _colorHexController = TextEditingController(text: data['colorHex'] ?? '');
    _driveLinkController = TextEditingController(text: data['imageURL'] ?? '');

    _updatePreviewFromHex(_colorHexController.text);
    _colorHexController.addListener(() {
      _updatePreviewFromHex(_colorHexController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subController.dispose();
    _aisleController.dispose();
    _colorHexController.dispose();
    _driveLinkController.dispose();
    super.dispose();
  }

  // -------- ACTIONS --------
  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await widget.categoryDoc.reference.update({
        'name': _nameController.text.trim(),
        'sub': _subController.text.trim(),
        'aisle': _aisleController.text.trim(),
        'colorHex': _colorHexController.text.trim(),
        'imageURL': _convertDriveLink(_driveLinkController.text.trim()),
        'updatedAt': Timestamp.now(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category updated successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text(
          'Are you sure you want to delete this category? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.categoryDoc.reference.delete();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
        backgroundColor: secondaryColor, // constant
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
                validator: _validateRequired,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  filled: true,
                ),
                validator: _validateRequired,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aisleController,
                decoration: const InputDecoration(
                  labelText: 'Aisle',
                  filled: true,
                ),
                validator: _validateRequired,
              ),
              const SizedBox(height: 16),

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
                      validator: _validateHex,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
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
                validator: _validateRequired,
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    // Update button -> primaryColor
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _updateCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Delete button -> secondaryColor (theme)
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _deleteCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
