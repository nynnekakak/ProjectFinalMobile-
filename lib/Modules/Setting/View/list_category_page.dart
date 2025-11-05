import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moneyboys/app/route.dart';
import 'package:moneyboys/data/Models/category.dart';

import '../../../data/services/category_service.dart';
import '../../../data/services/user_preferences.dart';
import 'add_category_page.dart';

class ListCategoryPage extends StatefulWidget {
  const ListCategoryPage({super.key});

  @override
  State<ListCategoryPage> createState() => _ListCategoryPageState();
}

class _ListCategoryPageState extends State<ListCategoryPage> {
  List<Category> _categories = [];
  final primaryBlue = const Color(0xFF0040FF);
  final lightBlue = Colors.grey[100];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final userId = await UserPreferences().getUserId();
    final result = await CategoryService().getAllCategories(userId!);
    setState(() {
      _categories = result;
    });
  }

  Future<void> _deleteCategory(String id) async {
    Category? cate = await CategoryService().getCategoryById(id);
    if (cate!.isShared == false) {
      await CategoryService().deleteCategory(id);
      await _loadCategories();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Danh mục này không thể xóa!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _goToAddCategory() async {
    final commonState = context.findAncestorStateOfType<RoutesState>();
    commonState?.setState(() {
      commonState.previousSubPage = null;
      commonState.subPage = const AddCategoryPage();
    });

    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final commonState = context.findAncestorStateOfType<RoutesState>();
            if (commonState != null) {
              commonState.setState(() {
                if (commonState.previousSubPage != null) {
                  commonState.subPage = commonState.previousSubPage;
                  commonState.previousSubPage = null;
                } else {
                  commonState.subPage = null;
                }
              });
            }
          },
        ),
        title: const Text(
          'Danh sách danh mục',
          style: TextStyle(color: Color(0xFF111111)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: primaryBlue),
            onPressed: _goToAddCategory,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: _categories.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có danh mục nào',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.25, // Thu nhỏ kích thước khi kéo
                                children: [
                                  SlidableAction(
                                    icon: Icons.delete,
                                    backgroundColor: Colors.redAccent,
                                    spacing: 4.0,
                                    borderRadius: BorderRadius.circular(12),
                                    flex: 1,
                                    label: 'Xóa',
                                    onPressed: (ctx) =>
                                        _deleteCategory(category.id),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      category.icon ?? '📁',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  title: Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    category.type == 'expense'
                                        ? 'Chi tiêu'
                                        : 'Thu nhập',
                                    style: TextStyle(
                                      color: category.type == 'expense'
                                          ? Colors.redAccent
                                          : Colors.green,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Đã bỏ FloatingActionButton ở đây
    );
  }
}
