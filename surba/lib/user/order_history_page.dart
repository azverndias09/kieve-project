import 'package:SurbaMart/user/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: FutureBuilder(
        future: getOrderHistory(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> orders = snapshot.data ?? [];
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> order = orders[index];
                return ListTile(
                  title: Text('Order #${order['orderId']}'),
                  subtitle: Text('Status: ${order['status']}'),
                  onTap: () {
                    print(order);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ensure that userId is not null or empty
    String? userId = prefs.getString('userUid');

    if (userId == null || userId.isEmpty) {
      // Handle the case where userId is not available
      print("User ID is null or empty. Unable to get order history.");
      return [];
    }

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      String userEmail = userSnapshot.get('email') ?? '';

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where('userEmail', isEqualTo: userEmail)
              .get();

      List<Map<String, dynamic>> orders = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              doc.data() as Map<String, dynamic>)
          .toList();

      return orders;
    } catch (e) {
      print('Error getting order history: $e');
      return [];
    }
  }
}
