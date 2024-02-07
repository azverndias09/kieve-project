// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:SurbaMart/admin/add_product.dart';
import 'package:SurbaMart/admin/categoryManagement.dart';
import 'package:SurbaMart/models/category.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


import 'package:firebase_storage/firebase_storage.dart';

class ProductManagementPage extends StatelessWidget {
  ProductManagementPage({Key? key}) : super(key: key);

  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  Future<void> _addCategory(BuildContext context) async {
    try {
      String? newCategoryName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String value = '';
          return AlertDialog(
            title: const Text('Enter New Category Name'),
            content: TextField(
              onChanged: (text) => value = text,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, value);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );

      if (newCategoryName == null) return;

      await categories.add({
        'Name': newCategoryName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category added successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> _addProduct(BuildContext context) async {
  //   try {
  //     // Fetch categories
  //     List<Category> categories = await CategoryService().fetchCategories();

  //     // Initialize variables for new product data
  //     String newProductId = '';
  //     String newProductName = '';
  //     int newStock = 0;
  //     double newCost = 0.0;
  //     String selectedCategoryId =
  //         categories.isNotEmpty ? categories.first.id : '';
  //     String imageUrl = '';
  //     List<Map<String, dynamic>> DiscountTiers = [];

  //     // Show a dialog to get the new product details from the admin
  //     Map<String, dynamic>? newProductData =
  //         await showDialog<Map<String, dynamic>>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //             return AlertDialog(
  //               title: const Text('Enter New Product Details'),
  //               content: Column(
  //                 children: [
  //                   // Product ID
  //                   TextField(
  //                     onChanged: (text) {
  //                       newProductId = text;
  //                     },
  //                     decoration:
  //                         const InputDecoration(labelText: 'Product ID'),
  //                   ),
  //                   // Product Name
  //                   TextField(
  //                     onChanged: (text) {
  //                       newProductName = text;
  //                     },
  //                     decoration:
  //                         const InputDecoration(labelText: 'Product Name'),
  //                   ),
  //                   // Stock
  //                   TextField(
  //                     onChanged: (text) {
  //                       newStock = int.tryParse(text) ?? 0;
  //                     },
  //                     keyboardType: TextInputType.number,
  //                     decoration: const InputDecoration(labelText: 'Stock'),
  //                   ),
  //                   // Cost
  //                   TextField(
  //                     onChanged: (text) {
  //                       newCost = double.tryParse(text) ?? 0.0;
  //                     },
  //                     keyboardType: TextInputType.number,
  //                     decoration: const InputDecoration(labelText: 'Cost'),
  //                   ),
  //                   // Category dropdown
  //                   DropdownButton<String>(
  //                     value: selectedCategoryId,
  //                     items: categories.map((Category category) {
  //                       return DropdownMenuItem<String>(
  //                         value: category.id,
  //                         child: Text(category.name),
  //                       );
  //                     }).toList(),
  //                     onChanged: (String? newValue) {
  //                       if (newValue != null) {
  //                         setState(() {
  //                           selectedCategoryId = newValue;
  //                         });
  //                       }
  //                     },
  //                   ),
  //                   // Discount Tiers input
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: TextField(
  //                           onChanged: (text) {
  //                             // Parse the quantity from the input
  //                             int quantity = int.tryParse(text) ?? 0;
  //                             DiscountTiers.add({'quantity': quantity});
  //                           },
  //                           keyboardType: TextInputType.number,
  //                           decoration: const InputDecoration(
  //                             labelText: 'Quantity',
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 16.0),
  //                       Expanded(
  //                         child: TextField(
  //                           onChanged: (text) {
  //                             // Parse the discount percentage from the input
  //                             double percentage = double.tryParse(text) ?? 0.0;
  //                             // Find the last added quantity and update its discount
  //                             DiscountTiers.last['percentage'] = percentage;
  //                           },
  //                           keyboardType: TextInputType.number,
  //                           decoration: const InputDecoration(
  //                             labelText: 'Discount Percentage',
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   // Image upload button
  //                   IconButton(
  //                     onPressed: () async {
  //                       // ... (same as before)
  //                     },
  //                     icon: const Icon(Icons.camera_alt),
  //                   ),
  //                 ],
  //               ),
  //               actions: [
  //                 // Cancel button
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: const Text('Cancel'),
  //                 ),
  //                 // Add button
  //                 TextButton(
  //                   onPressed: () {
  //                     print(imageUrl);
  //                     Navigator.pop(context, {
  //                       'ID': newProductId,
  //                       'Name': newProductName,
  //                       'Stock': newStock,
  //                       'CategoryId': selectedCategoryId,
  //                       'Cost': newCost,
  //                       'Image': imageUrl,
  //                       'DiscountTiers': DiscountTiers,
  //                     });
  //                   },
  //                   child: const Text('Add'),
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       },
  //     );

  //     // If the admin canceled, do nothing
  //     if (newProductData == null) return;

  //     // Add the new product to Firestore with the custom ID
  //     await products.add({
  //       'Id': newProductData['ID'],
  //       'Name': newProductData['Name'],
  //       'Stock': newProductData['Stock'],
  //       'CategoryId': newProductData['CategoryId'],
  //       'Cost': newProductData['Cost'],
  //       'Image': newProductData['Image'],
  //       'DiscountTiers': newProductData['DiscountTiers'],
  //     });

  //     // Show a success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Product added successfully'),
  //       ),
  //     );
  //   } catch (e) {
  //     // Handle errors, e.g., show an error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error adding product: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _editProduct(BuildContext context, String productId) async {
  //   try {
  //     DocumentSnapshot productSnapshot = await products.doc(productId).get();
  //     Map<String, dynamic> productData =
  //         productSnapshot.data() as Map<String, dynamic>;

  //     List<Category> categories = await CategoryService().fetchCategories();

  //     Map<String, dynamic>? updatedProductData =
  //         await showDialog<Map<String, dynamic>>(
  //       context: context,
  //       builder: (BuildContext context) {
  //         String updatedProductName = productData['Name'] ?? '';
  //         int updatedStock = productData['Stock'] ?? 0;
  //         double updatedCost = productData['Cost'] ?? 0.0; // Add this line
  //         String selectedCategoryId = productData['CategoryId'] ?? '';

  //         return AlertDialog(
  //           title: const Text('Enter Updated Product Details'),
  //           content: Column(
  //             children: [
  //               TextField(
  //                 controller: TextEditingController(text: updatedProductName),
  //                 onChanged: (text) {
  //                   updatedProductName = text;
  //                 },
  //                 decoration: const InputDecoration(labelText: 'Product Name'),
  //               ),
  //               TextField(
  //                 controller:
  //                     TextEditingController(text: updatedStock.toString()),
  //                 onChanged: (text) {
  //                   updatedStock = int.tryParse(text) ?? 0;
  //                 },
  //                 keyboardType: TextInputType.number,
  //                 decoration: const InputDecoration(labelText: 'Stock'),
  //               ),
  //               TextField(
  //                 controller: TextEditingController(
  //                     text: updatedCost.toString()), // Add this line
  //                 onChanged: (text) {
  //                   updatedCost = double.tryParse(text) ?? 0.0; // Add this line
  //                 },
  //                 keyboardType: TextInputType.number,
  //                 decoration:
  //                     const InputDecoration(labelText: 'Cost'), // Add this line
  //               ),
  //               DropdownButton<String>(
  //                 value: selectedCategoryId,
  //                 items: categories.map((Category category) {
  //                   return DropdownMenuItem<String>(
  //                     value: category.id,
  //                     child: Text(category.name),
  //                   );
  //                 }).toList(),
  //                 onChanged: (String? newValue) {
  //                   if (newValue != null) {
  //                     selectedCategoryId = newValue;
  //                   }
  //                 },
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: const Text('Cancel'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context, {
  //                   'Name': updatedProductName,
  //                   'Stock': updatedStock,
  //                   'CategoryId': selectedCategoryId,
  //                   'Cost': updatedCost, // Add this line
  //                 });
  //               },
  //               child: const Text('Update'),
  //             ),
  //           ],
  //         );
  //       },
  //     );

  //     if (updatedProductData == null) return;

  //     await products.doc(productId).update({
  //       'Name': updatedProductData['Name'],
  //       'Stock': updatedProductData['Stock'],
  //       'Cost': updatedProductData['Cost'], // Add this line
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Product updated successfully'),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error updating product: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _editProduct(BuildContext context, String productId) async {
    try {
      DocumentSnapshot productSnapshot = await products.doc(productId).get();
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      List<Category> categories = await CategoryService().fetchCategories();

      Map<String, dynamic>? updatedProductData =
          await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (BuildContext context) {
          String updatedProductName = productData['Name'] ?? '';
          int updatedStock = productData['Stock'] ?? 0;
          double updatedCost = productData['Cost'] ?? 0.0;
          String selectedCategoryId = productData['CategoryId'] ?? '';
          bool homeDeliveryEnabled =
              productData['homeDeliveryEnabled'] ?? false;
          List<Map<String, dynamic>> updatedDiscountTiers =
              List.from(productData['DiscountTiers'] ?? []);

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Enter Updated Product Details'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller:
                            TextEditingController(text: updatedProductName),
                        onChanged: (text) {
                          updatedProductName = text;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Product Name'),
                      ),
                      TextField(
                        controller: TextEditingController(
                            text: updatedStock.toString()),
                        onChanged: (text) {
                          updatedStock = int.tryParse(text) ?? 0;
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock'),
                      ),
                      TextField(
                        controller:
                            TextEditingController(text: updatedCost.toString()),
                        onChanged: (text) {
                          updatedCost = double.tryParse(text) ?? 0.0;
                        },
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Cost'),
                      ),
                      // Discount Tiers input
                      Column(
                        children: [
                          for (int i = 0; i < updatedDiscountTiers.length; i++)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: updatedDiscountTiers[i]['quantity']
                                              .toString() ??
                                          '',
                                    ),
                                    onChanged: (text) {
                                      int quantity = int.tryParse(text) ?? 0;
                                      updatedDiscountTiers[i]['quantity'] =
                                          quantity;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Quantity',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                      text: updatedDiscountTiers[i]
                                                  ['percentage']
                                              .toString() ??
                                          '',
                                    ),
                                    onChanged: (text) {
                                      double percentage =
                                          double.tryParse(text) ?? 0.0;
                                      updatedDiscountTiers[i]['percentage'] =
                                          percentage;
                                    },
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Discount Percentage',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Create a new map for each discount tier
                                updatedDiscountTiers.add(
                                  {'quantity': 0, 'percentage': 0.0},
                                );
                              });
                            },
                            child: const Text('Add More Discount Tiers'),
                          ),
                        ],
                      ),
                      // Toggle for Home Delivery
                      SwitchListTile(
                        title: const Text('Enable Home Delivery'),
                        value: homeDeliveryEnabled,
                        onChanged: (bool value) {
                          setState(() {
                            homeDeliveryEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'Name': updatedProductName,
                        'Stock': updatedStock,
                        'CategoryId': selectedCategoryId,
                        'Cost': updatedCost,
                        'DiscountTiers': updatedDiscountTiers,
                        'homeDeliveryEnabled': homeDeliveryEnabled,
                      });
                    },
                    child: const Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (updatedProductData == null) return;

      await products.doc(productId).update({
        'Name': updatedProductData['Name'],
        'Stock': updatedProductData['Stock'],
        'Cost': updatedProductData['Cost'],
        'DiscountTiers': updatedProductData['DiscountTiers'],
        'homeDeliveryEnabled': updatedProductData['homeDeliveryEnabled'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product updated successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) return;

      await products.doc(productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: categories.snapshots(),
        builder: (context, categoriesSnapshot) {
          if (categoriesSnapshot.hasError) {
            return Center(
              child: Text('Error: ${categoriesSnapshot.error}'),
            );
          }

          if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: categoriesSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot categoryDoc =
                  categoriesSnapshot.data!.docs[index];
              String categoryId = categoryDoc.id;
              String categoryName = categoryDoc['Name'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: products
                        .where('CategoryId', isEqualTo: categoryId)
                        .snapshots(),
                    builder: (context, productsSnapshot) {
                      if (productsSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${productsSnapshot.error}'),
                        );
                      }

                      if (productsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Column(
                        children: productsSnapshot.data!.docs.map((productDoc) {
                          String productId = productDoc.id;
                          String productName = productDoc['Name'] ?? '';
                          int productStock = productDoc['Stock'] ?? 0;
                          dynamic productCost = productDoc['Cost'] ?? 0.0;

                          return ListTile(
                            title: Text(productName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Stock: $productStock'),
                                Text('Cost: $productCost'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _editProduct(context, productId);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteProduct(context, productId);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductPage(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryManagementPage(),
                ),
              );
            },
            child: const Icon(Icons.category),
          ),
        ],
      ),
    );
  }
}

class ProductDiscountTier {
  final int quantityThreshold;
  final double discountPercentage;

  ProductDiscountTier({
    required this.quantityThreshold,
    required this.discountPercentage,
  });
}
