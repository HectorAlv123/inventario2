// lib/managers/inventory_manager.dart
import '../models/inventory_item.dart';
import '../models/transfer_record.dart';

class InventoryManager {
  static final InventoryManager instance = InventoryManager._internal();

  InventoryManager._internal();

  List<InventoryItem> inventoryItems = [];
  List<TransferRecord> transferRecords = [];
}
