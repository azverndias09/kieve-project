import 'package:SurbaMart/models/cartItem.dart';
import 'package:SurbaMart/models/orders.dart';
import 'package:SurbaMart/user/product_list_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckoutFormPage extends StatefulWidget {
  final double totalCost;

  const CheckoutFormPage({Key? key, required this.totalCost}) : super(key: key);

  @override
  _CheckoutFormPageState createState() => _CheckoutFormPageState();
}

class _CheckoutFormPageState extends State<CheckoutFormPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  Razorpay _razorpay = Razorpay();
  String userEmail = '';
  String paymentMethod = 'onlinePayment'; // Default to online payment

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              controller: _streetNameController,
              decoration: const InputDecoration(labelText: 'Street Name'),
            ),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(labelText: 'State'),
            ),
            TextFormField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Pincode'),
            ),
            const SizedBox(height: 16.0),
            const Text('Select Payment Method:'),
            Row(
              children: [
                Radio(
                  value: 'onlinePayment',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value.toString();
                    });
                  },
                ),
                const Text('Online Payment'),
                const SizedBox(width: 16),
                Radio(
                  value: 'cashOnDelivery',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value.toString();
                    });
                  },
                ),
                const Text('Cash On Delivery'),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _confirmOrder();
              },
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder() async {
    CartModel cartModel = Provider.of<CartModel>(context, listen: false);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userUid');

    if (userId == null || userId.isEmpty) {
      print("User ID is null or empty. Unable to place the order.");
      return;
    }

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      userEmail = userSnapshot.get('email') ?? '';
      if (paymentMethod == 'onlinePayment') {
        _initiateRazorpay(widget.totalCost);
        return;
      }

      _createOrder(cartModel);
    } catch (e) {
      print("Error during order confirmation: $e");
    }
  }

  void _initiateRazorpay(double totalCost) {
    String apiKey = 'rzp_test_SiwsH4lPnRr2nn';

    var options = {
      'key': apiKey,
      'amount': (totalCost * 100).round(),
      'name': 'Surba',
      'description': 'Payment for Order',
      'prefill': {'email': userEmail},
      'external': {
        'wallets': ['paytm']
      },
    };

    _razorpay.open(options);
  }

  void _createOrder(CartModel cartModel) async {
    await OrderService().createOrder(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      streetName: _streetNameController.text,
      city: _cityController.text,
      state: _stateController.text,
      pincode: _pincodeController.text,
      userEmail: userEmail,
      //  totalCost: cartModel.getTotalCost(),
      totalCost: widget.totalCost,
      status: 'Pending',
      items: cartModel.cartItems.map((item) => item.toMap()).toList(),
      paymentMethod: paymentMethod, // Pass the correct value for paymentMethod
      paymentStatus: paymentMethod == 'onlinePayment'
          ? 'Done Online'
          : 'On Delivery/On Pickup', // Pass the correct value for paymentStatus
    );

    Fluttertoast.showToast(
      msg: 'Order confirmed!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    cartModel.clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListPage(),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Handle payment success
    print('Payment Success: ${response.paymentId}');

    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String streetName = _streetNameController.text;
    String city = _cityController.text;
    String state = _stateController.text;
    String pincode = _pincodeController.text;

    CartModel cartModel = Provider.of<CartModel>(context, listen: false);

    double totalCost = cartModel.getTotalCost();
    print('Total Cost: $totalCost');
    List<Map<String, dynamic>> orderItems =
        Provider.of<CartModel>(context, listen: false)
            .cartItems
            .map((item) => item.toMap())
            .toList();

    await OrderService().createOrder(
      firstName: firstName,
      lastName: lastName,
      streetName: streetName,
      city: city,
      state: state,
      pincode: pincode,
      userEmail: userEmail,
      totalCost: widget.totalCost,
      status: 'Pending',
      items: orderItems,
      paymentMethod: '',
      paymentStatus: '',
    );

    Fluttertoast.showToast(
      msg: 'Order confirmed!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Provider.of<CartModel>(context, listen: false).clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductListPage(),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print('Payment Error: ${response.code.toString()} - ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }
}
