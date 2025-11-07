import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Hàm để thêm một người dùng mới vào bảng user
  Future<void> addUser(String username, String email) async {
    final response = await _supabase.from('user').insert([
      {'username': username, 'email': email}
    ]);

    if (response.error != null) {
      throw Exception('Failed to add user: ${response.error!.message}');
    }
  }

  // Hàm để lấy thông tin người dùng theo email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response =
        await _supabase.from('user').select('*').eq('email', email).single();

    return response;
  }

  // Hàm để thêm một category mới
  Future<void> addCategory(String name, String type, int userId) async {
    final response = await _supabase.from('category').insert([
      {'name': name, 'type': type, 'user_id': userId}
    ]);

    if (response.error != null) {
      throw Exception('Failed to add category: ${response.error!.message}');
    }
  }

  // Hàm để lấy các category của người dùng theo loại (income/expense)
  Future<List<Map<String, dynamic>>> getCategoriesByType(
      String userId, String type) async {
    try {
      final query = _supabase
          .from('category')
          .select()
          .eq('type', type)
          .or('is_shared.eq.true,userid.eq.$userId');
      //.or('is_share.eq.true${userId.isNotEmpty ? ',userid.eq.$userId' : ''}');

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Hàm để thêm một khoản thu/chi mới vào bảng spending
  Future<void> addSpending(String userId, String categoryId, double amount,
      String date, String note) async {
    await _supabase.from('spending').insert({
      'userid': userId,
      'amount': amount,
      'note': note,
      'category_id': categoryId,
      'date': date,
    });
print('Inserting spending: category_id=$categoryId');

  }
  Future<void> deleteSpending(String id) async {
  _supabase.from('spending').delete().eq('id', id);
}
Future<void> updateSpending({
  required String id,
  required String categoryId,
  required double amount,
  required String date,
  required String note,
}) async {
  final response = await _supabase.from('spending').update({
    'category_id': categoryId,
    'amount': amount,
    'date': date,
    'note': note,
  }).eq('id', id);

  if (response == null || response.error != null) {
    throw Exception('Cập nhật thất bại: ${response?.error?.message}');
  }
}




  // Hàm để lấy tất cả các khoản thu/chi của người dùng
  Future<List<Map<String, dynamic>>> getSpendings(int userId) async {
    final response =
        await _supabase.from('spending').select('*').eq('userid', userId);

    return List<Map<String, dynamic>>.from(response);
  }

  // Hàm lấy danh sách chi tiêu theo userId
Future<List<Map<String, dynamic>>> getSpendingList(String userId) async {
  final response = await _supabase
      .from('spending')
      .select('*, category(*)')
      .eq('userid', userId)
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}

}
