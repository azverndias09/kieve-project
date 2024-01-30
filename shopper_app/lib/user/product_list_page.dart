// product_list_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shopper_app/models/category.dart';
import 'package:shopper_app/models/product.dart';
import 'package:shopper_app/models/cartItem.dart';
import 'package:shopper_app/models/productSearch.dart';
import 'package:shopper_app/user/order_history_page.dart';
import 'package:shopper_app/user/shopping_cart_page.dart';
import 'package:shopper_app/user/product_detail_page.dart'; // Import the ProductDetailPage

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late CollectionReference products;
  late List<Category> categoryList = [];
  late Category? selectedCategory =
      null; // Change from null to initially select "All"

  @override
  void initState() {
    super.initState();
    // Initialize the reference to the "products" collection
    products = FirebaseFirestore.instance.collection('products');
    // Initialize categories list
    categoryList = [];
    // Call a method to fetch categories from Firestore
    _fetchCategories();
  }

  // Method to fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      CategoryService categoryService = CategoryService();
      List<Category> fetchedCategories =
          await categoryService.fetchCategories();

      // Insert an "All" category option at the beginning of the list
      fetchedCategories.insert(0, Category(id: '', name: 'All'));

      // Update the state to rebuild the UI
      if (mounted) {
        setState(() {
          categoryList = fetchedCategories;
          selectedCategory =
              fetchedCategories[0]; // Set the initial selection to "All"
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        actions: [
          Consumer<CartModel>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingCartPage(),
                        ),
                      );
                    },
                  ),
                  if (cart.cartItems.isNotEmpty)
                    Positioned(
                      top: 8.0,
                      right: 8.0,
                      child: CircleAvatar(
                        radius: 10.0,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        child: Text(
                          cart.cartItems.length.toString(),
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final selected = await showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
              // Handle the selected item if needed
              print('Selected item: $selected');
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Navigate to the order history page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add a dropdown to select categories
          DropdownButton<Category>(
            value: selectedCategory,
            hint: const Text('Select Category'),
            items: categoryList.map((Category category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (Category? newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: selectedCategory == null || selectedCategory!.id.isEmpty
                ? products
                    .snapshots() // Fetch all products when "All" is selected
                : products
                    .where('CategoryId', isEqualTo: selectedCategory!.id)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              print('Number of Documents: ${snapshot.data!.docs.length}');

              List<Product> productList =
                  snapshot.data!.docs.map((DocumentSnapshot doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                List<Map<String, dynamic>> discountTiers =
                    List<Map<String, dynamic>>.from(
                        data['DiscountTiers'] ?? []);
                return Product(
                  name: data['Name'] ?? '',
                  stock: data['Stock'] ?? 0,
                  id: data['Id'] ?? '',
                  categoryId: data['CategoryId'] ?? '',
                  cost: (data['Cost'] ?? 0).toDouble(),
                  imageUrl: data['Image'] ?? '',
                  discountTiers: discountTiers,
                );
              }).toList();

              return Expanded(
                child: ListView.builder(
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    // Skip items with zero stock
                    if (productList[index].stock == 0) {
                      return SizedBox.shrink();
                    }

                    int selectedQuantity = 1; // Default quantity

                    return ListTile(
                      title: Text(productList[index].name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stock: ${productList[index].stock}'),
                          Text(
                              '\₹${productList[index].cost.toStringAsFixed(2)}'),
                        ],
                      ),
                      leading: Container(
                        height: 80,
                        width: 80,
                        child: productList[index].imageUrl.isNotEmpty
                            ? Image.network(productList[index].imageUrl)
                            : Container(),
                      ),
                      onTap: () => {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: productList[index]),
                          ),
                        )
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<CartModel>(context, listen: false)
                                  .addToCart(productList[index], quantity: 1);
                            },
                            child: const Text('Add to Cart'),
                          ),
                          const SizedBox(width: 8.0),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
