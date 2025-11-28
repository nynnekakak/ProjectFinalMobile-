import 'package:equatable/equatable.dart';
import 'package:moneyboys/data/Models/user.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final UserModel user;

  const AccountLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountDeleting extends AccountState {}

class AccountDeleted extends AccountState {}

class AccountLoggedOut extends AccountState {}
