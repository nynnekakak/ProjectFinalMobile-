import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyboys/data/Models/budget.dart';
import 'package:moneyboys/data/Models/category.dart';
import 'package:moneyboys/data/services/budget_service.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:uuid/uuid.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({super.key});

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? userId;
  final String _selectedType = 'expense';
  Category? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  final _budgetService = BudgetService();
  final _uuid = const Uuid().v4();

  Future<void> _loadCategories() async {
    userId = await UserPreferences().getUserId();
    final result = await CategoryService().getAllCategories(userId!);
    setState(() {
      _categories = result.where((c) => c.type == _selectedType).toList();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedCategory != null) {
      final userId = await UserPreferences().getUserId();
      final budget = Budget(
        id: _uuid,
        userId: userId!,
        categoryId: _selectedCategory!.id,
        amount: double.parse(_amountController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        createdAt: DateTime.now(),
      );
      await _budgetService.addBudget(budget);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final primaryBlue = const Color(0xFF0040FF);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightBlue = Colors.grey[100];
    final primaryBlue = const Color(0xFF0040FF);

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text(
          'Thêm ngân sách',
          style: TextStyle(
            color: Color(0xFF111111),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCategoryDropdown(primaryBlue),
                              const SizedBox(height: 16),
                              _buildAmountField(primaryBlue),
                              const SizedBox(height: 16),
                              _buildDatePicker(
                                'Ngày bắt đầu',
                                _startDate,
                                () => _pickDate(true),
                                primaryBlue,
                              ),
                              const SizedBox(height: 16),
                              _buildDatePicker(
                                'Ngày kết thúc',
                                _endDate,
                                () => _pickDate(false),
                                primaryBlue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 1,
                              ),
                              child: const Text(
                                'Lưu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown(Color primaryBlue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<Category>(
        value: _selectedCategory,
        decoration: const InputDecoration(
          labelText: 'Danh mục',
          labelStyle: TextStyle(color: Color(0xFF111111)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: Icon(Icons.arrow_drop_down, color: primaryBlue),
        dropdownColor: Colors.white,
        items: _categories.map((category) {
          return DropdownMenuItem<Category>(
            value: category,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      category.icon ?? '📁',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value),
        validator: (value) => value == null ? 'Chọn danh mục' : null,
      ),
    );
  }

  Widget _buildAmountField(Color primaryBlue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Color(0xFF111111)),
        decoration: InputDecoration(
          labelText: 'Số tiền',
          labelStyle: TextStyle(color: primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(Icons.attach_money, color: primaryBlue),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Nhập số tiền';
          }
          final number = double.tryParse(value);
          if (number == null) {
            return 'Số tiền không hợp lệ';
          }
          if (number <= 0) {
            return 'Số tiền phải lớn hơn 0';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(
    String title,
    DateTime? date,
    VoidCallback onTap,
    Color primaryBlue,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Color(0xFF111111))),
        subtitle: Text(
          date == null ? 'Chưa chọn' : DateFormat('dd MMM yyyy').format(date),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.calendar_today, color: primaryBlue),
        onTap: onTap,
      ),
    );
  }
}
