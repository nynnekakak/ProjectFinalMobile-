import 'package:equatable/equatable.dart';
import 'package:moneyboys/data/Models/category.dart';
import 'package:moneyboys/data/Models/spending.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class HomeInitial extends HomeState {}

/// Loading state - fetching spendings and categories
class HomeLoading extends HomeState {}

/// Successfully loaded spendings and categories
class HomeLoaded extends HomeState {
  final List<Spending> spendings;
  final Map<String, Category> categoryMap;
  final String? userId;

  const HomeLoaded({
    required this.spendings,
    required this.categoryMap,
    this.userId,
  });

  @override
  List<Object?> get props => [spendings, categoryMap, userId];
}

/// Error state when loading spendings or categories fails
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State after successfully deleting a spending
class HomeSpendingDeleted extends HomeState {
  final String spendingId;

  const HomeSpendingDeleted(this.spendingId);

  @override
  List<Object?> get props => [spendingId];
}

/// State for deleting spending (to show loading state during deletion)
class HomeDeletingSpending extends HomeState {
  final String spendingId;

  const HomeDeletingSpending(this.spendingId);

  @override
  List<Object?> get props => [spendingId];
}

/// State when deleting spending fails
class HomeDeleteError extends HomeState {
  final String message;
  final String spendingId;

  const HomeDeleteError(this.message, this.spendingId);

  @override
  List<Object?> get props => [message, spendingId];
}

/// State after spending edit completed
class HomeSpendingUpdated extends HomeState {}

/// State for refreshing data
class HomeRefreshing extends HomeState {
  final List<Spending> spendings;
  final Map<String, Category> categoryMap;

  const HomeRefreshing({required this.spendings, required this.categoryMap});

  @override
  List<Object?> get props => [spendings, categoryMap];
}

/// State for AI advice loading
class HomeAILoading extends HomeState {}

/// State for AI advice loaded
class HomeAILoaded extends HomeState {
  final String advice;

  const HomeAILoaded(this.advice);

  @override
  List<Object?> get props => [advice];
}

/// State for AI advice error
class HomeAIError extends HomeState {
  final String message;

  const HomeAIError(this.message);

  @override
  List<Object?> get props => [message];
}
