import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  // Dữ liệu demo (hiển thị giao diện thôi)
  final List<Map<String, dynamic>> spendings = [
    {
      'icon': '🍔',
      'name': 'Ăn uống',
      'date': DateTime.now(),
      'note': 'Bữa trưa',
      'amount': 50000,
      'isIncome': false
    },
    {
      'icon': '💼',
      'name': 'Lương',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'note': 'Lương tháng 11',
      'amount': 10000000,
      'isIncome': true
    },
  ];

  Widget _buildTopCards() {
    double totalIncome = 10000000;
    double totalExpense = 50000;

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
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard2(
                double.infinity,
                90,
                "Tổng chi tiêu",
                const Color(0xFF0040FF),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard2(
      double width, double height, String title, Color color,
      {required VoidCallback onTap}) {
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
            Icon(Icons.credit_card,
                color: isBlue ? Colors.white : const Color(0xFF0040FF)),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: isBlue ? Colors.white70 : Colors.grey[600]))
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      double width, double height, String title, double amount, Color color,
      {required VoidCallback onTap}) {
    final isBlue = color == const Color(0xFF0040FF);
    final formatter = NumberFormat("#,###", "en_US");
    final textAmount = formatter.format(amount);
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
            Icon(Icons.credit_card,
                color: isBlue ? Colors.white : const Color(0xFF0040FF)),
            const SizedBox(height: 8),
            Text(
              textAmount,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isBlue ? Colors.white : const Color(0xFF111111)),
            ),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    color: isBlue ? Colors.white70 : Colors.grey[600]))
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingItem(Map<String, dynamic> s) {
    final formatter = NumberFormat("#,###", "en_US");
    final isIncome = s['isIncome'] as bool;
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            icon: Icons.delete,
            backgroundColor: Colors.red,
            label: 'Xóa',
            onPressed: (ctx) {},
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
                s['icon'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            s['name'],
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF111111)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd MMM yyyy').format(s['date']),
                  style: TextStyle(color: Colors.grey[600])),
              Text(s['note'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]))
            ],
          ),
          trailing: Text(
            "${isIncome ? '+' : '-'}\$${formatter.format(s['amount'])}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red[500]),
          ),
          onTap: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                    color: Color(0xFF111111)),
                              ),
                              const SizedBox(height: 12),
                              ...spendings.map(_buildSpendingItem),
                              const SizedBox(height: 100),
                            ],
                          ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
