import 'package:flutter/material.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:intl/intl.dart';

import '../../data/Models/category.dart';
import '../../data/Models/spending.dart';
import '../../data/services/category_service.dart';
import '../../data/services/spending_service.dart';

class EditSpendingPage extends StatefulWidget {
  final Spending spending;

  const EditSpendingPage({required this.spending, super.key});

  @override
  State<EditSpendingPage> createState() => _EditSpendingPageState();
}

class _EditSpendingPageState extends State<EditSpendingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  String? _selectedCategoryId;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.spending.amount.toString(),
    );
    _noteController = TextEditingController(text: widget.spending.note ?? '');
    _selectedDate = widget.spending.date;
    _selectedCategoryId = widget.spending.categoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final userId = await UserPreferences().getUserId();
    final all = await CategoryService().getAllCategories(userId!);
    final selected = all.firstWhere(
      (c) => c.id == widget.spending.categoryId,
      orElse: () => all.first,
    );
    setState(() {
      _categories = all;
      _selectedType = selected.type;
    });
  }

  Future<void> _saveSpending() async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      final updated = Spending(
        id: widget.spending.id,
        userId: widget.spending.userId,
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text),
        note: _noteController.text,
        date: _selectedDate,
        createdAt: widget.spending.createdAt,
      );
      await SpendingService().updateSpending(updated);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((c) => c.type == _selectedType).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa khoản chi',
          style: TextStyle(color: Color(0xFF111111)),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF111111)),
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: ToggleButtons(
                        isSelected: [
                          _selectedType == 'income',
                          _selectedType == 'expense',
                        ],
                        onPressed: (i) {
                          setState(() {
                            _selectedType = i == 0 ? 'income' : 'expense';
                            _selectedCategoryId = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        selectedColor: Colors.white,
                        fillColor: const Color(0xFF0040FF),
                        color: Colors.grey[700],
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Thu'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Chi'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildDropdown(filtered),
                    const SizedBox(height: 16),
                    buildAmountField(),
                    const SizedBox(height: 16),
                    buildNoteField(),
                    const SizedBox(height: 16),
                    buildDateField(),
                    const SizedBox(height: 24),
                    buildSaveButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDropdown(List<Category> filtered) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: DropdownButtonFormField<String>(
          value: filtered.any((c) => c.id == _selectedCategoryId)
              ? _selectedCategoryId
              : null,
          hint: const Text('Chọn danh mục'),
          decoration: const InputDecoration(border: InputBorder.none),
          items: filtered.map((c) {
            return DropdownMenuItem(
              value: c.id,
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
                        c.icon ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    c.name,
                    style: const TextStyle(color: Color(0xFF111111)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedCategoryId = v),
          validator: (v) => v == null || v.isEmpty ? 'Chọn danh mục' : null,
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildAmountField() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Số tiền',
          labelStyle: TextStyle(color: Color(0xFF0040FF)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(Icons.attach_money, color: Color(0xFF0040FF)),
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

  Widget buildNoteField() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: _noteController,
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Ghi chú',
          labelStyle: TextStyle(color: Color(0xFF0040FF)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: Icon(Icons.note, color: Color(0xFF0040FF)),
        ),
      ),
    );
  }

  Widget buildDateField() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        title: Text(
          'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
          style: const TextStyle(color: Color(0xFF111111)),
        ),
        trailing: const Icon(Icons.calendar_today, color: Color(0xFF0040FF)),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF0040FF),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) setState(() => _selectedDate = picked);
        },
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _saveSpending,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0040FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Lưu chỉnh sửa',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
