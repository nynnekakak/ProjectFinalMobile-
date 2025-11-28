import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:moneyboys/Modules/Setting/View/PersonalProfile.dart';
import 'package:moneyboys/Modules/Setting/widget/Custom_Manager.dart';
import 'package:moneyboys/Modules/SignIn/View/Signin_screen.dart';
import 'package:moneyboys/app/route.dart';
import 'package:moneyboys/data/Models/user.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/user_service.dart';

import 'ChangePassword.dart';

class AccountManager extends StatefulWidget {
  const AccountManager({super.key});

  @override
  State<AccountManager> createState() => _AccountManagerState();
}

class _AccountManagerState extends State<AccountManager> {
  String? userId;
  UserModel? user;
  static const BoxDecoration commonBoxDecoration = BoxDecoration(
    color: Color.fromARGB(255, 255, 255, 255),
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(color: Color(0x11000000), blurRadius: 8, offset: Offset(0, 4)),
    ],
    border: Border.fromBorderSide(
      BorderSide(
        color: Color(0xFFE0E0E0), // màu viền xám rất nhạt
        width: 1,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    userId = await UserPreferences().getUserId();
    if (userId == null) return;

    final fetchedUser = await UserService().getUserById(userId!);
    if (fetchedUser == null) return;

    setState(() {
      user = fetchedUser;
    });
  }

  Widget build(BuildContext context) {
    return CustomScaffoldManager(
      title: 'Quản lý tài khoản',
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 10.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                const SizedBox(height: 28),
                _buildActionTile(
                  title: 'Thay đổi mật khẩu',
                  color: Colors.blueAccent,
                  onTap: () {
                    final commonState = context
                        .findAncestorStateOfType<RoutesState>();
                    commonState?.setState(() {
                      commonState.previousSubPage = commonState.subPage;
                      commonState.subPage = const Changepassword();
                    });
                  },
                ),
                const SizedBox(height: 28),
                _buildActionTile(
                  title: 'Đăng xuất',
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  onTap: () async {
                    await UserPreferences().removeUserId(); // Xóa userId đã lưu
                    // final commonState =
                    //     context.findAncestorStateOfType<CommonPageState>();
                    // commonState?.setState(() {
                    //   commonState.subPage =
                    //       const SignInScreen(); // Chuyển về trang đăng nhập
                    // });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                _buildActionTile(
                  title: 'Xóa tài khoản',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận'),
                        content: const Text(
                          'Bạn có chắc muốn xóa tài khoản không?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Không'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Có'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && userId != null) {
                      UserService().deleteUser(userId!);

                      await UserPreferences().removeUserId(); // Xóa local
                      final commonState = context
                          .findAncestorStateOfType<RoutesState>();
                      commonState?.setState(() {
                        commonState.subPage =
                            const SignInScreen(); // Quay về đăng nhập
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Xóa tài khoản thất bại')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: commonBoxDecoration,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(),
                const SizedBox(height: 12),
                Text(
                  user!.name ?? '',
                  style: TextStyle(color: Colors.black87, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  user!.email,
                  style: TextStyle(color: Colors.black45, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Brand(Brands.google, size: 22),
                const SizedBox(height: 12),
              ],
            ),
          ),
          const Divider(color: Color(0xFFDADADA)),
          _buildActionTile(
            title: 'Hồ sơ cá nhân',
            color: Colors.blueAccent,
            onTap: () {
              final commonState = context
                  .findAncestorStateOfType<RoutesState>();
              commonState?.setState(() {
                commonState.previousSubPage = commonState.subPage;
                commonState.subPage = const PersonalProfilePage();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        const CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xFF42A5F5),
          child: Text("L", style: TextStyle(fontSize: 32, color: Colors.white)),
        ),
        Positioned(
          bottom: -12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified, color: Colors.blueAccent, size: 14),
                SizedBox(width: 6),
                Text(
                  'Tài khoản của tôi',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    required VoidCallback onTap,
  }) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      decoration: commonBoxDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        dense: true,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: fontWeight,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
