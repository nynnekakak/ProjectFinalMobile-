import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_state.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/spending_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/gemini_service.dart';
import 'package:moneyboys/data/services/budget_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final SpendingService _spendingService;
  final CategoryService _categoryService;
  final UserPreferences _userPreferences;
  final GeminiService _geminiService;
  final BudgetService _budgetService;

  HomeCubit({
    SpendingService? spendingService,
    CategoryService? categoryService,
    UserPreferences? userPreferences,
    GeminiService? geminiService,
    BudgetService? budgetService,
  }) : _spendingService = spendingService ?? SpendingService(),
       _categoryService = categoryService ?? CategoryService(),
       _userPreferences = userPreferences ?? UserPreferences(),
       _geminiService = geminiService ?? GeminiService(),
       _budgetService = budgetService ?? BudgetService(),
       super(HomeInitial());

  String? _currentUserId;

  /// Load all spendings and categories
  Future<void> loadSpendings() async {
    try {
      emit(HomeLoading());

      // Get user ID
      _currentUserId = await _userPreferences.getUserId();
      if (_currentUserId == null) {
        emit(const HomeError('User not found'));
        return;
      }

      // Load spendings and categories
      final spendingList = await _spendingService.getSpendings(_currentUserId!);
      final categories = await _categoryService.getAllCategories(
        _currentUserId!,
      );
      final catMap = {for (var cat in categories) cat.id: cat};

      emit(
        HomeLoaded(
          spendings: spendingList,
          categoryMap: catMap,
          userId: _currentUserId,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load spendings: ${e.toString()}'));
    }
  }

  /// Refresh spendings (pull to refresh)
  Future<void> refreshSpendings() async {
    final currentState = state;
    if (currentState is! HomeLoaded) {
      await loadSpendings();
      return;
    }

    try {
      emit(
        HomeRefreshing(
          spendings: currentState.spendings,
          categoryMap: currentState.categoryMap,
        ),
      );

      // Get updated data
      final userId = _currentUserId ?? await _userPreferences.getUserId();
      if (userId == null) {
        emit(const HomeError('User not found'));
        return;
      }

      final spendingList = await _spendingService.getSpendings(userId);
      final categories = await _categoryService.getAllCategories(userId);
      final catMap = {for (var cat in categories) cat.id: cat};

      _currentUserId = userId;

      emit(
        HomeLoaded(
          spendings: spendingList,
          categoryMap: catMap,
          userId: userId,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to refresh spendings: ${e.toString()}'));
    }
  }

  /// Delete a spending
  Future<void> deleteSpending(String spendingId) async {
    try {
      emit(HomeDeletingSpending(spendingId));

      await _spendingService.deleteSpending(spendingId);

      // Reload data after deletion
      await loadSpendings();
    } catch (e) {
      emit(
        HomeDeleteError(
          'Failed to delete spending: ${e.toString()}',
          spendingId,
        ),
      );
      // Restore to loaded state
      await loadSpendings();
    }
  }

  /// Notify that spending has been updated
  Future<void> notifySpendingUpdated() async {
    emit(HomeSpendingUpdated());
    await loadSpendings();
  }

  /// Get AI advice for spending analysis
  Future<void> getAIAdvice() async {
    try {
      emit(HomeAILoading());

      final currentState = state;
      if (currentState is! HomeLoaded) {
        emit(const HomeAIError('Please load data first'));
        return;
      }

      final budgets = await _budgetService.getBudgets();
      final categories = currentState.categoryMap.values.toList();

      final advice = await _geminiService.analyzeSpending(
        currentState.spendings,
        budgets,
        categories,
      );

      emit(HomeAILoaded(advice));
    } catch (e) {
      emit(
        HomeAIError(
          'Không thể kết nối với AI. Vui lòng kiểm tra API key và kết nối internet.\n\nLỗi: ${e.toString()}',
        ),
      );
    }
  }

  /// Reset to initial state
  void reset() {
    emit(HomeInitial());
  }
}
