import 'package:SurbaMart/models/orders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class OrderHandlingPage extends StatefulWidget {
  const OrderHandlingPage({Key? key}) : super(key: key);

  @override
  _OrderHandlingPageState createState() => _OrderHandlingPageState();
}

class _OrderHandlingPageState extends State<OrderHandlingPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    // Fetch orders from Firestore or your database
    _fetchOrders();
  }

  void _updateAndConfirmOrderStatus(String orderId, String newStatus) {
    final orderService = OrderService();

    // Update order status in Firebase
    orderService.updateOrderStatus(orderId, newStatus);

    // Update local state
    setState(() {
      // Find the order in the local state and update its status
      orders = orders.map((order) {
        if (order['orderId'] == orderId) {
          return {...order, 'status': newStatus};
        }
        return order;
      }).toList();
    });

    // Optionally, add more logic or UI updates as needed
  }

  Future<void> _fetchOrders() async {
    try {
      // Use the OrderService to fetch orders from Firestore
      final orderService = OrderService();
      final fetchedOrders = await orderService.fetchOrders();

      setState(() {
        orders = fetchedOrders;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Handling'),
      ),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          // Calculate order number using index + 1
          int orderNumber = index + 1;

          return ListTile(
            title: Text('Order #$orderNumber'),
            subtitle: Text('Status: ${order['status']}'),
            onTap: () => _showOrderDetails(order),
          );
        },
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    print(order);

    // Fetch user information based on userEmail
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: order['userEmail'])
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var userSnapshot = querySnapshot.docs.first;
        int orderNumber = orders.indexOf(order) + 1;
        List<String> deliveryStatuses = [
          'Pending',
          'Approved',
          'Out for Delivery',
          'Delivered',
          'Cancelled',
        ];
        String selectedStatus = order['status'];

        // Assuming the document ID is used as the order ID
        String orderId = order['orderId'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Order Details - #$orderNumber'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('Status', Text(order['status'])),
                    _buildDetailRow('User Email', Text(order['userEmail'])),
                    _buildDetailRow(
                      'User Phone',
                      Text(userSnapshot.get('phoneNumber') ?? 'N/A'),
                    ),
                    _buildDetailRow(
                      'Address',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${order['streetName']}, ${order['city']}, ${order['state']} ${order['pincode']}'),
                        ],
                      ),
                    ),
                    _buildDetailRow('Items', _buildItemList(order['items'])),
                    _buildDetailRow(
                        'Total Cost', Text('\₹${order['totalCost']}')),
                    _buildDetailRow(
                      'Change Status',
                      DropdownButton<String>(
                        value: selectedStatus,
                        items: deliveryStatuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != selectedStatus) {
                            setState(() {
                              selectedStatus = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                _buildActionButton('Update and Confirm', () {
                  _updateAndConfirmOrderStatus(orderId, selectedStatus);
                  Navigator.pop(context);
                }),
              ],
            );
          },
        );
      }
    });
  }

  Widget _buildDetailRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            WidgetSpan(child: value), // Pass the Widget directly
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(List<dynamic> items) {
    return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey),
          children: [
            _buildTableHeader('Name'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Cost'),
          ],
        ),
        for (var item in items)
          TableRow(
            children: [
              _buildTableCell(item['name']),
              _buildTableCell(item['quantity'].toString()),
              _buildTableCell('\₹${item['cost']}'),
            ],
          ),
        TableRow(
          decoration: BoxDecoration(color: Colors.grey),
          children: [
            _buildTableHeader('Total Cost'),
            _buildTableCell(''), // Empty cell for Quantity column
            _buildTableCell('\₹${_calculateTotalItemCost(items)}'),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(value),
    );
  }

  double _calculateTotalItemCost(List<dynamic> items) {
    return items.fold(0, (sum, item) => sum + item['cost']);
  }

  Widget _buildActionButton(String label, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(primary: Colors.blue),
      child: Text(label),
    );
  }
}
