import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final SupabaseClient? _supabaseClient;

  UserCubit({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client,
      super(const UserInitial());

  Future<void> loadUserInfo() async {
    emit(const UserLoading());
    try {
      final userInfo = await _supabaseClient!
          .from('user')
          .select()
          .limit(1)
          .maybeSingle();

      if (userInfo != null) {
        emit(
          UserLoaded(
            userData: userInfo,
            name: userInfo['name'] as String?,
            email: userInfo['email'] as String?,
            profileImageUrl: userInfo['profile_image_url'] as String?,
            createdAt: userInfo['created_at'] != null
                ? DateTime.parse(userInfo['created_at'] as String)
                : null,
          ),
        );
      } else {
        emit(const UserError('ไม่พบข้อมูลผู้ใช้'));
      }
    } catch (e) {
      emit(UserError('Lỗi tải dữ liệu: ${e.toString()}'));
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> updates) async {
    final currentState = state;
    if (currentState is UserLoaded) {
      try {
        final updatedData = await _supabaseClient!
            .from('user')
            .update(updates)
            .eq('id', currentState.userData['id'])
            .select()
            .single();

        final newState = currentState.copyWith(
          userData: updatedData,
          name: updates['name'] as String? ?? currentState.name,
          email: updates['email'] as String? ?? currentState.email,
          profileImageUrl:
              updates['profile_image_url'] as String? ??
              currentState.profileImageUrl,
        );

        emit(newState);
        emit(UserUpdated(updatedData));
      } catch (e) {
        emit(UserError('Lỗi cập nhật: ${e.toString()}'));
      }
    }
  }

  Future<void> refreshUserInfo() async {
    await loadUserInfo();
  }
}
