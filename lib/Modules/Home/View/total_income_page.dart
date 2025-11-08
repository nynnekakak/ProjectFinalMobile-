import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:moneyboys/data/Models/category.dart';
import 'package:moneyboys/data/Models/spending.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/spending_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';

class TotalIncomePage extends StatefulWidget {
  const TotalIncomePage({super.key});

  @override
  State<TotalIncomePage> createState() => _TotalIncomePageState();
}

class _TotalIncomePageState extends State<TotalIncomePage> {
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate;
  DateTime _focusedDay = DateTime.now();

  List<Spending> _spendings = [];
  List<Category> _categories = [];
  String? userId;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    userId = await UserPreferences().getUserId();
    final allCategories = await CategoryService().getAllCategories(userId!);
    final filteredSpendings = await SpendingService().getSpendingsInRange(
      _startDate!,
      _endDate ?? _startDate!,
      'income',
    );
    setState(() {
      _categories = allCategories;
      _spendings = filteredSpendings;
    });
  }

  double get totalIncome {
    return _spendings
        .where((e) => _getCategory(e.categoryId)?.type == 'income')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Category? _getCategory(String categoryId) {
    return _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => Category(
        id: '',
        name: 'Unknown',
        type: 'income',
        isShared: false,
        createdAt: DateTime.now(),
      ),
    );
  }

  Map<String, double> get _categoryData {
    Map<String, double> data = {};
    for (var s in _spendings) {
      final cat = _getCategory(s.categoryId);
      if (cat != null && cat.type == 'income') {
        data[cat.name] = (data[cat.name] ?? 0) + s.amount;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF0040FF);
    final formatter = NumberFormat("#,###", "en_US");

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Total Income",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111111),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  _buildCalendar(primaryBlue),
                  _buildTotalAmountCircle(primaryBlue, formatter),
                  _buildTabBar(primaryBlue),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _tabIndex == 0
                        ? _buildSpendingList()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _buildPieChartWithLegend(primaryBlue),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(Color primaryBlue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.now(),
        selectedDayPredicate: (day) =>
            isSameDay(day, _startDate) || isSameDay(day, _endDate),
        rangeStartDay: _startDate,
        rangeEndDay: _endDate,
        rangeSelectionMode: RangeSelectionMode.enforced,
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
            if (_startDate != null &&
                _endDate == null &&
                selectedDay.isAfter(_startDate!)) {
              _endDate = selectedDay;
            } else {
              _startDate = selectedDay;
              _endDate = null;
            }
          });
          _fetchData();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.grey[400],
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
          ),
          rangeHighlightColor: primaryBlue.withOpacity(0.1),
          rangeStartDecoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        availableCalendarFormats: const {CalendarFormat.twoWeeks: '2 weeks'},
        calendarFormat: CalendarFormat.twoWeeks,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: primaryBlue),
          rightChevronIcon: Icon(Icons.chevron_right, color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildTotalAmountCircle(Color primaryBlue, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${formatter.format(totalIncome)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Income in selected range",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(Color primaryBlue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _tabIndex = 0),
              child: Column(
                children: [
                  Text(
                    "Spends",
                    style: TextStyle(
                      color: _tabIndex == 0 ? primaryBlue : Colors.grey[700],
                      fontWeight: _tabIndex == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_tabIndex == 0)
                    Container(
                      height: 2,
                      color: primaryBlue,
                      margin: const EdgeInsets.only(top: 4),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _tabIndex = 1),
              child: Column(
                children: [
                  Text(
                    "Categories",
                    style: TextStyle(
                      color: _tabIndex == 1 ? primaryBlue : Colors.grey[700],
                      fontWeight: _tabIndex == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_tabIndex == 1)
                    Container(
                      height: 2,
                      color: primaryBlue,
                      margin: const EdgeInsets.only(top: 4),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartWithLegend(Color primaryColor) {
    final items = _categoryData.entries.toList();
    if (items.isEmpty) {
      return Center(
        child: Text(
          "No category data",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    final sections = items.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = Colors.primaries[index % Colors.primaries.length];
      final percent = (data.value / totalIncome) * 100;

      return PieChartSectionData(
        color: color,
        value: data.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final color = Colors.primaries[index % Colors.primaries.length];
              final amount = data.value;

              return Container(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.key,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingList() {
    if (_spendings.isEmpty) {
      return Center(
        child: Text(
          'No income found in this range',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _spendings.length,
      itemBuilder: (context, index) {
        final spending = _spendings[index];
        final category = _getCategory(spending.categoryId);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category?.icon ?? "❓",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              category?.name ?? "Unknown",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            subtitle: Text(
              DateFormat('dd MMM yyyy').format(spending.date),
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "+\$${spending.amount.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (spending.note?.isNotEmpty == true)
                  Text(
                    spending.note!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
