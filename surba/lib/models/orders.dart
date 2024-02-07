import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class OrderService {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  String generateRandomOrderId() {
    const String _chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final Random _random = Random.secure();

    return List.generate(6, (index) => _chars[_random.nextInt(_chars.length)])
        .join();
  }

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      final querySnapshot = await orders.get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<void> createOrder({
    required String firstName,
    required String lastName,
    required String streetName,
    required String city,
    required String state,
    required String pincode,
    required String userEmail,
    required double totalCost,
    required String status,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    try {
      String orderId = generateRandomOrderId();

      await orders.add({
        'orderId': orderId,
        'firstName': firstName,
        'lastName': lastName,
        'streetName': streetName,
        'city': city,
        'state': state,
        'pincode': pincode,
        'userEmail': userEmail,
        'totalCost': totalCost,
        'status': status,
        'items': items,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
      });
      print(userEmail);
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Query for the document with the specified orderId field
      final querySnapshot =
          await orders.where('orderId', isEqualTo: orderId).get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Update the status of the first document (assuming there is only one match)
        final documentId = querySnapshot.docs.first.id;
        await orders.doc(documentId).update({
          'status': newStatus,
        });
        print("done");
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}
