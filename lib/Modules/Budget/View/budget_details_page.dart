import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:moneyboys/data/Models/budget.dart';
import 'package:moneyboys/data/Models/category.dart';
import 'package:moneyboys/data/Models/spending.dart';
import 'package:moneyboys/data/services/budget_service.dart';
// bỏ supabase, sử dụng lại thì uncomment import dưới và _loadBudgetDetails
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moneyboys/data/mock/mock_data.dart';
import '../widget/budget_line_chart.dart';
import 'edit_budget_page.dart';

class BudgetDetailsPage extends StatefulWidget {
  final String budgetId;

  const BudgetDetailsPage({super.key, required this.budgetId});

  @override
  State<BudgetDetailsPage> createState() => _BudgetDetailsPageState();
}

class _BudgetDetailsPageState extends State<BudgetDetailsPage> {
  // final supabase = Supabase.instance.client;
  late Budget budgetData;
  late Category categoryData;
  List<Map<String, dynamic>> relatedSpendings = [];
  double totalSpent = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBudgetDetails();
  }

  /// Map budget mock -> map cho Budget.fromMap (nếu model parse từ key gốc)
  Map<String, dynamic> _budgetMapForModel(Map<String, dynamic> b) => {
    'id': b['id'],
    'user_id': b['user_id'],
    'category_id': b['category_id'],
    'amount': (b['amount'] as num).toDouble(),
    'start_date': b['start_date'],
    'end_date': b['end_date'],
    'created_at': b['created_at'],
  };

  /// Map category mock -> map cho Category.fromMap
  Map<String, dynamic> _categoryMapForModel(Map<String, dynamic> c) => {
    'id': c['id'],
    'name': c['name'],
    'icon': c['icon'],
  };

  Future<void> loadBudgetDetails() async {
    try {
      // 1) Lấy budget từ mock theo id
      final b = mockBudgets.firstWhere((x) => x['id'] == widget.budgetId);

      final categoryId = b['category_id'] as String;
      final userId = b['user_id'] as String;
      final startDate = DateTime.parse(b['start_date'] as String);
      final endDate = DateTime.parse(b['end_date'] as String);

      // 2) Lấy category từ mock
      final c =
          findCategory(categoryId) ??
          {'id': categoryId, 'name': 'Unknown', 'icon': '❔'};

      // 3) Lấy danh sách spending liên quan trong khoảng thời gian
      final spends =
          mockSpendings.where((s) {
            final d = DateTime.parse(s['date'] as String);
            return s['user_id'] == userId &&
                s['category_id'] == categoryId &&
                !d.isBefore(startDate) &&
                !d.isAfter(endDate);
          }).toList()..sort(
            (a, b) => DateTime.parse(
              b['date'] as String,
            ).compareTo(DateTime.parse(a['date'] as String)),
          ); // desc

      // 4) Tổng tiền đã chi
      final spent = spends.fold<double>(
        0.0,
        (sum, s) => sum + (s['amount'] as num).toDouble(),
      );

      setState(() {
        budgetData = Budget.fromMap(_budgetMapForModel(b));
        categoryData = Category.fromMap(_categoryMapForModel(c));
        relatedSpendings = spends;
        totalSpent = spent;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading budget details (mock): $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  // Future<void> loadBudgetDetails() async {
  //   try {
  //     final budgetResponse = await supabase
  //         .from('budget')
  //         .select()
  //         .eq('id', widget.budgetId)
  //         .single();

  //     final categoryId = budgetResponse['category_id'];
  //     final userId = budgetResponse['userid'];
  //     final startDate = DateTime.parse(budgetResponse['start_date']);
  //     final endDate = DateTime.parse(budgetResponse['end_date']);

  //     final categoryResponse = await supabase
  //         .from('category')
  //         .select()
  //         .eq('id', categoryId)
  //         .single();

  //     final spendingsResponse = await supabase
  //         .from('spending')
  //         .select()
  //         .eq('userid', userId)
  //         .eq('category_id', categoryId)
  //         .gte('date', startDate.toIso8601String())
  //         .lte('date', endDate.toIso8601String())
  //         .order('date', ascending: false);

  //     double spent = 0;
  //     for (var s in spendingsResponse) {
  //       spent += s['amount'];
  //     }

  //     setState(() {
  //       budgetData = Budget.fromMap(budgetResponse);
  //       categoryData = Category.fromMap(categoryResponse);
  //       relatedSpendings = List<Map<String, dynamic>>.from(spendingsResponse);
  //       totalSpent = spent;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error loading budget details: $e');
  //   }
  // }

  void _deleteBudget(String id) async {
    await BudgetService().deleteBudget(id);
  }

  Map<DateTime, double> getCumulativeSpendingPerDay({
    required DateTime start,
    required DateTime end,
    required List<Spending> spendings,
  }) {
    final dailyMap = <DateTime, double>{};
    double total = 0;

    for (
      DateTime day = start;
      !day.isAfter(end);
      day = day.add(Duration(days: 1))
    ) {
      final dailySpend = spendings
          .where(
            (s) =>
                s.date.year == day.year &&
                s.date.month == day.month &&
                s.date.day == day.day,
          )
          .fold(0.0, (sum, s) => sum + s.amount);
      total += dailySpend;
      dailyMap[day] = total;
    }

    return dailyMap;
  }

  @override
  Widget build(BuildContext context) {
    final lightBlue = Colors.grey[100];
    final primaryBlue = const Color(0xFF0040FF);

    if (isLoading) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Scaffold(
            backgroundColor: lightBlue,
            body: Center(child: CircularProgressIndicator(color: primaryBlue)),
          ),
        ),
      );
    }

    final formatter = DateFormat('dd/MM/yyyy');
    final startDate = formatter.format(budgetData.startDate);
    final endDate = formatter.format(budgetData.endDate);
    final remaining = budgetData.amount - totalSpent;
    final spendingMap = getCumulativeSpendingPerDay(
      start: budgetData.startDate,
      end: budgetData.endDate,
      spendings: relatedSpendings.map((s) => Spending.fromMap(s)).toList(),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: lightBlue,
          appBar: AppBar(
            title: const Text(
              "Chi tiết ngân sách",
              style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            iconTheme: const IconThemeData(color: Color(0xFF111111)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF111111)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditBudgetPage(budget: budgetData),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFF111111)),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xóa ngân sách'),
                      content: const Text(
                        'Bạn có chắc chắn muốn xóa ngân sách này không?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      _deleteBudget(widget.budgetId);
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      print('Lỗi khi xóa ngân sách: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xóa thất bại')),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            categoryData.icon ?? '📁',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryData.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111111),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$startDate - $endDate",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      _buildAmountRow(
                        "Tổng ngân sách",
                        budgetData.amount,
                        primaryBlue,
                      ),
                      _buildAmountRow("Đã chi tiêu", totalSpent, Colors.red),
                      const Divider(height: 16),
                      _buildAmountRow(
                        "Còn lại",
                        remaining,
                        remaining >= 0 ? Colors.green : Colors.red,
                        isBold: true,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BudgetLineChart(
                  startDate: budgetData.startDate,
                  endDate: budgetData.endDate,
                  budgetAmount: budgetData.amount,
                  spendingData: spendingMap,
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "Các giao dịch",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: relatedSpendings.isEmpty
                      ? Center(
                          child: Text(
                            "Không có giao dịch nào",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: relatedSpendings.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final spending = relatedSpendings[index];
                            final date = DateFormat(
                              'dd/MM/yyyy',
                            ).format(DateTime.parse(spending['date']));
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      categoryData.icon ?? '📁',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  "${NumberFormat('#,###').format(spending['amount'])} đ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (spending['note'] != null &&
                                        spending['note'].toString().isNotEmpty)
                                      Text(
                                        spending['note'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    Text(
                                      date,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF111111),
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            "${NumberFormat('#,###').format(amount)} đ",
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
