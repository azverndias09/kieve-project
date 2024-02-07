import 'package:SurbaMart/models/cartItem.dart';
import 'package:SurbaMart/models/product.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';


class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the app bar (e.g., clear search query)
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the app bar (e.g., back arrow)
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Show the search results based on the query
    // Use the query to filter the list of products
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while the user types in the search bar
    // You can use this method to display recent searches or related items
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    // Implement your logic to fetch and display search results
    // Use the query to filter the list of products
    // For example, you can use a StreamBuilder similar to the product list page
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
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

        // Extract the list of products from the snapshot
        List<Product> productList =
            snapshot.data!.docs.map((DocumentSnapshot doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return Product(
            name: data['Name'] ?? '',
            stock: data['Stock'] ?? 0,
            id: data['Id'] ?? '',
            categoryId: '',
            cost: 0,
            imageUrl: '',
            discountTiers: [],
          );
        }).toList();

        // Filter the list based on the search query
        List<Product> filteredList = productList
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Display the filtered list of products
        return ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(filteredList[index].name),
              subtitle: Text('Stock: ${filteredList[index].stock}'),
              // Add to cart button
              trailing: ElevatedButton(
                onPressed: () {
                  // Access the CartModel and add the product to the cart
                  Provider.of<CartModel>(context, listen: false)
                      .addToCart(filteredList[index]);
                },
                child: Text('Add to Cart'),
              ),
            );
          },
        );
      },
    );
  }
}
