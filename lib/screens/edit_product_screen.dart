import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  final String initialName;
  final String initialCategory;
  final Function(String, String) onSave;

  const EditProductScreen({super.key, 
    required this.initialName,
    required this.initialCategory,
    required this.onSave,
  });

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late String _selectedCategory;

  final List<String> categories = [
    'Sin categoría',
    'Electrónica',
    'Ropa',
    'Alimentos',
    'Hogar',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedCategory = widget.initialCategory;
  }

  void _saveChanges() {
    final newName = _nameController.text;
    if (newName.isNotEmpty) {
      widget.onSave(newName, _selectedCategory);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del producto'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
