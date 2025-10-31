import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/format.dart';
import '../expenses/spending_list_page.dart';
import '../budget/budget_page.dart';
import '../stats/spending_chart_page.dart';
import '../settings/setting_page.dart';

class CommonPage extends StatefulWidget {
  const CommonPage({super.key});
  @override
  State<CommonPage> createState() => _CommonPageState();
}

class _CommonPageState extends State<CommonPage> {
  final _bucket = PageStorageBucket();
  int _current = 0;

  static const _titles = [
    'Danh sách chi tiêu',
    'Ngân sách',
    'Thống kê',
    'Cài đặt',
  ];

  final _pages = const [
    SpendingListPage(key: PageStorageKey('spend_list')),
    BudgetPage(key: PageStorageKey('budget')),
    SpendingChartPage(key: PageStorageKey('stats')),
    SettingPage(key: PageStorageKey('settings')),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: Text(_titles[_current]),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surface, cs.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: PageStorage(
          bucket: _bucket,
          child: IndexedStack(index: _current, children: _pages),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
        child: const Icon(CupertinoIcons.add, size: 28),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildTabItem(0, Icons.list_alt_outlined, Icons.list_alt),
              _buildTabItem(
                1,
                Icons.account_balance_wallet_outlined,
                Icons.account_balance_wallet,
              ),
              const SizedBox(width: 56), // chừa chỗ cho FAB
              _buildTabItem(2, Icons.bar_chart_outlined, Icons.bar_chart),
              _buildTabItem(3, Icons.settings_outlined, Icons.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, IconData selectedIcon) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _current == index;
    final color = isSelected ? cs.primary : Colors.grey;

    return Expanded(
      child: InkResponse(
        onTap: () => setState(() => _current = index),
        radius: 28,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: color),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddPressed() {
    // TODO: mở bottom sheet thêm chi tiêu (gắn backend sau)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('TODO: Thêm chi tiêu')));
  }
}
