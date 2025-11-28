import 'package:equatable/equatable.dart';
import 'package:moneyboys/data/Models/user.dart';
import 'package:moneyboys/data/Models/category.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class SettingInitial extends SettingState {}

/// Loading state - fetching user profile
class SettingLoading extends SettingState {}

/// Successfully loaded user profile and categories
class SettingLoaded extends SettingState {
  final UserModel user;
  final List<Category> categories;
  final String? userId;

  const SettingLoaded({
    required this.user,
    required this.categories,
    this.userId,
  });

  @override
  List<Object?> get props => [user, categories, userId];
}

/// Error state when loading user or categories fails
class SettingError extends SettingState {
  final String message;

  const SettingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when updating user profile
class SettingUpdatingProfile extends SettingState {}

/// State after successfully updating profile
class SettingProfileUpdated extends SettingState {
  final UserModel updatedUser;

  const SettingProfileUpdated(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}

/// State when profile update fails
class SettingProfileUpdateError extends SettingState {
  final String message;

  const SettingProfileUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when changing password
class SettingChangingPassword extends SettingState {}

/// State after successfully changing password
class SettingPasswordChanged extends SettingState {}

/// State when password change fails
class SettingPasswordChangeError extends SettingState {
  final String message;

  const SettingPasswordChangeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when loading categories
class SettingLoadingCategories extends SettingState {}

/// State after successfully loading categories
class SettingCategoriesLoaded extends SettingState {
  final List<Category> categories;

  const SettingCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// State when category loading fails
class SettingCategoriesError extends SettingState {
  final String message;

  const SettingCategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when adding a new category
class SettingAddingCategory extends SettingState {}

/// State after successfully adding category
class SettingCategoryAdded extends SettingState {
  final Category newCategory;

  const SettingCategoryAdded(this.newCategory);

  @override
  List<Object?> get props => [newCategory];
}

/// State when add category fails
class SettingAddCategoryError extends SettingState {
  final String message;

  const SettingAddCategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when deleting a category
class SettingDeletingCategory extends SettingState {
  final String categoryId;

  const SettingDeletingCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// State after successfully deleting category
class SettingCategoryDeleted extends SettingState {
  final String categoryId;

  const SettingCategoryDeleted(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// State when delete category fails
class SettingDeleteCategoryError extends SettingState {
  final String message;
  final String categoryId;

  const SettingDeleteCategoryError(this.message, this.categoryId);

  @override
  List<Object?> get props => [message, categoryId];
}

/// State when logging out
class SettingLoggingOut extends SettingState {}

/// State after successfully logging out
class SettingLoggedOut extends SettingState {}

/// State when logout fails
class SettingLogoutError extends SettingState {
  final String message;

  const SettingLogoutError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when deleting account
class SettingDeletingAccount extends SettingState {}

/// State after successfully deleting account
class SettingAccountDeleted extends SettingState {}

/// State when account deletion fails
class SettingDeleteAccountError extends SettingState {
  final String message;

  const SettingDeleteAccountError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when refreshing data
class SettingRefreshing extends SettingState {
  final UserModel user;
  final List<Category> categories;

  const SettingRefreshing({required this.user, required this.categories});

  @override
  List<Object?> get props => [user, categories];
}
