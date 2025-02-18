import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AddProductScreen extends StatefulWidget {
  final Function(String, String, String, int) onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await DatabaseHelper.instance.getCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['name'] as String;
      }
    });
  }

  void _addCategory(String categoryName) async {
    await DatabaseHelper.instance.insertCategory(categoryName);
    _loadCategories();
  }

  void _submitProduct() {
    final String name = _nameController.text.trim();
    final String description = _descriptionController.text.trim();
    final int quantity = int.tryParse(_quantityController.text) ?? 0;

    if (name.isNotEmpty && _selectedCategory != null) {
      widget.onProductAdded(name, _selectedCategory!, description, quantity);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCategory,
              items: _categories.map<DropdownMenuItem<String>>((category) {
                return DropdownMenuItem<String>(
                  value: category['name'] as String,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final TextEditingController categoryController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Agregar Categoría'),
                      content: TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(labelText: 'Nombre de la categoría'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            final categoryName = categoryController.text.trim();
                            if (categoryName.isNotEmpty) {
                              _addCategory(categoryName);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Agregar'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Agregar nueva categoría'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitProduct,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
