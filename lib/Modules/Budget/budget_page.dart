import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyboys/Modules/Budget/View/add_budget_page.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'View/budget_details_page.dart';
import 'package:moneyboys/data/services/gemini_service.dart';
import 'package:moneyboys/data/services/budget_service.dart';
import 'package:moneyboys/data/services/spending_service.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/Shared/widgets/ai_assistant_widget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  List<Map<String, dynamic>> _budgetList = [];
  bool _isLoading = true;
  String? userId;
  final GeminiService _geminiService = GeminiService();

  // Date selection variables
  String _selectedPeriod = 'Tháng này';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Summary data
  double _totalBudget = 0;
  double _totalSpent = 0;
  double _remainingAmount = 0;
  int _daysLeft = 0;

  @override
  void initState() {
    super.initState();
    _initializeDateRange();
    _loadBudgets();
  }

  void _initializeDateRange() {
    final now = DateTime.now();
    // Tháng này - từ đầu tháng đến cuối tháng
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0); // Ngày cuối tháng
    _calculateDaysLeft();
  }

  void _calculateDaysLeft() {
    final now = DateTime.now();
    if (_endDate.isAfter(now)) {
      _daysLeft = _endDate.difference(now).inDays;
    } else {
      _daysLeft = 0;
    }
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
    });

    userId = await UserPreferences().getUserId();
    if (userId == null) return;

    final supabase = Supabase.instance.client;

    // Lấy danh sách budget trong khoảng thời gian được chọn
    final budgetResponse = await supabase
        .from('budget')
        .select('*')
        .eq('userid', userId!)
        .lte('start_date', _endDate.toIso8601String())
        .gte('end_date', _startDate.toIso8601String())
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> budgetWithSpending = [];
    double totalBudget = 0;
    double totalSpent = 0;

    for (final budget in budgetResponse) {
      final budgetId = budget['id'];
      final categoryId = budget['category_id'];
      final budgetAmount = (budget['amount'] as num).toDouble();
      final budgetStartDate = DateTime.parse(budget['start_date']);
      final budgetEndDate = DateTime.parse(budget['end_date']);

      // Lấy thông tin category riêng
      // Parse categoryId to int if it's stored as integer in DB
      final categoryIdParsed =
          int.tryParse(categoryId.toString()) ?? categoryId;
      final category = await supabase
          .from('category')
          .select('*')
          .eq('id', categoryIdParsed)
          .single();

      // Lấy tổng chi tiêu theo category trong khoảng thời gian của budget
      final spendingSumResponse = await supabase
          .from('spending')
          .select('amount')
          .eq('userid', userId!)
          .eq('category_id', categoryIdParsed)
          .gte('date', budgetStartDate.toIso8601String())
          .lte('date', budgetEndDate.toIso8601String());

      double spent = 0;
      for (final row in spendingSumResponse) {
        spent += (row['amount'] as num).toDouble();
      }

      budgetWithSpending.add({
        'budget_id': budgetId,
        'budget': budget,
        'category': category,
        'amount': spent,
        'start_date': budgetStartDate,
        'end_date': budgetEndDate,
      });

      totalBudget += budgetAmount;
      totalSpent += spent;
    }

    setState(() {
      _budgetList = budgetWithSpending;
      _totalBudget = totalBudget;
      _totalSpent = totalSpent;
      _remainingAmount = totalBudget - totalSpent;
      _isLoading = false;
    });
  }

  Future<void> _showDateRangePicker() async {
    final primaryBlue = const Color(0xFF0040FF);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF111111),
            ),
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    color: Colors.black12,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 430, // giống kích thước điện thoại
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod =
            '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}';
      });
      _calculateDaysLeft();
      _loadBudgets();
    }
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
      _selectedPeriod = 'Tháng này';
    });
    _calculateDaysLeft();
    _loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,##0", "vi_VN");
    final primaryBlue = const Color(0xFF0040FF);
    final lightBlue = Colors.grey[100];

    return Scaffold(
      backgroundColor: lightBlue,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : Column(
              children: [
                // Period Selector
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildPeriodTab(
                        'Tháng này',
                        _selectedPeriod == 'Tháng này',
                        _selectThisMonth,
                        primaryBlue,
                      ),
                      const SizedBox(width: 20),
                      _buildPeriodTab(
                        _selectedPeriod == 'Tháng này'
                            ? '${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}'
                            : _selectedPeriod,
                        _selectedPeriod != 'Tháng này',
                        _showDateRangePicker,
                        primaryBlue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main Budget Circle
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      // Budget Circle
                      Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 8,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Progress Circle
                            if (_totalBudget > 0)
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: CircularProgressIndicator(
                                  value: _totalSpent / _totalBudget,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.transparent,
                                  color: primaryBlue,
                                ),
                              ),
                            // Center Content
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Còn lại',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyFormatter.format(
                                    _remainingAmount.abs(),
                                  ),
                                  style: TextStyle(
                                    color: _remainingAmount >= 0
                                        ? primaryBlue
                                        : Colors.redAccent,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_remainingAmount < 0)
                                  const Text(
                                    'Vượt ngân sách',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            currencyFormatter.format(_totalBudget),
                            'Tổng ngân sách',
                            primaryBlue,
                          ),
                          _buildStatItem(
                            currencyFormatter.format(_totalSpent),
                            'Đã chi tiêu',
                            Colors.redAccent,
                          ),
                          _buildStatItem(
                            '$_daysLeft ngày',
                            'Còn lại',
                            Colors.grey[700]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Budget List Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ), // dùng padding nhỏ hơn để tránh tràn
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Danh sách ngân sách',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF111111),
                          ),
                          overflow: TextOverflow
                              .ellipsis, // nếu tiêu đề quá dài thì sẽ bị cắt
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddBudgetPage(),
                            ),
                          );
                          if (result == true) {
                            _loadBudgets();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primaryBlue,
                          padding: EdgeInsets.zero, // loại bỏ padding dư
                          minimumSize: Size(0, 0), // tránh chiếm diện tích lớn
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 16, color: primaryBlue),
                            const SizedBox(width: 4),
                            Text(
                              'Thêm ngân sách',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Budget Items List
                Expanded(
                  child: _budgetList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Không có ngân sách nào trong khoảng thời gian này',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddBudgetPage(),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadBudgets();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Tạo ngân sách',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _budgetList.length,
                          itemBuilder: (context, index) {
                            final item = _budgetList[index];
                            return _buildBudgetItem(
                              item,
                              currencyFormatter,
                              primaryBlue,
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton.extended(
                heroTag: 'budget_advice',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AIAdviceDialog(
                      onGetAdvice: _getBudgetAIAdvice,
                      title: 'Tư vấn ngân sách',
                      icon: Icons.account_balance_wallet,
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

  Widget _buildPeriodTab(
    String text,
    bool isSelected,
    VoidCallback onTap,
    Color primaryColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF111111) : Colors.grey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            if (isSelected)
              Container(height: 2, width: 40, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBudgetItem(
    Map<String, dynamic> item,
    NumberFormat formatter,
    Color primaryColor,
  ) {
    String id = item['budget_id'].toString();
    final budget = item['budget'];
    final category = item['category'];
    final spent = item['amount'] as double;
    final startDate = item['start_date'] as DateTime;
    final endDate = item['end_date'] as DateTime;
    final amount = (budget['amount'] as num).toDouble();
    final remaining = amount - spent;
    final progress = amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;

    // Calculate days left for this specific budget
    final now = DateTime.now();
    final daysLeftForBudget = endDate.isAfter(now)
        ? endDate.difference(now).inDays
        : 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BudgetDetailsPage(budgetId: id),
          ),
        );
        _loadBudgets(); // Refresh when returning from details
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        category['icon'] ?? '📁',
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
                          category['name'],
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã chi: ${formatter.format(spent)} ₫',
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  Text(
                    'Ngân sách: ${formatter.format(amount)} ₫',
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: progress >= 0.9 ? Colors.redAccent : primaryColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$daysLeftForBudget ngày còn lại',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Còn lại: ${formatter.format(remaining.abs())} ₫',
                    style: TextStyle(
                      color: remaining >= 0 ? primaryColor : Colors.redAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getBudgetAIAdvice() async {
    try {
      final budgets = await BudgetService().getBudgets();
      final spendings = await SpendingService().getSpendings(userId!);
      final categories = await CategoryService().getAllCategories(userId!);

      return await _geminiService.analyzeSpending(
        spendings,
        budgets,
        categories,
      );
    } catch (e) {
      return 'Không thể kết nối với AI. Vui lòng kiểm tra API key và kết nối internet.\n\nLỗi: ${e.toString()}';
    }
  }
}
