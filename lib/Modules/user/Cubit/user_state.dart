part of 'user_cubit.dart';

abstract class UserState {
  const UserState();
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final Map<String, dynamic> userData;
  final String? name;
  final String? email;
  final String? profileImageUrl;
  final DateTime? createdAt;

  const UserLoaded({
    required this.userData,
    this.name,
    this.email,
    this.profileImageUrl,
    this.createdAt,
  });

  UserLoaded copyWith({
    Map<String, dynamic>? userData,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserLoaded(
      userData: userData ?? this.userData,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);
}

class UserUpdated extends UserState {
  final Map<String, dynamic> updatedData;

  const UserUpdated(this.updatedData);
}
