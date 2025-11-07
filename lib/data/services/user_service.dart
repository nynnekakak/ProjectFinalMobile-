import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moneyboys/data/Models/user.dart';

class UserService {
  final _supabase = Supabase.instance.client;
  final _table = 'user';

  Future<UserModel?> getUserByEmail(String email) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('email', email)
        .single();

    return UserModel.fromMap(response);
  }

  Future<UserModel?> getUserById(String userId) async {
    final response = await _supabase
        .from('user')
        .select()
        .eq('id', userId)
        .single();

    return UserModel.fromMap(response);
  }

  Future<void> createUser(UserModel user) async {
    await _supabase.from(_table).insert(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _supabase.from(_table).update(user.toMap()).eq('id', user.id);
  }

  Future<void> deleteUser(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }
}
