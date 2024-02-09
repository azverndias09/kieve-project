import 'package:SurbaMart/user/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderStatusProvider extends ChangeNotifier {
  Map<String, String> _orderStatusMap = {};

  Map<String, String> get orderStatusMap => _orderStatusMap;

  void updateOrderStatus(String orderId, String status) {
    _orderStatusMap[orderId] = status;
    notifyListeners();
  }
}

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: Consumer<OrderStatusProvider>(
        builder: (context, orderStatusProvider, _) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: getOrderHistory(),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<Map<String, dynamic>> orders = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> order = orders[index];
                    String orderId = order['orderId'];
                    String orderStatus =
                        orderStatusProvider.orderStatusMap[orderId] ??
                            order['status'];
                    return ListTile(
                      title: Text('Order #$orderId'),
                      subtitle: Text('Status: $orderStatus'),
                      onTap: () async {
                        final updatedStatus = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrderDetailsPage(order: order),
                          ),
                        );
                        if (updatedStatus != null) {
                          // Update the order status in the provider
                          orderStatusProvider.updateOrderStatus(
                              orderId, updatedStatus);
                        }
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userUid');

    if (userId == null || userId.isEmpty) {
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
