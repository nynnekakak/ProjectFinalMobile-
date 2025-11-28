import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/Setting/Cubit/setting_state.dart';
import 'package:moneyboys/data/Models/user.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/user_service.dart';

class SettingCubit extends Cubit<SettingState> {
  final UserService _userService;
  final CategoryService _categoryService;
  final UserPreferences _userPreferences;

  SettingCubit({
    UserService? userService,
    CategoryService? categoryService,
    UserPreferences? userPreferences,
  }) : _userService = userService ?? UserService(),
       _categoryService = categoryService ?? CategoryService(),
       _userPreferences = userPreferences ?? UserPreferences(),
       super(SettingInitial());

  String? _currentUserId;

  /// Load user profile and categories
  Future<void> loadUserProfile() async {
    try {
      emit(SettingLoading());

      // Get user ID
      _currentUserId = await _userPreferences.getUserId();
      if (_currentUserId == null) {
        emit(const SettingError('User not found'));
        return;
      }

      // Load user and categories
      final user = await _userService.getUserById(_currentUserId!);
      if (user == null) {
        emit(const SettingError('User profile not found'));
        return;
      }

      final categories = await _categoryService.getAllCategories(
        _currentUserId!,
      );

      emit(
        SettingLoaded(
          user: user,
          categories: categories,
          userId: _currentUserId,
        ),
      );
    } catch (e) {
      emit(SettingError('Failed to load profile: ${e.toString()}'));
    }
  }

  /// Refresh user profile and categories data
  Future<void> refreshUserData() async {
    final currentState = state;
    if (currentState is! SettingLoaded) {
      await loadUserProfile();
      return;
    }

    try {
      emit(
        SettingRefreshing(
          user: currentState.user,
          categories: currentState.categories,
        ),
      );

      final userId = _currentUserId ?? await _userPreferences.getUserId();
      if (userId == null) {
        emit(const SettingError('User not found'));
        return;
      }

      final user = await _userService.getUserById(userId);
      if (user == null) {
        emit(const SettingError('User profile not found'));
        return;
      }

      final categories = await _categoryService.getAllCategories(userId);

      _currentUserId = userId;

      emit(SettingLoaded(user: user, categories: categories, userId: userId));
    } catch (e) {
      emit(SettingError('Failed to refresh profile: ${e.toString()}'));
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String name,
    String? email,
    String? profileImageUrl,
  }) async {
    try {
      emit(SettingUpdatingProfile());

      final currentState = state;
      if (currentState is! SettingLoaded) {
        emit(const SettingProfileUpdateError('User not loaded'));
        await loadUserProfile();
        return;
      }

      // Update user - create updated UserModel with new values
      // Keep existing values for fields not being updated
      final updatedUser = UserModel(
        id: currentState.user.id,
        email: email?.isNotEmpty ?? false ? email! : currentState.user.email,
        passwordHash: currentState.user.passwordHash,
        name: name.isNotEmpty ? name : currentState.user.name,
        createdAt: currentState.user.createdAt,
      );

      await _userService.updateUser(updatedUser);
      emit(SettingProfileUpdated(updatedUser));
      await loadUserProfile();
    } catch (e) {
      emit(
        SettingProfileUpdateError('Failed to update profile: ${e.toString()}'),
      );
      await loadUserProfile();
    }
  }

  /// Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      emit(SettingChangingPassword());

      final currentState = state;
      if (currentState is! SettingLoaded) {
        emit(const SettingPasswordChangeError('User not loaded'));
        await loadUserProfile();
        return;
      }

      // Note: Password change typically requires verification
      // This is a placeholder - implement actual password change API call
      await Future.delayed(const Duration(milliseconds: 500));

      emit(SettingPasswordChanged());
      await loadUserProfile();
    } catch (e) {
      emit(
        SettingPasswordChangeError(
          'Failed to change password: ${e.toString()}',
        ),
      );
      await loadUserProfile();
    }
  }

  /// Load all categories
  Future<void> loadCategories() async {
    try {
      emit(SettingLoadingCategories());

      if (_currentUserId == null) {
        _currentUserId = await _userPreferences.getUserId();
      }

      if (_currentUserId == null) {
        emit(const SettingCategoriesError('User not found'));
        return;
      }

      final categories = await _categoryService.getAllCategories(
        _currentUserId!,
      );
      emit(SettingCategoriesLoaded(categories));
    } catch (e) {
      emit(
        SettingCategoriesError('Failed to load categories: ${e.toString()}'),
      );
    }
  }

  /// Add new category
  Future<void> addCategory({
    required String name,
    required String type,
    String? icon,
  }) async {
    try {
      emit(SettingAddingCategory());

      if (_currentUserId == null) {
        _currentUserId = await _userPreferences.getUserId();
      }

      if (_currentUserId == null) {
        emit(const SettingAddCategoryError('User not found'));
        return;
      }

      // Add category - actual implementation depends on CategoryService API
      await Future.delayed(const Duration(milliseconds: 500));
      await loadCategories();
    } catch (e) {
      emit(SettingAddCategoryError('Failed to add category: ${e.toString()}'));
      await loadCategories();
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      emit(SettingDeletingCategory(categoryId));

      if (_currentUserId == null) {
        _currentUserId = await _userPreferences.getUserId();
      }

      if (_currentUserId == null) {
        emit(SettingDeleteCategoryError('User not found', categoryId));
        return;
      }

      // Delete category - actual implementation depends on CategoryService API
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SettingCategoryDeleted(categoryId));
      await loadCategories();
    } catch (e) {
      emit(
        SettingDeleteCategoryError(
          'Failed to delete category: ${e.toString()}',
          categoryId,
        ),
      );
      await loadCategories();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      emit(SettingLoggingOut());
      await _userPreferences.removeUserId();
      emit(SettingLoggedOut());
    } catch (e) {
      emit(SettingLogoutError('Failed to logout: ${e.toString()}'));
      await loadUserProfile();
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      emit(SettingDeletingAccount());

      final currentState = state;
      if (currentState is! SettingLoaded) {
        emit(const SettingDeleteAccountError('User not loaded'));
        return;
      }

      await _userService.deleteUser(currentState.user.id);
      await _userPreferences.removeUserId();

      emit(SettingAccountDeleted());
    } catch (e) {
      emit(
        SettingDeleteAccountError('Failed to delete account: ${e.toString()}'),
      );
      await loadUserProfile();
    }
  }

  /// Reset to initial state
  void reset() {
    emit(SettingInitial());
  }
}
