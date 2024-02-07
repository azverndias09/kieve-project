import 'package:SurbaMart/components/auth.dart';
import 'package:SurbaMart/user/order_history_page.dart';
import 'package:SurbaMart/user/product_list_page.dart';
import 'package:SurbaMart/user/profile_page.dart';
import 'package:SurbaMart/user/shopping_cart_page.dart';
import 'package:flutter/material.dart';


class UserHomePage extends StatelessWidget {
  const UserHomePage({Key? key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListPage()),
                );
              },
              child: const Text('Browse and Order Products'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                );
              },
              child: const Text('View Order History'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShoppingCartPage()),
                );
              },
              child: Text('Manage Shopping Cart'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => PaymentPage()),
            //     );
            //   },
            //   child: Text('Complete Payment'),
            // ),
          ],
        ),
      ),
    );
  }
}
