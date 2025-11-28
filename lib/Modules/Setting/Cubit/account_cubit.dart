import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/Setting/Cubit/account_state.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/user_service.dart';

class AccountCubit extends Cubit<AccountState> {
  final UserService _userService;
  final UserPreferences _userPreferences;

  AccountCubit({UserService? userService, UserPreferences? userPreferences})
    : _userService = userService ?? UserService(),
      _userPreferences = userPreferences ?? UserPreferences(),
      super(AccountInitial());

  /// Load user data
  Future<void> loadUser() async {
    emit(AccountLoading());

    try {
      final userId = await _userPreferences.getUserId();

      if (userId == null) {
        emit(const AccountError('User ID not found'));
        return;
      }

      final user = await _userService.getUserById(userId);

      if (user == null) {
        emit(const AccountError('User not found'));
        return;
      }

      emit(AccountLoaded(user: user));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (state is AccountLoaded) {
      final currentUser = (state as AccountLoaded).user;
      try {
        final user = await _userService.getUserById(currentUser.id);
        if (user != null) {
          emit(AccountLoaded(user: user));
        }
      } catch (e) {
        // Keep current state if refresh fails
        emit(AccountError(e.toString()));
      }
    } else {
      loadUser();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _userPreferences.removeUserId();
      emit(AccountLoggedOut());
    } catch (e) {
      emit(AccountError('Failed to logout: ${e.toString()}'));
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    if (state is! AccountLoaded) {
      emit(const AccountError('User not loaded'));
      return;
    }

    emit(AccountDeleting());

    try {
      final userId = (state as AccountLoaded).user.id;
      await _userService.deleteUser(userId);
      await _userPreferences.removeUserId();
      emit(AccountDeleted());
    } catch (e) {
      emit(AccountError('Failed to delete account: ${e.toString()}'));
    }
  }

  /// Reset state to initial
  void reset() {
    emit(AccountInitial());
  }
}
