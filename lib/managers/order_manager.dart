import '../models/order.dart';

class OrderManager {
  static final OrderManager instance = OrderManager._internal();
  OrderManager._internal();

  final List<Order> orders = [];

  void addOrder(Order order) {
    orders.add(order);
  }

  // Devuelve el primer pedido guardado que no esté finalizado (si existe)
  Order? get pendingOrder {
    try {
      return orders.firstWhere((order) => order.isFinalized == false);
    } catch (e) {
      return null;
    }
  }
}
