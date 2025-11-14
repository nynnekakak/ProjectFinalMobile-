import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../data/Models/category.dart';
import '../../data/Models/spending.dart';
import '../../data/services/category_service.dart';
import '../../data/services/spending_service.dart';
import '../../data/services/user_preferences.dart';

class AddSpendingPage extends StatefulWidget {
  const AddSpendingPage({super.key});

  @override
  State<AddSpendingPage> createState() => _AddSpendingPageState();
}

class _AddSpendingPageState extends State<AddSpendingPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  Category? _selectedCategory;
  List<Category> _categories = [];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    userId = await UserPreferences().getUserId();
    final result = await CategoryService().getAllCategories(userId!);
    setState(() {
      _categories = result.where((c) => c.type == _selectedType).toList();
    });
  }

  void _onTypeChanged(String type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = null;
      _loadCategories();
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    userId = await UserPreferences().getUserId();
    if (userId == null) return;

    final cleanAmount = _amountController.text.replaceAll('.', '');
    final newSpending = Spending(
      id: '',
      userId: userId!,
      categoryId: _selectedCategory!.id,
      amount: double.parse(cleanAmount),
      note: _noteController.text,
      date: _selectedDate,
      createdAt: DateTime.now(),
    );

    await SpendingService().addSpending(newSpending);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final lightBlue = Colors.grey[100];
    final primaryBlue = const Color(0xFF0040FF);

    return Scaffold(
      backgroundColor: lightBlue,
      appBar: AppBar(
        title: const Text(
          'Thêm giao dịch',
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
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ToggleButton(
                        label: 'Chi',
                        selected: _selectedType == 'expense',
                        onTap: () => _onTypeChanged('expense'),
                        primaryColor: primaryBlue,
                      ),
                      const SizedBox(width: 12),
                      ToggleButton(
                        label: 'Thu',
                        selected: _selectedType == 'income',
                        onTap: () => _onTypeChanged('income'),
                        primaryColor: primaryBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildDropdownField(primaryBlue),
                        const SizedBox(height: 16),
                        buildAmountField(primaryBlue),
                        const SizedBox(height: 16),
                        buildNoteField(primaryBlue),
                        const SizedBox(height: 16),
                        buildDatePicker(primaryBlue),
                        const SizedBox(height: 24),
                        buildSubmitButton(primaryBlue),
                      ],
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

  Widget buildDropdownField(Color primaryBlue) {
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

  Widget buildAmountField(Color primaryBlue) {
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _ThousandsSeparatorInputFormatter(),
        ],
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
          final cleanValue = value.replaceAll('.', '');
          final number = double.tryParse(cleanValue);
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

  Widget buildNoteField(Color primaryBlue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _noteController,
        style: const TextStyle(color: Color(0xFF111111)),
        decoration: InputDecoration(
          labelText: 'Ghi chú',
          labelStyle: TextStyle(color: primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(Icons.note, color: primaryBlue),
        ),
      ),
    );
  }

  Widget buildDatePicker(Color primaryBlue) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        title: const Text('Ngày', style: TextStyle(color: Color(0xFF111111))),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(_selectedDate),
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.calendar_today, color: primaryBlue),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
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
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        },
      ),
    );
  }

  Widget buildSubmitButton(Color primaryBlue) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,###', 'vi_VN');
    final newText = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;

  const ToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor),
          boxShadow: selected
              ? [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 6)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
