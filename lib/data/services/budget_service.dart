import 'package:moneyboys/data/Models/budget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_preferences.dart';

class BudgetService {
  final _supabase = Supabase.instance.client;

  Future<List<Budget>> getBudgets() async {
    final userId = await UserPreferences().getUserId();

    final response = await _supabase
        .from('budget')
        .select('*')
        .eq('userid', userId!)
        .order('start_date');

    return (response as List).map((e) => Budget.fromMap(e)).toList();
  }

  Future<void> addBudget(BudgetInsert budget) async {
    await _supabase.from('budget').insert(budget.toMap());
  }

  Future<void> updateBudget(Budget budget) async {
    await _supabase.from('budget').update(budget.toMap()).eq('id', budget.id);
  }

  Future<void> deleteBudget(String id) async {
    await _supabase.from('budget').delete().eq('id', id);
  }
}
