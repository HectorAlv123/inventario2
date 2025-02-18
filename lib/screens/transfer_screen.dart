// lib/screens/transfer_screen.dart
import 'package:flutter/material.dart';
import '../managers/inventory_manager.dart';
import '../models/inventory_item.dart';
import '../models/transfer_record.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String? selectedSourceLocation;
  String? selectedDestinationLocation;
  InventoryItem? selectedItem;
  int transferQuantity = 0;
  // Supongamos que el usuario actual es "admin" (esto vendría del login)
  final String currentUser = "admin";

  // Como el nombre de quien envía será fijo, no permitimos editarlo.
  // Podemos preseter un TextEditingController con ese valor.
  final TextEditingController deliveredByController = TextEditingController(text: "admin");

  final List<String> locations = ['Galpón Azul', 'Galpón Verde', 'Bodega de EPPs'];

  // Retorna la lista de productos disponibles en la ubicación de origen con cantidad > 0.
  List<InventoryItem> get sourceItems {
    if (selectedSourceLocation == null) return [];
    return InventoryManager.instance.inventoryItems.where((item) {
      return item.location == selectedSourceLocation && item.quantity > 0;
    }).toList();
  }

  void _performTransfer() {
    if (selectedItem == null ||
        transferQuantity <= 0 ||
        selectedSourceLocation == null ||
        selectedDestinationLocation == null ||
        deliveredByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complete todos los campos para realizar la transferencia."),
        ),
      );
      return;
    }
    if (selectedItem!.quantity < transferQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cantidad insuficiente en el inventario.")),
      );
      return;
    }

    // Actualiza el inventario en el origen restando la cantidad.
    setState(() {
      selectedItem!.quantity -= transferQuantity;
      // Si la cantidad queda en 0, eliminamos el item del inventario.
      if (selectedItem!.quantity == 0) {
        InventoryManager.instance.inventoryItems.removeWhere((item) => item.id == selectedItem!.id);
      }
    });

    // Busca si ya existe un item en la ubicación de destino con el mismo producto.
    InventoryItem? destItem;
    try {
      destItem = InventoryManager.instance.inventoryItems.firstWhere(
            (item) =>
        item.location == selectedDestinationLocation &&
            item.description == selectedItem!.description,
      );
    } catch (e) {
      destItem = null;
    }

    if (destItem != null) {
      setState(() {
        destItem!.quantity += transferQuantity;
      });
    } else {
      // Crea un nuevo registro en el inventario para la ubicación de destino,
      // copiando la categoría del producto original.
      InventoryItem newItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        description: selectedItem!.description,
        guiaDespacho: null,
        quantity: transferQuantity,
        receiver: deliveredByController.text,
        receptionDateTime: DateTime.now(),
        location: selectedDestinationLocation!,
        category: selectedItem!.category,
      );
      InventoryManager.instance.inventoryItems.add(newItem);
    }

    // Registra la transferencia.
    TransferRecord record = TransferRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: selectedItem!.id,
      description: selectedItem!.description,
      quantity: transferQuantity,
      deliveredBy: deliveredByController.text,
      fromLocation: selectedSourceLocation!,
      toLocation: selectedDestinationLocation!,
      transferDateTime: DateTime.now(),
    );
    InventoryManager.instance.transferRecords.add(record);

    // Reinicia el formulario.
    setState(() {
      selectedItem = null;
      transferQuantity = 0;
      // No modificamos deliveredByController, ya que siempre es el mismo.
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transferencia realizada con éxito.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Para el dropdown de destino, filtramos las ubicaciones para no incluir la fuente.
    List<String> destinationOptions = locations.where((loc) => loc != selectedSourceLocation).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Transferencias")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de ubicación de origen.
            DropdownButtonFormField<String>(
              value: selectedSourceLocation,
              hint: const Text("Selecciona ubicación de origen"),
              items: locations
                  .map((loc) => DropdownMenuItem(
                value: loc,
                child: Text(loc),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedSourceLocation = val;
                  selectedItem = null; // Reinicia el producto seleccionado.
                  // Reinicia la opción de destino al no ser la misma.
                  selectedDestinationLocation = null;
                });
              },
            ),
            const SizedBox(height: 10),
            // Selección del producto a transferir de la ubicación de origen.
            DropdownButtonFormField<InventoryItem>(
              value: selectedItem,
              hint: const Text("Selecciona producto a transferir"),
              items: sourceItems
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text("${item.description} (Cantidad: ${item.quantity})"),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedItem = val;
                });
              },
            ),
            const SizedBox(height: 10),
            // Campo para ingresar la cantidad a transferir.
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad a transferir"),
              onChanged: (val) {
                setState(() {
                  transferQuantity = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            // Campo de solo lectura para "Entregado por", fijo al usuario actual.
            TextFormField(
              controller: deliveredByController,
              decoration: const InputDecoration(labelText: "Entregado por"),
              readOnly: true,
            ),
            const SizedBox(height: 10),
            // Selección de ubicación de destino (excluye la fuente).
            DropdownButtonFormField<String>(
              value: selectedDestinationLocation,
              hint: const Text("Selecciona ubicación de destino"),
              items: destinationOptions
                  .map((loc) => DropdownMenuItem(
                value: loc,
                child: Text(loc),
              ))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedDestinationLocation = val;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _performTransfer,
                child: const Text("Realizar Transferencia"),
              ),
            ),
            const Divider(height: 40),
            const Text(
              "Historial de Transferencias",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: InventoryManager.instance.transferRecords.length,
              itemBuilder: (context, index) {
                final record = InventoryManager.instance.transferRecords[index];
                return ListTile(
                  title: Text("${record.description} (${record.quantity})"),
                  subtitle: Text(
                    "De: ${record.fromLocation}  →  ${record.toLocation}\n"
                        "Entregado por: ${record.deliveredBy}\n"
                        "Fecha: ${record.transferDateTime.day}/${record.transferDateTime.month}/${record.transferDateTime.year} "
                        "${record.transferDateTime.hour}:${record.transferDateTime.minute}",
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
