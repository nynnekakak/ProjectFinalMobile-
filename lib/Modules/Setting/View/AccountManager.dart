import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:moneyboys/Modules/Setting/Cubit/account_cubit.dart';
import 'package:moneyboys/Modules/Setting/Cubit/account_state.dart';
import 'package:moneyboys/Modules/Setting/View/PersonalProfile.dart';
import 'package:moneyboys/Modules/Setting/widget/Custom_Manager.dart';
import 'package:moneyboys/Modules/SignIn/View/Signin_screen.dart';
import 'package:moneyboys/app/route.dart';
import 'package:moneyboys/data/Models/user.dart';

import 'ChangePassword.dart';

class AccountManager extends StatelessWidget {
  const AccountManager({super.key});

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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountCubit()..loadUser(),
      child: const AccountManagerView(),
    );
  }
}

class AccountManagerView extends StatelessWidget {
  const AccountManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is AccountLoggedOut) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        } else if (state is AccountDeleted) {
          final commonState = context.findAncestorStateOfType<RoutesState>();
          commonState?.setState(() {
            commonState.subPage = const SignInScreen();
          });
        } else if (state is AccountError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: CustomScaffoldManager(
        title: 'Quản lý tài khoản',
        child: SafeArea(
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, state) {
              if (state is AccountLoading || state is AccountInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AccountError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AccountCubit>().loadUser();
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (state is! AccountLoaded) {
                return const Center(child: Text('Không có dữ liệu'));
              }

              final user = state.user;

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.fromLTRB(8.0, 32.0, 8.0, 10.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(context, user),
                      const SizedBox(height: 28),
                      _buildActionTile(
                        context: context,
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
                        context: context,
                        title: 'Đăng xuất',
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        onTap: () {
                          context.read<AccountCubit>().logout();
                        },
                      ),
                      const SizedBox(height: 28),
                      _buildActionTile(
                        context: context,
                        title: 'Xóa tài khoản',
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        onTap: () => _showDeleteConfirmation(context),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Có'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AccountCubit>().deleteAccount();
    }
  }

  Widget _buildProfileSection(BuildContext context, UserModel user) {
    return Container(
      decoration: AccountManager.commonBoxDecoration,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(user),
                const SizedBox(height: 12),
                Text(
                  user.name ?? '',
                  style: const TextStyle(color: Colors.black87, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.black45, fontSize: 14),
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

  Widget _buildAvatar(UserModel user) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: const Color(0xFF42A5F5),
          child: Text(
            user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : "U",
            style: const TextStyle(fontSize: 32, color: Colors.white),
          ),
        ),
        Positioned(
          bottom: -12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
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
