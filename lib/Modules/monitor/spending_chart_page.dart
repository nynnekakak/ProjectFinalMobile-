import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:intl/intl.dart';
import '../../data/services/spending_service.dart';
import 'package:moneyboys/data/services/gemini_service.dart';
import 'package:moneyboys/data/services/budget_service.dart';
import 'package:moneyboys/Shared/widgets/ai_assistant_widget.dart';

enum SpendingType { expense, income }

enum ViewMode { weekly, monthly }

class SpendingChartPage extends StatefulWidget {
  const SpendingChartPage({super.key});

  @override
  State<SpendingChartPage> createState() => _SpendingChartPageState();
}

class _SpendingChartPageState extends State<SpendingChartPage> {
  final SpendingService spendingService = SpendingService();
  final CategoryService _categoryService = CategoryService();
  final PageController _pageController = PageController();
  final GeminiService _geminiService = GeminiService();

  Map<String, double> _expenseData = {};
  Map<String, double> _incomeData = {};
  ViewMode _viewMode = ViewMode.weekly;
  int _currentPageIndex = 0;

  // Clean, eye-friendly colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color expenseColor = Color(0xFF0040FF);
  static const Color incomeColor = Color(0xFF80CFFF); // Material green
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color accentColor = Color(0xFF2196F3);
  // Orange color for average line

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 5;
    _loadSpendingData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSpendingData() async {
    final userId = await UserPreferences().getUserId();
    final spendings = await spendingService.getSpendings(userId!);

    Map<String, double> expenseMap = {};
    Map<String, double> incomeMap = {};

    for (var item in spendings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.date);
      final categories = await _categoryService.getCategoryById(
        item.categoryId,
      );

      if (categories!.type == 'expense') {
        expenseMap[dateKey] = (expenseMap[dateKey] ?? 0) + item.amount;
      } else if (categories.type == 'income') {
        incomeMap[dateKey] = (incomeMap[dateKey] ?? 0) + item.amount;
      }
    }

    if (!mounted) return;
    setState(() {
      _expenseData = expenseMap;
      _incomeData = incomeMap;
    });
  }

  Map<String, Map<String, double>> _groupDataByPeriod() {
    Map<String, Map<String, double>> groupedData = {};

    final allDates = <String>{};
    allDates.addAll(_expenseData.keys);
    allDates.addAll(_incomeData.keys);

    if (_viewMode == ViewMode.weekly) {
      for (String dateStr in allDates) {
        groupedData[dateStr] = {
          'expense': _expenseData[dateStr] ?? 0.0,
          'income': _incomeData[dateStr] ?? 0.0,
        };
      }
    } else {
      for (String dateStr in allDates) {
        final date = DateTime.parse(dateStr);
        final periodKey = DateFormat('yyyy-MM').format(date);

        if (!groupedData.containsKey(periodKey)) {
          groupedData[periodKey] = {'expense': 0.0, 'income': 0.0};
        }

        groupedData[periodKey]!['expense'] =
            (groupedData[periodKey]!['expense']! +
            (_expenseData[dateStr] ?? 0));
        groupedData[periodKey]!['income'] =
            (groupedData[periodKey]!['income']! + (_incomeData[dateStr] ?? 0));
      }
    }

    return groupedData;
  }

  Map<String, double> _calculateAverageForPage(int pageIndex) {
    final periodsForPage = _getPeriodsForPage(pageIndex);
    if (periodsForPage.isEmpty) return {'expense': 0.0, 'income': 0.0};

    final groupedData = _groupDataByPeriod();
    double totalExpense = 0.0;
    double totalIncome = 0.0;
    int validPeriods = 0;

    for (String period in periodsForPage) {
      final data = groupedData[period];
      if (data != null) {
        totalExpense += data['expense']!;
        totalIncome += data['income']!;
        validPeriods++;
      }
    }

    return {
      'expense': validPeriods > 0 ? totalExpense / validPeriods : 0.0,
      'income': validPeriods > 0 ? totalIncome / validPeriods : 0.0,
    };
  }

  List<DateTime> get _allWeeks {
    final today = DateTime.now();
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(6, (i) {
      final weekStart = thisWeekStart.subtract(Duration(days: i * 7));
      return DateTime(weekStart.year, weekStart.month, weekStart.day);
    });
  }

  List<String> get _sortedPeriods {
    if (_viewMode == ViewMode.weekly) {
      final allDates = <String>{};
      allDates.addAll(_expenseData.keys);
      allDates.addAll(_incomeData.keys);
      final periods = allDates.toList();
      periods.sort((a, b) => a.compareTo(b));
      return periods;
    } else {
      final groupedData = _groupDataByPeriod();
      final periods = groupedData.keys.toList();
      periods.sort((a, b) => a.compareTo(b));
      return periods;
    }
  }

  // Get dates for a specific week
  List<String> _getDatesForWeek(DateTime weekStart) {
    List<String> weekDates = [];
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      weekDates.add(DateFormat('yyyy-MM-dd').format(date));
    }
    return weekDates;
  }

  List<String> _getPeriodsForPage(int pageIndex) {
    if (_viewMode == ViewMode.weekly) {
      final weeks = _allWeeks;
      if (pageIndex < 0 || pageIndex >= weeks.length) return [];
      return _getDatesForWeek(weeks[pageIndex]);
    } else {
      final allPeriods = _sortedPeriods;
      final periodsPerPage = 4;
      final startIndex = pageIndex * periodsPerPage;
      final endIndex = (startIndex + periodsPerPage).clamp(
        0,
        allPeriods.length,
      );

      if (startIndex >= allPeriods.length) return [];
      return allPeriods.sublist(startIndex, endIndex);
    }
  }

  int get _totalPages {
    if (_viewMode == ViewMode.weekly) {
      return _allWeeks.length;
    } else {
      final periodsPerPage = 4;
      return (_sortedPeriods.length / periodsPerPage).ceil();
    }
  }

  String _formatPeriodLabel(String period) {
    if (_viewMode == ViewMode.weekly) {
      final date = DateTime.parse(period);
      final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return weekdays[date.weekday - 1];
    } else {
      final date = DateTime.parse('$period-01');
      return DateFormat('MM/yyyy').format(date);
    }
  }

  String _getWeekTitle(int pageIndex) {
    if (_viewMode == ViewMode.weekly && _allWeeks.isNotEmpty) {
      final weekStart = _allWeeks[pageIndex];
      final weekEnd = weekStart.add(Duration(days: 6));
      return '${DateFormat('dd/MM').format(weekStart)} - ${DateFormat('dd/MM').format(weekEnd)}';
    }
    return '';
  }

  String _formatAmount(double value) {
    if (value > 1000000000)
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return NumberFormat('#,###').format(value);
  }

  double _getTotalExpense() {
    return _expenseData.values.fold(0, (a, b) => a + b);
  }

  double _getTotalIncome() {
    return _incomeData.values.fold(0, (a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              selectedBorderColor: accentColor,
              selectedColor: Colors.white,
              fillColor: accentColor,
              color: textSecondary,
              constraints: const BoxConstraints(minWidth: 45, minHeight: 32),
              isSelected: [
                _viewMode == ViewMode.weekly,
                _viewMode == ViewMode.monthly,
              ],
              onPressed: (index) {
                if (!mounted) return;
                setState(() {
                  _viewMode = index == 0 ? ViewMode.weekly : ViewMode.monthly;
                  _currentPageIndex = 0;
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Tuần',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Tháng',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats cards
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.trending_down_rounded,
                      title: 'Tổng chi tiêu',
                      amount: _getTotalExpense(),
                      color: expenseColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.trending_up_rounded,
                      title: 'Tổng thu nhập',
                      amount: _getTotalIncome(),
                      color: incomeColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Chart container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chart header
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _viewMode == ViewMode.weekly
                                    ? 'Chi tiêu theo tuần'
                                    : 'Chi tiêu theo tháng',
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_viewMode == ViewMode.weekly &&
                                  _totalPages > 0)
                                Text(
                                  _getWeekTitle(_currentPageIndex),
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Legend with average line
                    Row(
                      children: [
                        _buildLegendItem(context, 'Chi tiêu', expenseColor),
                        const SizedBox(width: 20),
                        _buildLegendItem(context, 'Thu nhập', incomeColor),
                      ],
                    ),
                    Row(
                      children: [
                        _buildLegendItem(
                          context,
                          'Trung bình chi tiêu',
                          expenseColor,
                          isDashed: true,
                        ),
                        const SizedBox(width: 20),
                        _buildLegendItem(
                          context,
                          'Trung bình thu nhập',
                          incomeColor,
                          isDashed: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Chart with PageView
                    Expanded(
                      child: _totalPages > 0
                          ? PageView.builder(
                              controller: _pageController,
                              itemCount: _totalPages,
                              onPageChanged: (index) {
                                if (!mounted) return;
                                setState(() {
                                  _currentPageIndex = index;
                                });
                              },
                              itemBuilder: (context, pageIndex) {
                                return _buildBarChart(pageIndex);
                              },
                            )
                          : const Center(
                              child: Text(
                                'Không có dữ liệu',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),

                    // Navigation hints
                    if (_totalPages > 1)
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swipe_left,
                              color: textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Vuốt để xem thêm',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AIAdviceDialog(
                onGetAdvice: _getChartAIAdvice,
                title: 'Phân tích xu hướng',
                icon: Icons.trending_up,
              ),
            );
          },
          icon: const Icon(Icons.psychology),
          label: const Text('Hỏi AI'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color, {
    bool isDashed = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth.clamp(200, double.infinity);

        const double referenceWidth = 360.0;
        double scaleFactor = screenWidth / referenceWidth;

        const double baseShapeSize = 10.0;
        double shapeSize = baseShapeSize * scaleFactor.clamp(0.8, 1.2);
        double lineHeight = shapeSize / 6;
        double fontSize = shapeSize * 0.9;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDashed)
              Container(
                width: shapeSize,
                height: lineHeight,
                child: CustomPaint(painter: DashedLinePainter(color: color)),
              )
            else
              Container(
                width: shapeSize,
                height: shapeSize,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(shapeSize * 0.15),
                ),
              ),
            SizedBox(width: 6 * scaleFactor.clamp(0.8, 1.2)),
            Text(
              label,
              style: TextStyle(
                color: textSecondary,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarChart(int pageIndex) {
    final periodsForPage = _getPeriodsForPage(pageIndex);
    if (periodsForPage.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu cho trang này',
          style: TextStyle(color: textSecondary),
        ),
      );
    }

    final groupedData = _groupDataByPeriod();
    final averageData = _calculateAverageForPage(pageIndex);
    final maxValue = periodsForPage.fold<double>(0, (max, period) {
      final data = groupedData[period];
      if (data == null) return max;
      final periodMax = [
        data['expense']!,
        data['income']!,
      ].reduce((a, b) => a > b ? a : b);
      return periodMax > max ? periodMax : max;
    });

    final maxWithAverage = [
      maxValue,
      averageData['expense']!,
      averageData['income']!,
    ].reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxWithAverage > 0 ? maxWithAverage * 1.2 : 100,
        minY: 0,
        groupsSpace: _viewMode == ViewMode.weekly ? 8 : 20,
        barGroups: periodsForPage.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          final data = groupedData[period] ?? {'expense': 0.0, 'income': 0.0};

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['expense']!,
                color: expenseColor,
                width: _viewMode == ViewMode.weekly ? 16 : 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: data['income']!,
                color: incomeColor,
                width: _viewMode == ViewMode.weekly ? 16 : 20,
                borderSide: BorderSide(
                  color: incomeColor.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            // Average expense line
            if (averageData['expense']! > 0)
              HorizontalLine(
                y: averageData['expense']!,
                color: expenseColor,
                strokeWidth: 2,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  style: TextStyle(
                    color: expenseColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            // Average income line
            if (averageData['income']! > 0)
              HorizontalLine(
                y: averageData['income']!,
                color: incomeColor,
                strokeWidth: 2,
                dashArray: [3, 3],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 10, top: 4),
                  style: TextStyle(
                    color: incomeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                if (value == (maxWithAverage > 0 ? maxWithAverage * 1.2 : 100))
                  return const SizedBox();
                return Text(
                  _formatAmount(value),
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= periodsForPage.length) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatPeriodLabel(periodsForPage[index]),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: _viewMode == ViewMode.weekly ? 12 : 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: borderColor, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: borderColor, width: 1),
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String type = rodIndex == 0 ? 'Chi tiêu' : 'Thu nhập';
              final period = periodsForPage[groupIndex];
              String dateInfo = '';
              if (_viewMode == ViewMode.weekly) {
                final date = DateTime.parse(period);
                dateInfo = DateFormat('dd/MM/yyyy').format(date);
              }

              return BarTooltipItem(
                '$type${dateInfo.isNotEmpty ? '\n$dateInfo' : ''}\n${_formatAmount(rod.toY)}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _formatAmount(amount),
          style: const TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset((startX + dashWidth).clamp(0, size.width), size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on _SpendingChartPageState {
  Future<String> _getChartAIAdvice() async {
    try {
      final userId = await UserPreferences().getUserId();
      if (userId == null) {
        return 'Không thể lấy thông tin người dùng.';
      }

      final spendings = await spendingService.getSpendings(userId);
      final categories = await _categoryService.getAllCategories(userId);

      // Lấy số ngày dựa vào chế độ xem
      final days = _viewMode == ViewMode.weekly ? 7 : 30;

      return await _geminiService.analyzeTrends(spendings, categories, days);
    } catch (e) {
      return 'Không thể kết nối với AI. Vui lòng kiểm tra API key và kết nối internet.\n\nLỗi: ${e.toString()}';
    }
  }
}
