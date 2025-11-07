import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyboys/data/Models/budget.dart';
import 'package:moneyboys/data/Models/category.dart';
import 'package:moneyboys/data/services/budget_service.dart';
import 'package:moneyboys/data/services/category_service.dart';
import 'package:moneyboys/data/services/user_preferences.dart';

class EditBudgetPage extends StatefulWidget {
  final Budget budget;

  const EditBudgetPage({super.key, required this.budget});

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? userId;
  String _selectedType = 'expense';
  Category? _selectedCategory;
  List<Category> _categories = [];

  final _budgetService = BudgetService();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.budget.amount.toString();
    _startDate = widget.budget.startDate;
    _endDate = widget.budget.endDate;
    _loadCategoriesAndSetSelected();
  }

  Future<void> _loadCategoriesAndSetSelected() async {
    userId = await UserPreferences().getUserId();
    final result = await CategoryService().getAllCategories(userId!);

    final selectedCat = result.firstWhere(
      (c) => c.id == widget.budget.categoryId,
      orElse: () => result.first,
    );
    setState(() {
      _selectedType = selectedCat.type;
      _categories = result.where((c) => c.type == _selectedType).toList();
      _selectedCategory = _categories.firstWhere(
        (c) => c.id == selectedCat.id,
        orElse: () => _categories.first,
      );
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedCategory != null) {
      final updatedBudget = Budget(
        id: widget.budget.id,
        userId: widget.budget.userId,
        categoryId: _selectedCategory!.id,
        amount: double.parse(_amountController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        createdAt: widget.budget.createdAt,
      );
      await _budgetService.updateBudget(updatedBudget);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final primaryBlue = const Color(0xFF0040FF);

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
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

    return Center(
      child: Container(
        color: lightBlue,
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: lightBlue,
          appBar: AppBar(
            title: const Text(
              'Chỉnh sửa ngân sách',
              style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.0,
            iconTheme: const IconThemeData(color: Color(0xFF111111)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
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
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value),
                          validator: (value) =>
                              value == null ? 'Chọn danh mục' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.attach_money,
                              color: primaryBlue,
                            ),
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
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ListTile(
                          title: const Text(
                            'Ngày bắt đầu',
                            style: TextStyle(color: Color(0xFF111111)),
                          ),
                          subtitle: Text(
                            _startDate == null
                                ? 'Chưa chọn'
                                : DateFormat('dd MMM yyyy').format(_startDate!),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Icon(
                            Icons.calendar_today,
                            color: primaryBlue,
                          ),
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ListTile(
                          title: const Text(
                            'Ngày kết thúc',
                            style: TextStyle(color: Color(0xFF111111)),
                          ),
                          subtitle: Text(
                            _endDate == null
                                ? 'Chưa chọn'
                                : DateFormat('dd MMM yyyy').format(_endDate!),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Icon(
                            Icons.calendar_today,
                            color: primaryBlue,
                          ),
                          onTap: () => _pickDate(false),
                        ),
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
                            'Cập nhật',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
