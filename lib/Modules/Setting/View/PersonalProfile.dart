import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyboys/Modules/Setting/widget/Custom_Manager.dart';
import 'package:moneyboys/app/route.dart';
import 'package:moneyboys/data/Models/user.dart';

import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/user_service.dart';

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage({super.key});

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  String? userId;
  UserModel? user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _createdAtController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    userId = await UserPreferences().getUserId();
    user = await UserService().getUserById(userId!);

    if (user != null) {
      setState(() {
        _nameController.text = user!.name ?? '';
        _emailController.text = user!.email;
        _createdAtController.text = DateFormat(
          'dd/MM/yyyy HH:mm:ss',
        ).format(user!.createdAt.toLocal());
      });
    }
  }

  void _saveChanges() {
    final updatedName = _nameController.text.trim();
    if (updatedName.isEmpty) {
      _showMessage("Vui lòng nhập tên người dùng");
      return;
    }

    UserService().updateUser(
      UserModel(
        id: user!.id,
        email: user!.email,
        passwordHash: user!.passwordHash,
        name: updatedName,
        createdAt: user!.createdAt,
      ),
    );

    _showMessage("Cập nhật thành công", success: true);
  }

  void _showMessage(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) {
                final commonState = context
                    .findAncestorStateOfType<RoutesState>();
                if (commonState != null) {
                  commonState.setState(() {
                    commonState.subPage = null;
                  });
                }
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTile(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          label: Text(label),
          hintText: 'Nhập $label',
          hintStyle: const TextStyle(color: Colors.black26),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldGroup() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        children: [
          _buildFieldTile('Tên người dùng', _nameController),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildFieldTile('Email', _emailController, readOnly: true),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildFieldTile(
            'Ngày tạo tài khoản',
            _createdAtController,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0E33F3), Color(0xFF2FDAFF)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldManager(
      title: 'Hồ sơ cá nhân',
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldGroup(),
                const SizedBox(height: 24),
                _buildActionTile(
                  title: 'Lưu thay đổi',
                  color: const Color.fromARGB(255, 255, 255, 255),
                  onTap: _saveChanges,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
