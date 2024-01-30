import 'package:cloud_firestore/cloud_firestore.dart';

class BulkDiscount {
  final String productId;
  final int quantityThreshold;
  final double discountPercentage;

  BulkDiscount({
    required this.productId,
    required this.quantityThreshold,
    required this.discountPercentage,
  });

  void setBulkDiscount(BulkDiscount bulkDiscount) {
    FirebaseFirestore.instance.collection('bulkDiscounts').add({
      'productId': bulkDiscount.productId,
      'quantityThreshold': bulkDiscount.quantityThreshold,
      'discountPercentage': bulkDiscount.discountPercentage,
    });
  }
}
