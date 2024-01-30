import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopper_app/models/cartItem.dart';
import 'package:shopper_app/models/product.dart';
import 'package:shopper_app/user/checkout_page.dart';

class ShoppingCartPage extends StatelessWidget {
  ShoppingCartPage({Key? key}) : super(key: key);
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: Consumer<CartModel>(
        builder: (context, cart, child) {
          return ListView.builder(
            itemCount: cart.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cart.cartItems[index];
              return FutureBuilder<List<Product>>(
                // Fetch the product based on the productId in the cart item
                future: fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final productList = snapshot.data ?? [];
                    final product =
                        getProductById(cartItem.productId, productList);
                    final discount = getDiscount(cartItem, product);

                    return ListTile(
                      title: Text('${cartItem.name} - \₹${cartItem.cost}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${cartItem.quantity}'),
                          if (discount != 0)
                            Text('Discount: \₹${discount.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_shopping_cart),
                        onPressed: () {
                          // Remove the item from the cart
                          cart.removeItem(cartItem);
                        },
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartModel>(
        builder: (context, cart, child) {
          return FutureBuilder<List<Product>>(
            // Fetch the product list
            future: fetchProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                // Get the product list from the snapshot
                final productList = snapshot.data ?? [];
                double totalCost =
                    cart.getTotalCost() - getDiscountTotal(cart, productList);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items: ${cart.cartItems.length}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            'Total Cost: \₹${totalCost.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CheckoutFormPage(),
                            ),
                          );
                        },
                        child: Text('Checkout'),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  // Function to fetch the product based on productId
  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot = await products.get();

      List<Product> productList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          name: data['Name'] ?? '',
          stock: data['Stock'] ?? 0,
          id: data['Id'] ?? '',
          categoryId: data['CategoryId'] ?? '',
          cost: (data['Cost'] ?? 0).toDouble(),
          imageUrl: data['Image'] ?? '',
          discountTiers: (data['DiscountTiers'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>(),
        );
      }).toList();

      return productList;
    } catch (e) {
      print('Error fetching products: $e');
      throw e;
    }
  }

  // Function to calculate the discount for a cart item
  double getDiscount(CartItem cartItem, Product? product) {
    // Check if the product and its discount tiers exist
    if (product != null &&
        product.discountTiers != null &&
        product.discountTiers.isNotEmpty) {
      // Sort discount tiers by quantity in descending order
      product.discountTiers
          .sort((a, b) => b['quantity'].compareTo(a['quantity']));

      // Iterate through discount tiers to find the applicable discount
      for (var tier in product.discountTiers) {
        int tierQuantity = tier['quantity'];
        double tierPercentage = tier['percentage'] / 100.0;

        // Check if the cart item quantity meets or exceeds the tier quantity
        if (cartItem.quantity >= tierQuantity) {
          // Calculate the discount for the entire cart item cost
          double itemDiscount = cartItem.cost * tierPercentage;

          // Store the discount for this item in the cartItem
          cartItem.discount = itemDiscount;

          // Return the calculated discount
          return itemDiscount;
        }
      }
    }

    // No discount applicable for this item
    return 0.0;
  }

// Function to calculate the total discount for all cart items
  double getDiscountTotal(CartModel cart, List<Product> products) {
    double totalDiscount = 0;

    for (var cartItem in cart.cartItems) {
      totalDiscount +=
          getDiscount(cartItem, getProductById(cartItem.productId, products));
    }

    return totalDiscount;
  }

  // Function to get a product by its ID
  Product? getProductById(String productId, List<Product> products) {
    return products.firstWhere((product) => product.id == productId,
        orElse: () => Product(
              name: '',
              stock: 0,
              id: productId,
              categoryId: '',
              cost: 0.0,
              imageUrl: '',
              discountTiers: [],
            ));
  }
}
