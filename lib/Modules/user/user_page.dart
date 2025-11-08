import 'package:flutter/material.dart';
import 'package:moneyboys/data/mock/mock_data.dart';
//bỏ supabase, sử dụng lại thì uncomment import dưới và _loadUserInfo
//import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // final supabase = Supabase.instance.client;
    // final userInfo = await supabase
    //     .from('user')
    //     .select()
    //     .limit(1)
    //     .maybeSingle();

    // setState(() => _user = userInfo);
    final userInfo = [mockUser];
    setState(() {
      _user = userInfo.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Tên: ${_user!['name']}', style: const TextStyle(fontSize: 18)),
        Text('Email: ${_user!['email']}', style: const TextStyle(fontSize: 16)),
        // các thông tin khác nếu có
      ],
    );
  }
}
