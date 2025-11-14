import 'package:moneyboys/data/Models/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryService {
  final _supabase = Supabase.instance.client;
  final _table = 'category';

  Future<List<Category>> getCategories(String userId, String type) async {
    final response = await _supabase
        .from(_table)
        .select()
        .or('userid.eq.$userId,is_shared.eq.true')
        .eq('type', type)
        .order('created_at');

    return (response as List).map((e) => Category.fromMap(e)).toList();
  }

  Future<List<Category>> getAllCategories(String userId) async {
    final response = await _supabase.from(_table).select().order('created_at');
    return (response as List)
        .map((e) => Category.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<Category?> getCategoryById(String id) async {
    final response = await _supabase
        .from('category')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response != null) {
      return Category.fromMap(response);
    }
    return null;
  }

  Future<void> addCategory(Category category) async {
    await _supabase.from(_table).insert(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _supabase.from(_table).update(category.toMap()).eq('id', category.id);
  }

  Future<void> deleteCategory(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
