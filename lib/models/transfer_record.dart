// lib/models/transfer_record.dart
class TransferRecord {
  final String id;
  final String itemId;
  final String description;
  final int quantity;
  final String deliveredBy;
  final String fromLocation;
  final String toLocation;
  final DateTime transferDateTime;

  TransferRecord({
    required this.id,
    required this.itemId,
    required this.description,
    required this.quantity,
    required this.deliveredBy,
    required this.fromLocation,
    required this.toLocation,
    required this.transferDateTime,
  });
}
