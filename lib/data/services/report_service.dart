import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final _client = Supabase.instance.client;

  Future<double> getTotalSpending(String userId, int month, int year) async {
    final response = await _client
        .from('spending')
        .select('amount')
        .eq('userid', userId)
        .gte('date', '$year-${month.toString().padLeft(2, '0')}-01')
        .lte('date', '$year-${month.toString().padLeft(2, '0')}-31');

    final list = (response as List).cast<Map<String, dynamic>>();
    // Sử dụng map và reduce thay cho fold, xử lý trường hợp danh sách rỗng
    if (list.isEmpty) {
      return 0.0;
    }
    return list
        .map((e) => (e['amount'] as num).toDouble())
        .reduce((value, element) => value + element);
  }

  Future<double> getTotalIncome(String userId, int month, int year) async {
    // Note: This query won't filter by income type without join
    // Consider using a different approach or RPC function
    final response = await _client
        .from('spending')
        .select('amount, category_id')
        .eq('userid', userId)
        .gte('date', '$year-${month.toString().padLeft(2, '0')}-01')
        .lte('date', '$year-${month.toString().padLeft(2, '0')}-31');

    // TODO: Need to fetch categories separately or use RPC
    final list = (response as List).cast<Map<String, dynamic>>();

    // Sử dụng map và reduce thay cho fold, xử lý trường hợp danh sách rỗng
    if (list.isEmpty) {
      return 0.0;
    }
    return list
        .map((e) => (e['amount'] as num).toDouble())
        .reduce((value, element) => value + element);
  }

  Future<double> getBudgetLimit(String userId, int month, int year) async {
    final response = await _client
        .from('budget')
        .select('amount')
        .eq('userid', userId)
        .eq('month', month)
        .eq('year', year);

    final list = (response as List).cast<Map<String, dynamic>>();
    // Sử dụng map và reduce thay cho fold, xử lý trường hợp danh sách rỗng
    if (list.isEmpty) {
      return 0.0;
    }
    return list
        .map((e) => (e['amount'] as num).toDouble())
        .reduce((value, element) => value + element);
  }

  Future<Map<String, double>> getSpendingByCategory(
    String userId,
    int month,
    int year,
  ) async {
    final response = await _client.rpc(
      'spending_by_category',
      params: {'user_id': userId, 'month': month, 'year': year},
    );

    // Cần tạo thủ tục `spending_by_category` trong Supabase nếu dùng đoạn này
    final list = (response as List).cast<Map<String, dynamic>>();
    return {
      for (var e in list)
        e['category_name'] as String: (e['total_amount'] as num).toDouble(),
    };
  }
}
