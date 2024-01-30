// add_product_page.dart

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopper_app/admin/productManagementPage.dart';
import 'package:shopper_app/models/category.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String newProductId = '';
  String newProductName = '';
  int newStock = 0;
  double newCost = 0.0;
  String selectedCategoryId = '';
  List<Map<String, dynamic>> DiscountTiers = [];
  List<Category> categories = [];
  String imageUrl = '';
  ImagePicker imagePicker = ImagePicker();
  bool homeDeliveryEnabled = false;
  @override
  void initState() {
    super.initState();
    // Fetch categories when the page is initialized
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      List<Category> fetchedCategories =
          await CategoryService().fetchCategories();
      print(fetchedCategories.first.id);
      setState(() {
        categories = fetchedCategories;
        // Set a default category if needed
        selectedCategoryId = categories.isNotEmpty ? categories.first.id : '';
      });
    } catch (e) {
      // Handle the error
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch categories (you may want to pass these as parameters or use Provider)
    // List<Category> categories = [];
    String imageUrl = '';
    ImagePicker imagePicker = ImagePicker();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Product ID
              TextField(
                onChanged: (text) {
                  newProductId = text;
                },
                decoration: const InputDecoration(labelText: 'Product ID'),
              ),
              // Product Name
              TextField(
                onChanged: (text) {
                  newProductName = text;
                },
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              // Stock
              TextField(
                onChanged: (text) {
                  newStock = int.tryParse(text) ?? 0;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock'),
              ),
              // Cost
              TextField(
                onChanged: (text) {
                  newCost = double.tryParse(text) ?? 0.0;
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost'),
              ),
              // Category dropdown
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Category',
                      errorText: state.hasError ? state.errorText : null,
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategoryId,
                      items: categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategoryId = newValue ?? '';
                        });
                      },
                    ),
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Enable Home Delivery'),
                value:
                    homeDeliveryEnabled, // Use the actual variable to store the state
                onChanged: (bool value) {
                  setState(() {
                    homeDeliveryEnabled = value;
                  });
                },
              ),
              // Discount Tiers input
              Column(
                children: [
                  for (int i = 0; i < DiscountTiers.length; i++)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (text) {
                              int quantity = int.tryParse(text) ?? 0;
                              DiscountTiers[i]['quantity'] = quantity;
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
                            onChanged: (text) {
                              double percentage = double.tryParse(text) ?? 0.0;
                              DiscountTiers[i]['percentage'] = percentage;
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
                      // Add a new discount tier
                      _addNewDiscountTier();
                    },
                    child: const Text('Add More Discount Tiers'),
                  ),
                ],
              ),

              ElevatedButton(
                onPressed: () async {
                  // Handle adding product to Firestore
                  await _addProductToFirestore();
                },
                child: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addProductToFirestore() async {
    try {
      // Upload the image to Firebase Storage and get the download URL
      if (imageUrl.isEmpty) {
        await _uploadImage();
      }

      // Add the product to Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'Id': newProductId,
        'Name': newProductName,
        'Stock': newStock,
        'CategoryId': selectedCategoryId,
        'Cost': newCost,
        'Image': imageUrl,
        'DiscountTiers': DiscountTiers,
        'homeDeliveryEnabled': true, // Replace with the actual value
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductManagementPage()),
      );
    } catch (e) {
      // Handle errors, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    /* Upload to Firebase storage */
    Reference referenceRoot = firebase_storage.FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload =
        referenceDirImages.child('$uniqueFileName.jpg');

    try {
      // Store the file directly
      await referenceImageToUpload.putFile(File(file.path));
      // Success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      // Handle errors
      print('Error uploading image: $error');
    }
  }

  // Function to add a new discount tier
  void _addNewDiscountTier() {
    setState(() {
      // Create a new map for each discount tier
      DiscountTiers.add({'quantity': 0, 'percentage': 0.0});
    });
  }
}
