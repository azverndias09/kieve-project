// category_management.dart

import 'package:SurbaMart/models/category.dart';
import 'package:flutter/material.dart';


class CategoryManagementPage extends StatefulWidget {
  @override
  _CategoryManagementPageState createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final CategoryService categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Management'),
      ),
      body: FutureBuilder<List<Category>>(
        future: categoryService.fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No categories available.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Category category = snapshot.data![index];
                return ListTile(
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editCategory(context, category);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteCategory(context, category.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCategory(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addCategory(BuildContext context) async {
    try {
      String? newCategoryName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String value = '';
          return AlertDialog(
            title: const Text('Enter New Category Name'),
            content: TextField(
              onChanged: (text) => value = text,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, value);

                  // Add the new category to Firestore
                  await categoryService.addCategory(value);

                  // Trigger a rebuild of the widget tree
                  setState(() {});
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );

      if (newCategoryName == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category added successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editCategory(BuildContext context, Category category) async {
    try {
      String? updatedCategoryName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String value = category.name;
          return AlertDialog(
            title: const Text('Edit Category Name'),
            content: TextField(
              onChanged: (text) => value = text,
              controller: TextEditingController(text: category.name),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, value);

                  // Edit the category in Firestore
                  await categoryService.editCategory(category.id, value);

                  // Trigger a rebuild of the widget tree
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (updatedCategoryName == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category updated successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCategory(BuildContext context, String categoryId) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this category?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);

                  // Delete the category from Firestore
                  await categoryService.deleteCategory(categoryId);

                  // Trigger a rebuild of the widget tree
                  setState(() {});
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete != true) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
