// lib/models/order.dart
import 'inventory_item.dart';

class Order {
  final String id;
  final String guiaDespacho;
  final String proveedor;
  final String ubicacionRecepcion;
  final List<InventoryItem> products;
  bool isFinalized;
  final String? fotoGuia; // Ruta o URL de la imagen de la guía

  Order({
    required this.id,
    required this.guiaDespacho,
    required this.proveedor,
    required this.ubicacionRecepcion,
    List<InventoryItem>? products,
    this.isFinalized = false,
    this.fotoGuia,
  }) : products = products ?? [];
}
