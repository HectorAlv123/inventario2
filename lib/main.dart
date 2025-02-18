import 'dart:math';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/transfer_screen.dart';
import 'screens/category_management_screen.dart';
import 'screens/order_screen.dart';
import 'screens/dispatch_guides_screen.dart';
import 'managers/inventory_manager.dart';
import 'managers/category_manager.dart';
import 'models/inventory_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Bodega',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/inventory': (context) => const ProductListScreen(isAdmin: true, warehouse: "18B"),
        '/transfer': (context) => const TransferScreen(),
        '/categories': (context) => const CategoryManagementScreen(),
        '/order': (context) => const OrderScreen(),
        '/dispatchGuides': (context) => const DispatchGuidesScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Función para generar datos aleatorios de prueba.
  void _generateFakeData(BuildContext context) {
    // Lista de categorías de ferretería.
    List<String> categorias = ['Herramientas', 'Materiales', 'Insumos', 'Accesorios'];
    // Actualiza el CategoryManager.
    CategoryManager.instance.categories
      ..clear()
      ..addAll(categorias);

    // Lista de ubicaciones fijas.
    List<String> ubicaciones = ['Galpón Azul', 'Galpón Verde', 'Bodega de EPPs'];

    // Lista de productos de ferretería.
    List<Map<String, String>> productos = [
      {'description': 'Martillo', 'category': 'Herramientas'},
      {'description': 'Sierra Circular', 'category': 'Herramientas'},
      {'description': 'Taladro', 'category': 'Herramientas'},
      {'description': 'Clavos', 'category': 'Materiales'},
      {'description': 'Tornillos', 'category': 'Materiales'},
      {'description': 'Cemento', 'category': 'Materiales'},
      {'description': 'Guantes de trabajo', 'category': 'Insumos'},
      {'description': 'Gafas de seguridad', 'category': 'Accesorios'},
      {'description': 'Cinta métrica', 'category': 'Accesorios'},
      {'description': 'Nivel de burbuja', 'category': 'Accesorios'},
    ];

    Random random = Random();

    // Limpia la base de datos actual.
    InventoryManager.instance.inventoryItems.clear();

    // Agrega productos con cantidades aleatorias y ubicaciones asignadas aleatoriamente.
    for (var prod in productos) {
      InventoryManager.instance.inventoryItems.add(
        InventoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() +
              random.nextInt(1000).toString(),
          description: prod['description']!,
          guiaDespacho: null,
          quantity: random.nextInt(50) + 1, // cantidad entre 1 y 50
          receiver: 'Recepción automática',
          receptionDateTime:
          DateTime.now().subtract(Duration(days: random.nextInt(30))),
          location: ubicaciones[random.nextInt(ubicaciones.length)],
          category: prod['category']!,
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Datos de prueba generados.")),
    );
  }

  // Botón estilizado
  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inicio")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(context, "Inventario", () {
              Navigator.pushNamed(context, '/inventory');
            }),
            const SizedBox(height: 10),
            _buildButton(context, "Transferencias", () {
              Navigator.pushNamed(context, '/transfer');
            }),
            const SizedBox(height: 10),
            _buildButton(context, "Gestión de Categorías", () {
              Navigator.pushNamed(context, '/categories');
            }),
            const SizedBox(height: 10),
            _buildButton(context, "Pedido con Guía", () {
              Navigator.pushNamed(context, '/order');
            }),
            const SizedBox(height: 10),
            _buildButton(context, "Guías de Despacho", () {
              Navigator.pushNamed(context, '/dispatchGuides');
            }),
            const SizedBox(height: 20),
            _buildButton(context, "Generar Datos de Prueba", () {
              _generateFakeData(context);
            }),
          ],
        ),
      ),
    );
  }
}
