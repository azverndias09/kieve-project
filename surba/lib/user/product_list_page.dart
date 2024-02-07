// product_list_page.dart

import 'package:SurbaMart/models/cartItem.dart';
import 'package:SurbaMart/models/category.dart';
import 'package:SurbaMart/models/product.dart';
import 'package:SurbaMart/models/productSearch.dart';
import 'package:SurbaMart/user/order_history_page.dart';
import 'package:SurbaMart/user/shopping_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:SurbaMart/user/product_detail_page.dart'; // Import the ProductDetailPage

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
              print('Selected item: $selected');
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedCategory == null || selectedCategory!.id.isEmpty
                  ? products.snapshots()
                  : products.where('CategoryId', isEqualTo: selectedCategory!.id).snapshots(),
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

                List<Product> productList = snapshot.data!.docs.map((DocumentSnapshot doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  List<Map<String, dynamic>> discountTiers =
                  List<Map<String, dynamic>>.from(data['DiscountTiers'] ?? []);
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
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.60,
                    ),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      if (productList[index].stock == 0) {
                        return SizedBox.shrink();
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(product: productList[index]),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3.0,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: productList[index].imageUrl.isNotEmpty
                                      ? Image.network(
                                    productList[index].imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  productList[index].name,
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Stock: ${productList[index].stock}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '\₹${productList[index].cost.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
