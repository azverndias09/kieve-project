import 'package:flutter/material.dart';
import 'package:shopper_app/admin/orderManagement.dart';
import 'package:shopper_app/components/auth.dart';
import 'package:shopper_app/admin/productManagementPage.dart'; // Import your product management page

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Admin Home Page'),
            const SizedBox(height: 20.0),
            // Add a button to navigate to ProductManagementPage
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductManagementPage()),
                );
              },
              child: Text('Product Management'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHandlingPage()),
                );
              },
              child: Text('Order Management'),
            ),
          ],
        ),
      ),
    );
  }
}
