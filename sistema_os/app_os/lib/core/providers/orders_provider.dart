import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/order.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> orders = [];

  Future<void> fetchOrders(String token) async {
    try {
      final data = await ApiService.get("/orders", token: token);

      orders = (data as List).map((o) => OrderModel.fromJson(o)).toList();

      notifyListeners();
    } catch (e) {
      print("Erro ao carregar ordens: $e");
    }
  }
}
