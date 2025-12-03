import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moneyboys/Modules/Home/View/total_expense_page.dart';
import 'package:moneyboys/Modules/Home/View/total_income_page.dart';
import 'package:moneyboys/Modules/expense/edit_spending_page.dart';
import 'package:moneyboys/data/Models/category.dart';
import 'package:moneyboys/data/Models/spending.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/spending_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/gemini_service.dart';
import 'package:moneyboys/data/services/budget_service.dart';
import 'package:moneyboys/Shared/widgets/ai_assistant_widget.dart';
import 'package:moneyboys/Shared/widgets/ai_chat_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Spending> spendings = [];
  Map<String, Category> categoryMap = {};
  static String? userId;
  bool isLoading = true;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    _loadSpendings();
  }

  Future<void> _loadSpendings() async {
    setState(() => isLoading = true);
    userId = await UserPreferences().getUserId();
    final spendingList = await SpendingService().getSpendings(userId!);
    final categories = await CategoryService().getAllCategories(userId!);
    final catMap = {for (var cat in categories) cat.id: cat};

    setState(() {
      spendings = spendingList;
      categoryMap = catMap;
      isLoading = false;
    });
  }

  void _deleteSpending(String id) async {
    await SpendingService().deleteSpending(id);
    await _loadSpendings();
  }

  void _navigateToEdit(Spending spending) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditSpendingPage(spending: spending)),
    );
    await _loadSpendings();
  }

  Widget _buildTopCards() {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var s in spendings) {
      if (categoryMap[s.categoryId]?.type == 'income') {
        totalIncome += s.amount;
      } else {
        totalExpense += s.amount;
      }
    }

    return Column(
      children: [
        _buildSummaryCard(
          double.infinity,
          120,
          'Số dư',
          totalIncome - totalExpense,
          const Color(0xFF0040FF),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard2(
                double.infinity,
                90,
                "Tổng thu nhập",
                Colors.white,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TotalIncomePage()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard2(
                double.infinity,
                90,
                "Tổng chi tiêu",
                const Color(0xFF0040FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TotalExpensePage()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard2(
    double width,
    double height,
    String title,
    Color color, {
    required VoidCallback onTap,
  }) {
    final isBlue = color == const Color(0xFF0040FF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.credit_card,
              color: isBlue ? Colors.white : const Color(0xFF0040FF),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isBlue ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    double width,
    double height,
    String title,
    double amount,
    Color color, {
    required VoidCallback onTap,
  }) {
    final isBlue = color == const Color(0xFF0040FF);
    final formatter = NumberFormat("#,###", "en_US");
    String? textamount = formatter.format(amount);
    if (textamount == '0') textamount = null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.credit_card,
              color: isBlue ? Colors.white : const Color(0xFF0040FF),
            ),
            const SizedBox(height: 8),
            Text(
              textamount ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isBlue ? Colors.white : const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isBlue ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingItem(Spending s) {
    final category = categoryMap[s.categoryId];
    final formatter = NumberFormat("#,###", "en_US");
    if (category == null) return const SizedBox.shrink();
    final isIncome = category.type == 'income';

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            icon: Icons.delete,
            backgroundColor: Colors.red,
            spacing: 4.0,
            flex: 1,
            label: 'Xóa',
            onPressed: (ctx) => _deleteSpending(s.id),
          ),
        ],
      ),
      child: Container(
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
                category.icon ?? "❓",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF111111),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(s.date),
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                s.note ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: Text(
            "${isIncome ? '+' : '-'}\$${formatter.format(s.amount)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red[500],
            ),
          ),
          onTap: () => _navigateToEdit(s),
        ),
      ),
    );
  }

  Future<String> _getAIAdvice() async {
    try {
      final budgets = await BudgetService().getBudgets();
      final categories = categoryMap.values.toList();
      return await _geminiService.analyzeSpending(
        spendings,
        budgets,
        categories,
      );
    } catch (e) {
      return 'Không thể kết nối với AI. Vui lòng kiểm tra API key và kết nối internet.\n\nLỗi: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _loadSpendings,
              color: const Color(0xFF0040FF),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: [
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0040FF),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTopCards(),
                                const SizedBox(height: 24),
                                const Text(
                                  "Các giao dịch gần đây",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...spendings.map(_buildSpendingItem),
                                const SizedBox(height: 100),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: isLoading
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Chat button
                FloatingActionButton(
                  heroTag: null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIChatPage(),
                      ),
                    );
                  },
                  backgroundColor: Colors.purple,
                  child: const Icon(Icons.chat_bubble, color: Colors.white),
                ),
                const SizedBox(height: 10),
                // Quick analysis button
                FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AIAdviceDialog(
                        onGetAdvice: _getAIAdvice,
                        title: 'Phân tích tài chính',
                        icon: Icons.analytics,
                      ),
                    );
                  },
                  icon: const Icon(Icons.psychology),
                  label: const Text('Phân tích'),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 60),
              ],
            ),
    );
  }
}
