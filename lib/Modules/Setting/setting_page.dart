import 'package:flutter/material.dart';
import 'package:moneyboys/data/models/user.dart';
import 'package:moneyboys/data/services/user_preferences.dart';
import 'package:moneyboys/data/services/user_service.dart';
import 'package:moneyboys/Modules/Setting/View/list_category_page.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:moneyboys/app/route.dart';
import 'View/AccountManager.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  String? userId;
  UserModel? user;
  static const BoxDecoration commonBoxDecoration = BoxDecoration(
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
    _loadUser();
  }

  Future<void> _loadUser() async {
    userId = await UserPreferences().getUserId();
    if (userId == null) return;

    final fetchedUser = await UserService().getUserById(userId!);
    if (fetchedUser == null) return;

    setState(() {
      user = fetchedUser as UserModel?;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileSection(),
                const SizedBox(height: 24),
                _buildMenuSection([
                  _buildListTile(
                    icon: Icons.category,
                    title: 'Quản lý danh mục',
                    onTap: () {
                      final commonState = context
                          .findAncestorStateOfType<RoutesState>();
                      commonState?.setState(() {
                        commonState.previousSubPage = null;
                        commonState.subPage = const ListCategoryPage();
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 32),
                const Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 60),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      child: Column(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 30, // nhỏ hơn
                      backgroundColor: const Color(
                        0xFF42A5F5,
                      ), // màu xanh tươi hơn
                      child: Text(
                        user!.name!
                            .split(' ')
                            .map((e) => e[0])
                            .join()[0]
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.verified,
                              color: Colors.blueAccent,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tài khoản của tôi',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user!.name ?? '',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user!.email,
                  style: const TextStyle(color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 10),
                const Icon(EvaIcons.google, size: 20, color: Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFDADADA)),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            leading: const Icon(
              Icons.account_circle,
              color: Colors.black87,
              size: 20,
            ),
            title: const Text(
              'Quản lý tài khoản',
              style: TextStyle(color: Colors.black87, fontSize: 13),
            ),
            subtitle: const Text(
              'Tài khoản miễn phí',
              style: TextStyle(color: Colors.black54, fontSize: 10),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 12,
            ),
            onTap: () {
              final commonState = context
                  .findAncestorStateOfType<RoutesState>();
              commonState?.setState(() {
                commonState.previousSubPage = null;
                commonState.subPage = const AccountManager();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(List<Widget> children) {
    return Container(
      decoration: commonBoxDecoration,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i != 0) const Divider(color: Color(0xFFDADADA)),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      dense: true,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      leading: Icon(icon, color: Colors.black87, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 12,
      ),
      onTap: onTap,
    );
  }
}
