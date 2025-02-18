class Product {
  final int? id;
  final String name;
  final String category;
  final String description;
  int quantity;  // Ahora sí permite modificar la cantidad
  final String warehouse;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.quantity,
    required this.warehouse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'quantity': quantity,
      'warehouse': warehouse,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      quantity: map['quantity'],
      warehouse: map['warehouse'],
    );
  }
}
