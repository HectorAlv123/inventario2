class InventoryItem {
  final String id;
  final String description;
  final String? guiaDespacho;
  int quantity; // mutable
  final String receiver;
  final DateTime receptionDateTime;
  final String location;
  final String category;

  InventoryItem({
    required this.id,
    required this.description,
    this.guiaDespacho,
    required this.quantity,
    required this.receiver,
    required this.receptionDateTime,
    required this.location,
    required this.category,
  });
}
