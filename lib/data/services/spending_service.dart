import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moneyboys/data/Models/spending.dart';

class SpendingService {
  final _supabase = Supabase.instance.client;
  final _table = 'spending';

  Future<List<Spending>> getSpendings(String userId) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('userid', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Spending.fromMap(e)).toList();
  }

  Future<List<Spending>> getSpendingsInRange(
    DateTime start,
    DateTime end,
    String type,
  ) async {
    final userId = await UserPreferences().getUserId();

    final response = await _supabase
        .from('spending')
        .select('*, category!inner(type)')
        .eq('userid', userId!)
        .eq('category.type', type)
        .gte('date', start.toIso8601String())
        .lte('date', end.toIso8601String())
        .order('date', ascending: false);

    final data = response as List;

    return data.map((e) => Spending.fromJson(e)).toList();
  }

  Future<void> addSpending(Spending spending) async {
    await _supabase.from(_table).insert(spending.toMap());
  }

  Future<void> updateSpending(Spending spending) async {
    await _supabase.from(_table).update(spending.toMap()).eq('id', spending.id);
  }

  Future<void> deleteSpending(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
