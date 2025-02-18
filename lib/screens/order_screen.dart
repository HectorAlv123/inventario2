// lib/screens/order_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../models/order.dart';
import '../managers/order_manager.dart';
import '../managers/inventory_manager.dart';
import '../managers/category_manager.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final TextEditingController _guiaController = TextEditingController();
  final TextEditingController _proveedorController = TextEditingController();
  // Lista de productos que se agregarán al pedido.
  List<InventoryItem> orderProducts = [];
  // Datos del pedido.
  String? guiaDespacho;
  String? proveedor;
  String? ubicacionRecepcion;
  // Ruta de la foto de la guía (opcional).
  String? fotoGuia;
  // Lista fija de ubicaciones de recepción.
  final List<String> _ubicaciones = ['Galpón Azul', 'Galpón Verde', 'Bodega de EPPs'];
  final Uuid uuid = const Uuid();
  final ImagePicker _picker = ImagePicker();

  // Método para seleccionar imagen de la galería.
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        fotoGuia = pickedFile.path;
      });
    }
  }

  // Reabre un pedido guardado pendiente para edición.
  void _reopenOrder(Order order) {
    setState(() {
      guiaDespacho = order.guiaDespacho;
      proveedor = order.proveedor;
      ubicacionRecepcion = order.ubicacionRecepcion;
      orderProducts = List.from(order.products);
      fotoGuia = order.fotoGuia;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pedido reabierto para edición.")),
    );
  }

  // Crea el pedido ingresando guía, proveedor, ubicación y (opcionalmente) la foto.
  void _createOrder() {
    if (_guiaController.text.trim().isEmpty ||
        _proveedorController.text.trim().isEmpty ||
        ubicacionRecepcion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa la guía, el proveedor y la ubicación de recepción.")),
      );
      return;
    }
    setState(() {
      guiaDespacho = _guiaController.text.trim();
      proveedor = _proveedorController.text.trim();
    });
  }

  // Función para agregar un producto al pedido, con campos: Producto, Cantidad y Categoría.
  void _addProduct() async {
    if (guiaDespacho == null || proveedor == null || ubicacionRecepcion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero crea el pedido ingresando todos los datos.")),
      );
      return;
    }
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    // Extrae la lista de productos existentes para sugerir.
    final List<String> existingProducts = InventoryManager.instance.inventoryItems
        .map((item) => item.description)
        .toSet()
        .toList();
    // Usamos el CategoryManager para obtener las categorías, o un valor fijo si está vacío.
    final List<String> catOptions = CategoryManager.instance.categories.isNotEmpty
        ? CategoryManager.instance.categories
        : ['Sin categoría'];
    String selectedCategory = catOptions.first;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Agregar producto al pedido"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Autocomplete para sugerir productos existentes.
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return existingProducts.where((option) => option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
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
                        if (val != null) {
                          selectedCategory = val;
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: "Categoría"),
                  ),
                ],
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
                    final newProduct = InventoryItem(
                      id: uuid.v4(),
                      description: descriptionController.text.trim(),
                      guiaDespacho: guiaDespacho,
                      quantity: qty,
                      receiver: "Pedido",
                      receptionDateTime: DateTime.now(),
                      // Cuando finalices el pedido, se asignará la ubicación de recepción.
                      location: ubicacionRecepcion!,
                      category: selectedCategory,
                    );
                    setState(() {
                      orderProducts.add(newProduct);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Agregar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Guarda el pedido provisional en OrderManager (para terminar más tarde).
  void _saveOrderTemporarily() {
    if (guiaDespacho == null ||
        proveedor == null ||
        ubicacionRecepcion == null ||
        orderProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa el pedido antes de guardarlo.")),
      );
      return;
    }
    Order newOrder = Order(
      id: uuid.v4(),
      guiaDespacho: guiaDespacho!,
      proveedor: proveedor!,
      ubicacionRecepcion: ubicacionRecepcion!,
      products: List.from(orderProducts),
    );
    Order? existing = OrderManager.instance.pendingOrder;
    if (existing != null) {
      existing.products.clear();
      existing.products.addAll(newOrder.products);
    } else {
      OrderManager.instance.addOrder(newOrder);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pedido guardado (pendiente). Total productos: ${newOrder.products.length}")),
    );
    // No se limpia la pantalla para permitir continuar la edición.
  }

  // Finaliza el pedido: se confirma y se agregan los productos al inventario con la ubicación de recepción.
  void _finalizeOrder() async {
    if (guiaDespacho == null ||
        proveedor == null ||
        ubicacionRecepcion == null ||
        orderProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa el pedido antes de finalizarlo.")),
      );
      return;
    }
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar finalización"),
          content: const Text("¿Estás seguro de que la guía está terminada y deseas finalizar el pedido?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    Order newOrder = Order(
      id: uuid.v4(),
      guiaDespacho: guiaDespacho!,
      proveedor: proveedor!,
      ubicacionRecepcion: ubicacionRecepcion!,
      products: List.from(orderProducts),
      isFinalized: true,
      fotoGuia: fotoGuia, // Guarda la ruta de la foto, si se adjuntó.
    );
    OrderManager.instance.addOrder(newOrder);
    // Al finalizar, se agregan los productos al inventario con la ubicación de recepción.
    for (var prod in orderProducts) {
      InventoryManager.instance.inventoryItems.add(
        InventoryItem(
          id: uuid.v4(),
          description: prod.description,
          guiaDespacho: prod.guiaDespacho,
          quantity: prod.quantity,
          receiver: prod.receiver,
          receptionDateTime: prod.receptionDateTime,
          location: ubicacionRecepcion!,
          category: prod.category,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pedido finalizado guardado. Total productos: ${newOrder.products.length}")),
    );
    setState(() {
      guiaDespacho = null;
      proveedor = null;
      ubicacionRecepcion = null;
      _guiaController.clear();
      _proveedorController.clear();
      orderProducts.clear();
      fotoGuia = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = OrderManager.instance.orders;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedidos con Guía"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Order? pending = OrderManager.instance.pendingOrder;
              if (pending != null) {
                _reopenOrder(pending);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No hay pedidos guardados pendientes.")),
                );
              }
            },
            tooltip: "Reabrir pedido guardado",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (guiaDespacho == null || proveedor == null || ubicacionRecepcion == null)
            ? Column(
          children: [
            TextField(
              controller: _guiaController,
              decoration: const InputDecoration(labelText: "Número de Guía de Despacho"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _proveedorController,
              decoration: const InputDecoration(labelText: "Proveedor"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: ubicacionRecepcion,
              hint: const Text("Selecciona ubicación de recepción"),
              items: _ubicaciones.map((loc) {
                return DropdownMenuItem(
                  value: loc,
                  child: Text(loc),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  ubicacionRecepcion = val;
                });
              },
              decoration: const InputDecoration(labelText: "Ubicación de Recepción"),
            ),
            const SizedBox(height: 10),
            // Botón para adjuntar foto de la guía
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Adjuntar Foto de la Guía"),
            ),
            // Muestra un preview de la foto si se seleccionó
            if (fotoGuia != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(fotoGuia!),
                  height: 150,
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _createOrder,
              child: const Text("Crear Pedido"),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade100,
              child: ListTile(
                title: const Text(
                  "Pedido creado",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Guía: $guiaDespacho\nProveedor: $proveedor\nUbicación: $ubicacionRecepcion"),
              ),
            ),
            const SizedBox(height: 10),
            // Si hay foto, muestra un preview y un botón para descargar o compartir
            if (fotoGuia != null)
              Column(
                children: [
                  const Text("Foto adjunta:"),
                  Image.file(File(fotoGuia!), height: 150),
                  // Aquí puedes agregar botones para compartir o descargar la imagen.
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addProduct,
                    child: const Text("Agregar productos con guía"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orderProducts.length,
                itemBuilder: (context, index) {
                  final prod = orderProducts[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(prod.description),
                      subtitle: Text("Cantidad: ${prod.quantity}\nCategoría: ${prod.category}"),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveOrderTemporarily,
                    child: const Text("Guardar y terminar más tarde"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _finalizeOrder,
                    child: const Text("Guía terminada"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: orders.isNotEmpty
          ? Container(
        color: Colors.grey.shade200,
        height: 150,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Pedidos guardados",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return InkWell(
                    onTap: () => _reopenOrder(order),
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Guía: ${order.guiaDespacho}"),
                            Text("Proveedor: ${order.proveedor}"),
                            Text("Ubicación: ${order.ubicacionRecepcion}"),
                            Text("Productos: ${order.products.length}"),
                            Text(order.isFinalized ? "Finalizado" : "Pendiente"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }
}
