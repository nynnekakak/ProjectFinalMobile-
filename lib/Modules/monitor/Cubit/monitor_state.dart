abstract class MonitorState {}

class MonitorInitial extends MonitorState {}

class MonitorLoading extends MonitorState {}

class MonitorLoaded extends MonitorState {
  final Map<String, double> expenseData;
  final Map<String, double> incomeData;
  final String viewMode; // 'weekly' or 'monthly'
  final int currentPageIndex;

  MonitorLoaded({
    required this.expenseData,
    required this.incomeData,
    this.viewMode = 'weekly',
    this.currentPageIndex = 0,
  });

  MonitorLoaded copyWith({
    Map<String, double>? expenseData,
    Map<String, double>? incomeData,
    String? viewMode,
    int? currentPageIndex,
  }) {
    return MonitorLoaded(
      expenseData: expenseData ?? this.expenseData,
      incomeData: incomeData ?? this.incomeData,
      viewMode: viewMode ?? this.viewMode,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }
}

class MonitorError extends MonitorState {
  final String message;
  MonitorError(this.message);
}
