import 'package:equatable/equatable.dart';

abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  final String userId;
  final String userName;

  const SignInSuccess({required this.userId, required this.userName});

  @override
  List<Object?> get props => [userId, userName];
}

class SignInFailure extends SignInState {
  final String message;

  const SignInFailure(this.message);

  @override
  List<Object?> get props => [message];
}
