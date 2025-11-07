import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:moneyboys/Modules/Setting/widget/Custom_Manager.dart';
import 'package:moneyboys/app/route.dart';
import 'package:moneyboys/data/Models/user.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/user_service.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<Changepassword> {
  String? userId;
  UserModel? user;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  static const BoxDecoration boxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4)),
    ],
    border: Border.fromBorderSide(
      BorderSide(color: Color(0xFFE0E0E0), width: 1),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    userId = await UserPreferences().getUserId();
    user = await UserService().getUserById(userId!);

    final email = user?.email;
    if (email != null) {
      setState(() {
        _emailController.text = email;
      });
    }
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _changePassword() {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Vui lòng nhập đầy đủ thông tin");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("Mật khẩu xác nhận không trùng khớp");
      return;
    }

    if (hashPassword(oldPassword) != user!.passwordHash) {
      _showMessage("Mật khẩu không chính xác");
      return;
    }

    final passwordHash = hashPassword(newPassword);

    UserService().updateUser(
      UserModel(
        id: user!.id,
        email: user!.email,
        passwordHash: passwordHash,
        name: user!.name,
        createdAt: user!.createdAt,
      ),
    );

    _showMessage("Đổi mật khẩu thành công", success: true);
  }

  void _showMessage(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // đóng dialog

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

  Widget _buildFieldGroup() {
    return Container(
      decoration: boxDecoration,
      child: Column(
        children: [
          _buildFieldTile('Email', _emailController, false, readOnly: true),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildFieldTile('Mật khẩu cũ', _oldPasswordController, true),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildFieldTile('Mật khẩu mới', _newPasswordController, true),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildFieldTile(
            'Xác nhận mật khẩu',
            _confirmPasswordController,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTile(
    String label,
    TextEditingController controller,
    bool obscure, {
    bool readOnly = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: TextField(
        controller: controller,
        obscureText: obscure,
        readOnly: readOnly,
        decoration: InputDecoration(hintText: label, border: InputBorder.none),
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
      title: 'Đổi mật khẩu',
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
                  onTap: () {
                    _changePassword();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
