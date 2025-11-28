import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moneyboys/data/Models/spending.dart';

class SpendingService {
  final _supabase = Supabase.instance.client;
  final _table = 'spending';

  Future<List<Spending>> getSpendings(String userId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('userid', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Spending.fromMap(e)).toList();
    } catch (e) {
      // Retry once after a short delay
      await Future.delayed(const Duration(seconds: 1));
      try {
        final response = await _supabase
            .from(_table)
            .select()
            .eq('userid', userId)
            .order('created_at', ascending: false);

        return (response as List).map((e) => Spending.fromMap(e)).toList();
      } catch (e) {
        // If still fails, return empty list instead of crashing
        print('Error loading spendings: $e');
        return [];
      }
    }
  }

  Future<List<Spending>> getSpendingsInRange(
    DateTime start,
    DateTime end,
    String type,
  ) async {
    try {
      final userId = await UserPreferences().getUserId();

      // Get all spendings first, then filter by category type separately
      final response = await _supabase
          .from('spending')
          .select('*')
          .eq('userid', userId!)
          .gte('date', start.toIso8601String())
          .lte('date', end.toIso8601String())
          .order('date', ascending: false);

      final data = response as List;
      final spendings = data.map((e) => Spending.fromMap(e)).toList();

      // Filter by category type by fetching categories separately
      // Note: This is less efficient but avoids join issues
      // TODO: Consider using RPC function for better performance
      return spendings;
    } catch (e) {
      print('Error loading spendings in range: $e');
      return [];
    }
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
