import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/spending_service.dart';
import '../../../data/services/category_service.dart';
import 'monitor_state.dart';

class MonitorCubit extends Cubit<MonitorState> {
  final SpendingService _spendingService;
  final CategoryService _categoryService;

  MonitorCubit({
    SpendingService? spendingService,
    CategoryService? categoryService,
  }) : _spendingService = spendingService ?? SpendingService(),
       _categoryService = categoryService ?? CategoryService(),
       super(MonitorInitial());

  Future<void> loadSpendingData(String userId) async {
    emit(MonitorLoading());
    try {
      final spendings = await _spendingService.getSpendings(userId);

      Map<String, double> expenseMap = {};
      Map<String, double> incomeMap = {};

      for (var item in spendings) {
        final dateKey = item.date.toIso8601String().split('T').first;
        final category = await _categoryService.getCategoryById(
          item.categoryId,
        );

        if (category == null) continue;

        if (category.type == 'expense') {
          expenseMap[dateKey] = (expenseMap[dateKey] ?? 0) + item.amount;
        } else if (category.type == 'income') {
          incomeMap[dateKey] = (incomeMap[dateKey] ?? 0) + item.amount;
        }
      }

      emit(
        MonitorLoaded(
          expenseData: expenseMap,
          incomeData: incomeMap,
          viewMode: 'weekly',
          currentPageIndex: 0,
        ),
      );
    } catch (e) {
      emit(MonitorError('Lỗi tải dữ liệu: ${e.toString()}'));
    }
  }

  void setViewMode(String mode) {
    final currentState = state;
    if (currentState is MonitorLoaded) {
      emit(currentState.copyWith(viewMode: mode, currentPageIndex: 0));
    }
  }

  void setPageIndex(int index) {
    final currentState = state;
    if (currentState is MonitorLoaded) {
      emit(currentState.copyWith(currentPageIndex: index));
    }
  }

  void refresh(String userId) {
    loadSpendingData(userId);
  }
}
