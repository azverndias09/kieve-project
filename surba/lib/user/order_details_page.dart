import 'package:flutter/material.dart';
import 'package:SurbaMart/models/orders.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late String _orderStatus;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order['status'] ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Rebuild OrderHistoryPage when navigating back
        Navigator.of(context).pop('Cancelled By User');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Number: ${widget.order['orderId'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Status: $_orderStatus',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: _orderStatus == 'Cancelled By User'
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Total Cost: ${widget.order['totalCost'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Items:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.order['items'].length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> item =
                            widget.order['items'][index];
                        String productName = item['name'] ?? 'N/A';
                        int quantity = item['quantity'] ?? 0;

                        return ListTile(
                          title: Text(
                            productName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('Quantity: $quantity'),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _orderStatus != 'Cancelled By User'
                        ? () => _cancelOrder(widget.order['orderId'])
                        : null,
                    child: Text('Cancel Order'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _cancelOrder(String orderId) {
    final orderService = OrderService();
    orderService.updateOrderStatus(orderId, 'Cancelled By User').then((_) {
      setState(() {
        _orderStatus = 'Cancelled By User';
      });
    }).catchError((error) {
      // Handle any errors
      print('Error cancelling order: $error');
    });
  }
}
