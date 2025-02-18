import 'package:flutter/material.dart';

class TestFabScreen extends StatelessWidget {
  const TestFabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea( // Usamos SafeArea para asegurarnos que nada interfiera
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Test FAB"),
        ),
        body: const Center(
          child: Text("Pantalla de prueba para FAB"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("FAB presionado")),
            );
          },
          child: const Icon(Icons.add),
          tooltip: "Agregar Registro",
        ),
      ),
    );
  }
}
