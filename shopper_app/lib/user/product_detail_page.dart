import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopper_app/models/cartItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shopper_app/models/product.dart';
import 'package:shopper_app/user/shopping_cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int selectedQuantity = 1; // Default quantity
  TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print(widget.product.discountTiers);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.shopping_cart),
          //   onPressed: () {
          //     // Navigate to the shopping cart page
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ShoppingCartPage(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(widget.product.imageUrl)
                    : Placeholder(),
              ),
              SizedBox(height: 16.0),
              Text('Price: ₹${widget.product.cost.toStringAsFixed(2)}'),
              SizedBox(height: 16.0),
              Text('Stock: ${widget.product.stock}'),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity: $selectedQuantity'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (selectedQuantity > 1) {
                                  selectedQuantity--;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                // Check if the selected quantity is less than the available stock
                                if (selectedQuantity < widget.product.stock) {
                                  selectedQuantity++;
                                } else {
                                  // Optionally, show a message or disable the increment button
                                  // For simplicity, we're just showing a debug print here
                                  print(
                                      'Cannot choose more than available stock.');

                                  Fluttertoast.showToast(
                                    msg:
                                        "Cannot choose more than available stock.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Add to cart logic using Provider
                  final cart = context.read<CartModel>();
                  cart.addToCart(widget.product, quantity: selectedQuantity);
                },
                child: Text('Add to Cart'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the shopping cart page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShoppingCartPage(),
                    ),
                  );
                },
                child: Text('Go to Cart'),
              ),
              SizedBox(height: 8.0),
              _buildReviewsSection(),
              SizedBox(height: 8.0),
              _buildDiscountTable(), // Add this line to display the discount table
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  _showReviewDialog(context);
                },
                child: Text('Add Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountTable() {
    // Check if DiscountTiers exist and are not empty
    if (widget.product.discountTiers != null &&
        widget.product.discountTiers.isNotEmpty) {
      // Filter out rows with either quantity 0 or discount amount 0
      List<Map<String, dynamic>> filteredDiscountTiers = widget
          .product.discountTiers
          .where((tier) =>
              tier['quantity'] != null &&
              tier['quantity'] > 0 &&
              tier['percentage'] != null &&
              tier['percentage'] > 0.0)
          .toList();

      if (filteredDiscountTiers.isNotEmpty) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Discount Tiers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              DataTable(
                columns: [
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Discount Percentage')),
                ],
                rows: filteredDiscountTiers.map((tier) {
                  return DataRow(
                    cells: [
                      DataCell(Text(tier['quantity'].toString())),
                      DataCell(Text('${tier['percentage']}%')),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }
    }

    // Return an empty container if there are no discount tiers or they are all either quantity 0 or discount amount 0
    return Container();
  }

  Widget _buildReviewsSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reviews')
                .where('productId', isEqualTo: widget.product.id)
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
              List<Widget> reviewWidgets = snapshot.data!.docs.map((document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String reviewText = data['reviewText'] ??
                    ''; // Check for null and provide a default value

                return ListTile(
                  title: Text(reviewText),
                  subtitle: Text('By: ${data['userEmail'] ?? ''}'),
                );
              }).toList();

              return SingleChildScrollView(
                child: Column(
                  children: reviewWidgets,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a Review'),
          content: TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Enter your review'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submitReview(context);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _submitReview(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userUid');

    if (userId == null || userId.isEmpty) {
      print("User ID is null or empty. Unable to submit review.");
      return;
    }

    String reviewText = reviewController.text.trim();
    if (reviewText.isNotEmpty) {
      // Fetch user email from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      String? userEmail = userSnapshot.get('email');

      if (userEmail == null || userEmail.isEmpty) {
        print("User email is null or empty. Unable to submit review.");
        return;
      }

      // Save the review to Firestore
      await FirebaseFirestore.instance.collection('reviews').add({
        'productId': widget.product.id,
        'userId': userId,
        'userEmail': userEmail,
        'reviewText': reviewText,
      });

      // Close the review dialog
      Navigator.pop(context);

      // Optionally, you can show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted successfully!'),
        ),
      );
    }
  }
}
