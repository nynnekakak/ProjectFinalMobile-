import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String message;

  const SignUpSuccess({this.message = 'Sign up successful'});

  @override
  List<Object?> get props => [message];
}

class SignUpFailure extends SignUpState {
  final String message;

  const SignUpFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class SignUpEmailExists extends SignUpState {
  const SignUpEmailExists();
}

class SignUpValidationError extends SignUpState {
  final String message;

  const SignUpValidationError(this.message);

  @override
  List<Object?> get props => [message];
}
