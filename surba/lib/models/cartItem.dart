import 'package:SurbaMart/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem {
  final String productId;
  final String name;
  final int quantity;
  final double cost;
  double discount; // New field to store the discount

  CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.cost,
    this.discount = 0.0, // Initialize discount to 0.0
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId, // Include this field in the map
      'name': name,
      'quantity': quantity,
      'cost': cost,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '', // Retrieve productId from the map
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      cost: map['cost'] ?? 0.0,
    );
  }
}

class CartModel extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(Product product, {int quantity = 1}) {
    // Check if the item is already in the cart
    int index = _cartItems.indexWhere((item) => item.name == product.name);

    if (index != -1) {
      // If the item is in the cart, increase the quantity
      _cartItems[index] = CartItem(
        name: product.name,
        quantity: _cartItems[index].quantity + quantity,
        cost: _cartItems[index].cost + product.cost * quantity,
        productId: product.id, // Update the cost
      );
    } else {
      // If the item is not in the cart, add it with the specified quantity
      _cartItems.add(CartItem(
        name: product.name,
        quantity: quantity,
        cost: product.cost * quantity,
        productId: product.id, // Set the initial cost
      ));
    }

    // Notify listeners that the cart has been updated
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  double getTotalCost() {
    return _cartItems.fold(0, (sum, item) => sum + item.cost);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Add more methods as needed for cart management (e.g., remove from cart)
}
