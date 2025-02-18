// lib/screens/dispatch_guide_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/order.dart';

class DispatchGuideDetailScreen extends StatelessWidget {
  final Order order;

  const DispatchGuideDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guía: ${order.guiaDespacho}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: order.products.isEmpty
            ? const Center(child: Text("No hay productos en esta guía."))
            : ListView.builder(
          itemCount: order.products.length,
          itemBuilder: (context, index) {
            final product = order.products[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(product.description),
                subtitle: Text(
                    "Cantidad: ${product.quantity}\nCategoría: ${product.category}\nUbicación: ${product.location}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
