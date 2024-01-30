// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shopper_app/models/cartItem.dart';
// import 'package:shopper_app/models/orders.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shopper_app/user/product_list_page.dart';

// class CheckoutFormPage extends StatefulWidget {
//   const CheckoutFormPage({Key? key}) : super(key: key);

//   @override
//   _CheckoutFormPageState createState() => _CheckoutFormPageState();
// }

// class _CheckoutFormPageState extends State<CheckoutFormPage> {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _streetNameController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _stateController = TextEditingController();
//   final TextEditingController _pincodeController = TextEditingController();
//   bool homeDeliveryEnabled = false;
//   Razorpay _razorpay = Razorpay();
//   String userEmail = '';
//   @override
//   void initState() {
//     super.initState();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _razorpay.clear();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               controller: _firstNameController,
//               decoration: const InputDecoration(labelText: 'First Name'),
//             ),
//             TextFormField(
//               controller: _lastNameController,
//               decoration: const InputDecoration(labelText: 'Last Name'),
//             ),
//             TextFormField(
//               controller: _streetNameController,
//               decoration: const InputDecoration(labelText: 'Street Name'),
//             ),
//             TextFormField(
//               controller: _cityController,
//               decoration: const InputDecoration(labelText: 'City'),
//             ),
//             TextFormField(
//               controller: _stateController,
//               decoration: const InputDecoration(labelText: 'State'),
//             ),
//             TextFormField(
//               controller: _pincodeController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(labelText: 'Pincode'),
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () {
//                 _confirmOrder();
//               },
//               child: const Text('Confirm Order'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _confirmOrder() async {
//     // Replace with your Razorpay API key
//     // Access the CartModel using Provider
//     CartModel cartModel = Provider.of<CartModel>(context, listen: false);
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Ensure that userId is not null or empty
//     String? userId = prefs.getString('userUid');
//     print(userId);

//     if (userId == null || userId.isEmpty) {
//       // Handle the case where userId is not available
//       print("User ID is null or empty. Unable to place the order.");
//       return;
//     }

//     try {
//       DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .get();

//       userEmail = userSnapshot.get('email') ?? '';
//       print(userEmail);

//       // Create an order document
//       // await FirebaseFirestore.instance.collection('orders').add({
//       //   'userEmail': userEmail,
//       //   'status': 'pending', // Set initial status
//       //   'items': orderItems,
//       //   // Add other order details (e.g., address, timestamp)
//       // });

//       // Get the total cost from the cart
//       double totalCost = cartModel.getTotalCost();
//       int totalCostInPaise = (totalCost * 100).round();
//       print(totalCostInPaise);

//       String apiKey = 'rzp_test_SiwsH4lPnRr2nn';
//       var options = {
//         'key': apiKey,
//         'amount': totalCostInPaise, // Replace with the actual amount in paise
//         'name': 'College Project',
//         'description': 'Payment for Order',
//         'prefill': {'contact': '1234567890', 'email': userEmail},
//         'external': {
//           'wallets': ['paytm'],
//         },
//       };
//       _razorpay.open(options);
//     } catch (e) {
//       print("Error during order confirmation: $e");
//       // Handle the error as needed
//     }
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     // Handle payment success
//     print('Payment Success: ${response.paymentId}');

//     // Access the entered values from the controllers
//     String firstName = _firstNameController.text;
//     String lastName = _lastNameController.text;
//     String streetName = _streetNameController.text;
//     String city = _cityController.text;
//     String state = _stateController.text;
//     String pincode = _pincodeController.text;

//     // Get user email from shared preferences (replace with your logic)

//     // Access the CartModel using Provider
//     CartModel cartModel = Provider.of<CartModel>(context, listen: false);

//     // Get the total cost from the cart
//     double totalCost = cartModel.getTotalCost();
//     List<Map<String, dynamic>> orderItems =
//         Provider.of<CartModel>(context, listen: false)
//             .cartItems
//             .map((item) => item.toMap())
//             .toList();
//     // Create the order in Firestore
//     await OrderService().createOrder(
//       firstName: firstName,
//       lastName: lastName,
//       streetName: streetName,
//       city: city,
//       state: state,
//       pincode: pincode,
//       userEmail: userEmail,
//       totalCost: totalCost,
//       status: 'Pending', // Set initial status
//       items: orderItems, paymentMethod: '',
//       paymentStatus: '', // Add items to the order
//     );

//     // Show toast message
//     Fluttertoast.showToast(
//       msg: 'Order confirmed!',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );

//     Provider.of<CartModel>(context, listen: false).clearCart();
//     // Navigate back to the product view page
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ProductListPage(),
//       ),
//     );
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     // Handle payment failure
//     //print('Payment Error: ${response.code.toString()} - ${response.message}');
//     Fluttertoast.showToast(
//       msg: 'Payment Error: ${response.code.toString()} - ${response.message}',
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: Colors.green,
//       textColor: Colors.white,
//     );
//     // You may want to show an error message to the user
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     // Handle external wallet
//     print('External Wallet: ${response.walletName}');
//   }

//   int calculateTotalCost() {
//     // Access the CartModel using Provider
//     CartModel cartModel = Provider.of<CartModel>(context, listen: false);

//     // Call the getTotalCost method to get the total cost
//     double totalCost = cartModel.getTotalCost();

//     // Convert the total cost to rupees (assuming it's in paise)
//     int totalCostInRupees = (totalCost / 100).round();

//     return totalCostInRupees;
//   }
// }
