class Product {
  final String name;
  final int stock;
  final String id;
  final String categoryId;
  final double cost;
  final String imageUrl;
  final List<Map<String, dynamic>> discountTiers; // Add this field

  Product({
    required this.name,
    required this.stock,
    required this.id,
    required this.categoryId,
    required this.cost,
    required this.imageUrl,
    required this.discountTiers, // Initialize this field in the constructor
  });
}
