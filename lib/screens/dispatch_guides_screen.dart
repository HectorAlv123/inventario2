// lib/screens/dispatch_guides_screen.dart
import 'package:flutter/material.dart';
import '../managers/order_manager.dart';
import '../models/order.dart';
import 'dispatch_guide_detail_screen.dart';

class DispatchGuidesScreen extends StatelessWidget {
  const DispatchGuidesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = OrderManager.instance.orders;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guías de Despacho"),
      ),
      body: orders.isEmpty
          ? const Center(child: Text("No hay guías de despacho guardadas."))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DispatchGuideDetailScreen(order: order),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Guía: ${order.guiaDespacho}", style: const TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}
