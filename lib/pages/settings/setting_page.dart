import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Hồ sơ cá nhân'),
          onTap: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('TODO: Hồ sơ cá nhân'))),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Đổi mật khẩu'),
          onTap: () => ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('TODO: Đổi mật khẩu'))),
        ),
        const Divider(),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () {
            // TODO: Đăng xuất + điều hướng về màn SignIn
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('TODO: Đăng xuất')));
          },
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
