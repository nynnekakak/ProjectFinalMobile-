import 'package:flutter/material.dart';
import 'package:moneyboys/Modules/Setting/View/list_category_page.dart';
import 'package:moneyboys/app/route.dart';
import 'package:moneyboys/data/Models/category.dart';

import 'package:uuid/uuid.dart';

import '../../../data/services/category_service.dart';
import '../../../data/services/user_preferences.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();

  final Map<String, String> iconMap = {
    '🛒': 'Mua sắm',
    '🍔': 'Ăn uống',
    '🚗': 'Di chuyển',
    '🎁': 'Quà tặng',
    '📚': 'Học tập',
    '💡': 'Tiện ích',
    '🎮': 'Giải trí',
    '💰': 'Tiền lương',
    '🏠': 'Nhà cửa',
    '🎵': 'Âm nhạc',
    '🧾': 'Hóa đơn',
    '🧘‍♂️': 'Sức khỏe',
    '💻': 'Công nghệ',
    '👕': 'Quần áo',
    '✈️': 'Du lịch',
    '🎬': 'Phim ảnh',
    '☕': 'Cà phê',
    '🍹': 'Đồ uống',
    '🍕': 'Đồ ăn nhanh',
    '🛍️': 'Mua sắm',
    '📱': 'Điện thoại',
    '🚿': 'Tiện ích',
    '🧴': 'Mỹ phẩm',
    '🥗': 'Đồ ăn lành mạnh',
    '🚕': 'Taxi',
    '🚌': 'Xe buýt',
    '🏛️': 'Ngân hàng',
    '💳': 'Thẻ tín dụng',
    '📝': 'Học phí',
    '🏥': 'Y tế',
    '💊': 'Thuốc',
    '🎓': 'Giáo dục',
    '🏪': 'Cửa hàng',
    '🎪': 'Sự kiện',
    '🎭': 'Giải trí',
    '📷': 'Nhiếp ảnh',
    '🏋️‍♀️': 'Thể thao',
    '📺': 'Truyền hình',
    '📶': 'Internet',
    '📞': 'Điện thoại',
    '💼': 'Công việc',
    '👶': 'Trẻ em',
    '🧸': 'Đồ chơi',
    '🎨': 'Nghệ thuật',
    '🥊': 'Thể thao',
    '🚲': 'Xe đạp',
    '🧢': 'Phụ kiện',
    '🧹': 'Vệ sinh',
    '🧺': 'Giặt ủi',
  };

  String _selectedIcon = '';
  String _type = 'expense';
  bool _isSaving = false;

  final _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _selectedIcon = iconMap.keys.first;
    _iconController.text = _selectedIcon;
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final uuid = const Uuid().v4();
    final userId = await UserPreferences().getUserId();

    Category newCategory = Category(
      id: uuid,
      name: _nameController.text,
      type: _type,
      icon: _iconController.text,
      color: '#6BCB77',
      isShared: false,
      userId: userId,
      createdAt: DateTime.now(),
    );

    try {
      _categoryService.addCategory(newCategory);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thêm danh mục thành công')));
      final commonState = context.findAncestorStateOfType<RoutesState>();
      if (commonState != null) {
        commonState.setState(() {
          if (commonState.previousSubPage != null) {
            commonState.subPage = commonState.previousSubPage;
            commonState.previousSubPage = null;
          } else {
            commonState.subPage = ListCategoryPage();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm danh mục: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showIconSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chọn Icon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: iconMap.length,
                itemBuilder: (context, index) {
                  final icon = iconMap.keys.elementAt(index);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                        _iconController.text = icon;
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon
                            ? const Color(0xFF0040FF)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: TextStyle(
                            fontSize: 28,
                            color: _selectedIcon == icon
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF0040FF);
    final lightBlue = Colors.grey[100];

    return Center(
      child: Container(
        color: lightBlue,
        constraints: const BoxConstraints(maxWidth: 430),
        child: Scaffold(
          backgroundColor: lightBlue,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                final commonState = context
                    .findAncestorStateOfType<RoutesState>();
                if (commonState != null) {
                  commonState.setState(() {
                    if (commonState.previousSubPage != null) {
                      commonState.subPage = commonState.previousSubPage;
                      commonState.previousSubPage = null;
                    } else {
                      commonState.subPage = ListCategoryPage();
                    }
                  });
                }
              },
            ),
            title: const Text(
              'Thêm danh mục',
              style: TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Color(0xFF111111)),
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'Tên danh mục',
                      prefixIcon: Icons.label_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Không được để trống'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Loại danh mục',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    _buildTypeToggle(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Chọn Icon',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: _showIconSelector,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedIcon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Spacer(),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
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
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: Color(0xFF111111)),
          decoration: InputDecoration(
            hintText: 'Nhập $label',
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0040FF)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    final primaryBlue = const Color(0xFF0040FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['expense', 'income'].map((type) {
          final isSelected = _type == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _type = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    type == 'expense' ? 'Chi tiêu' : 'Thu nhập',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF111111),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
