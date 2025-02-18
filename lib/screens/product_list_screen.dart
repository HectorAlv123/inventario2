// lib/screens/product_list_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../managers/inventory_manager.dart';
import '../managers/category_manager.dart';
import '../models/inventory_item.dart';
import '../services/excel_service.dart';

class ProductListScreen extends StatefulWidget {
  final bool isAdmin;
  final String warehouse;

  const ProductListScreen({
    Key? key,
    required this.isAdmin,
    required this.warehouse,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchQuery = "";
  String selectedLocation = 'Todas las ubicaciones';

  // Lista fija de ubicaciones, con opción "Todas las ubicaciones".
  final List<String> locations = [
    'Todas las ubicaciones',
    'Galpón Azul',
    'Galpón Verde',
    'Bodega de EPPs'
  ];

  // Retorna los productos filtrados por ubicación y búsqueda.
  List<InventoryItem> get filteredItems {
    List<InventoryItem> items = InventoryManager.instance.inventoryItems;
    if (selectedLocation != 'Todas las ubicaciones') {
      items = items.where((item) => item.location == selectedLocation).toList();
    }
    if (searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.description.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    return items;
  }

  void _sort<T>(Comparable<T> Function(InventoryItem item) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      InventoryManager.instance.inventoryItems.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  Future<void> _exportToExcel() async {
    String csvData =
        "ID,Descripción,Guía de despacho,Cantidad,Usuario,Fecha/Hora,Ubicación,Categoría\n" +
            filteredItems.map((i) {
              return "${i.id},${i.description},${i.guiaDespacho ?? ''},${i.quantity},${i.receiver},${i.receptionDateTime.toIso8601String()},${i.location},${i.category}";
            }).join("\n");

    List<int> fileBytes = utf8.encode(csvData);
    Directory directory = await getApplicationDocumentsDirectory();

    try {
      ExcelService.generarArchivoExcel(fileBytes, directory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Archivo exportado en ${directory.path}/Inventario_Bodegas.xlsx")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al exportar: $e")),
      );
    }
  }

  // Diálogo para agregar/editar un producto.
  Future<void> _showAddEditDialog({InventoryItem? item}) async {
    final TextEditingController descriptionController = TextEditingController(text: item?.description ?? '');
    final TextEditingController quantityController = TextEditingController(text: item != null ? item.quantity.toString() : '');
    final TextEditingController receiverController = TextEditingController(text: item?.receiver ?? '');
    final List<String> catOptions = CategoryManager.instance.categories.isNotEmpty
        ? CategoryManager.instance.categories
        : ['Sin categoría'];
    String selectedCategory = item?.category ?? catOptions.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(item == null ? "Agregar Producto" : "Editar Producto"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                        final existing = InventoryManager.instance.inventoryItems
                            .map((item) => item.description)
                            .toSet()
                            .toList();
                        return existing.where((option) =>
                            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        descriptionController.text = selection;
                      },
                      fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                        fieldTextEditingController.text = descriptionController.text;
                        return TextField(
                          controller: fieldTextEditingController,
                          focusNode: fieldFocusNode,
                          decoration: const InputDecoration(labelText: "Producto"),
                        );
                      },
                    ),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: "Cantidad"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: receiverController,
                      decoration: const InputDecoration(labelText: "Usuario"),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: catOptions.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          if (val != null) selectedCategory = val;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Categoría"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final int qty = int.tryParse(quantityController.text) ?? 0;
                    if (descriptionController.text.trim().isEmpty || qty <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Datos inválidos")),
                      );
                      return;
                    }
                    if (item == null) {
                      final newItem = InventoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        description: descriptionController.text.trim(),
                        guiaDespacho: null,
                        quantity: qty,
                        receiver: receiverController.text.trim(),
                        receptionDateTime: DateTime.now(),
                        location: "Sin definir",
                        category: selectedCategory,
                      );
                      setState(() {
                        InventoryManager.instance.inventoryItems.add(newItem);
                      });
                    } else {
                      // Crear un objeto actualizado y reemplazar el existente.
                      final updatedItem = InventoryItem(
                        id: item.id,
                        description: descriptionController.text.trim(),
                        guiaDespacho: item.guiaDespacho,
                        quantity: qty,
                        receiver: receiverController.text.trim(),
                        receptionDateTime: item.receptionDateTime,
                        location: item.location,
                        category: selectedCategory,
                      );
                      int index = InventoryManager.instance.inventoryItems.indexWhere((i) => i.id == item.id);
                      if (index != -1) {
                        setState(() {
                          InventoryManager.instance.inventoryItems[index] = updatedItem;
                        });
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addProduct() {
    _showAddEditDialog();
  }

  void _deleteProduct(InventoryItem item) {
    setState(() {
      InventoryManager.instance.inventoryItems.removeWhere((i) => i.id == item.id);
    });
  }

  void _editProduct(InventoryItem item) {
    _showAddEditDialog(item: item);
  }

  @override
  Widget build(BuildContext context) {
    final List<InventoryItem> items = filteredItems;
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventario - ${widget.warehouse}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToExcel,
            tooltip: "Exportar a Excel",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Buscar producto",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedLocation,
              items: locations.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Text(loc),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  if (val != null) selectedLocation = val;
                });
              },
              decoration: const InputDecoration(labelText: "Filtrar por Ubicación"),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: _sortAscending,
                sortColumnIndex: _sortColumnIndex,
                columns: [
                  DataColumn(
                    label: const Text("Producto"),
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((item) => item.description, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text("Cantidad"),
                    numeric: true,
                    onSort: (columnIndex, ascending) =>
                        _sort<num>((item) => item.quantity, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text("Categoría"),
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((item) => item.category, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text("Fecha/Hora"),
                    onSort: (columnIndex, ascending) =>
                        _sort<DateTime>((item) => item.receptionDateTime, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text("Ubicación"),
                    onSort: (columnIndex, ascending) =>
                        _sort<String>((item) => item.location, columnIndex, ascending),
                  ),
                  const DataColumn(label: Text("Acciones")),
                ],
                rows: items.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.description)),
                    DataCell(Text(item.quantity.toString())),
                    DataCell(Text(item.category)),
                    DataCell(Text(item.receptionDateTime.toString())),
                    DataCell(Text(item.location)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editProduct(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteProduct(item),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
        tooltip: "Agregar Producto",
      ),
    );
  }
}
