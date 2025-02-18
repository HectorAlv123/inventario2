// lib/screens/category_management_screen.dart
import 'package:flutter/material.dart';
import '../managers/category_manager.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _categoryController = TextEditingController();

  void _addCategory() {
    String newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      setState(() {
        CategoryManager.instance.addCategory(newCategory);
        _categoryController.clear();
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      CategoryManager.instance.removeCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryManager.instance.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Categorías"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para agregar nueva categoría
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: "Nueva categoría",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addCategory,
                  child: const Text("Agregar"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Lista de categorías
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCategory(category),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
