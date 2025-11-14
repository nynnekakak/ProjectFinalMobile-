import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:moneyboys/Modules/Budget/budget_page.dart';
import 'package:moneyboys/Modules/Home/home_Screen.dart';
import 'package:moneyboys/Modules/Setting/setting_page.dart';
import 'package:moneyboys/Modules/expense/add_spending_page.dart';
import 'package:moneyboys/Modules/monitor/spending_chart_page.dart';

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => RoutesState();
}

class RoutesState extends State<Routes> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    BudgetScreen(),
    SpendingChartPage(),
    SettingPage(),
  ];

  Widget? subPage;
  Widget? previousSubPage;

  final List<String> _titles = [
    'Danh sách chi tiêu',
    'Ngân sách',
    'Thống kê',
    'Cài đặt',
  ];

  void _onTabTapped(int index) {
    setState(() {
      subPage = null;
      previousSubPage = null;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: _currentIndex == 3
          ? null
          : AppBar(
              title: Text(
                _titles[_currentIndex],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              backgroundColor: const Color.fromARGB(255, 62, 54, 226),
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F1FA), Color(0xFFF6FBFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 430),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: subPage ?? _pages[_currentIndex],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, 10),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddSpendingPage()),
            );
          },
          backgroundColor: const Color.fromARGB(255, 62, 54, 226),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
          child: const Icon(CupertinoIcons.add, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  icon: CupertinoIcons.square_list_fill,
                  index: 0,
                  label: 'Danh sách',
                ),
                _buildTabItem(
                  icon: CupertinoIcons.money_rubl_circle_fill,
                  index: 1,
                  label: 'Ngân sách',
                ),
                const SizedBox(width: 48), // khoảng trống cho FAB
                _buildTabItem(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  index: 2,
                  label: 'Thống kê',
                ),
                _buildTabItem(
                  icon: CupertinoIcons.gear_solid,
                  index: 3,
                  label: 'Cài đặt',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              size: 22,
              icon,
              color: isSelected
                  ? const Color.fromARGB(255, 62, 54, 226)
                  : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color.fromARGB(255, 62, 54, 226)
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
