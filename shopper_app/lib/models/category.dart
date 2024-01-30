import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

class CategoryService {
  final CollectionReference categories =
      FirebaseFirestore.instance.collection('categories');

  Future<List<Category>> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot = await categories.get();
      List<Category> categoryList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Category(
          id: doc.id,
          name: data['Name'] ?? '',
        );
      }).toList();
      return categoryList;
    } catch (e) {
      // Handle errors, e.g., log the error
      print('Error fetching categories: $e');
      return [];
    }
  }
}
