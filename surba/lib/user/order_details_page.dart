import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Order Number: ${order['orderId'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Status: ${order['status']}',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.blue, // You can choose your color
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Total Cost: ${order['totalCost']}',
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
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: order['items'].length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> item = order['items'][index];
                    String productName =
                        item['name'] ?? 'Product Name Not Available';

                    return ListTile(
                      title: Text(
                        productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('Quantity: ${item['quantity']}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
