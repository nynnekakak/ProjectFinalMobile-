import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_cubit.dart';
import 'package:moneyboys/Modules/Home/Cubit/home_state.dart';
import 'package:moneyboys/Modules/expense/edit_spending_page.dart';
import 'package:moneyboys/data/Models/spending.dart';
import 'package:moneyboys/Shared/widgets/ai_assistant_widget.dart';
import 'package:moneyboys/Shared/widgets/ai_chat_page.dart';

/// Example of how to use the new HomeCubit with the home screen
/// To use this, wrap the screen with BlocProvider:
///
/// BlocProvider(
///   create: (context) => HomeCubit()..loadSpendings(),
///   child: const HomeScreenWithCubit(),
/// )

class HomeScreenWithCubit extends StatelessWidget {
  const HomeScreenWithCubit({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeDeleteError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is HomeAIError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F7FF),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<HomeCubit>().refreshSpendings(),
                    color: const Color(0xFF0040FF),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      children: [
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: _buildContent(context, state),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0040FF)),
      );
    } else if (state is HomeLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopCards(state),
          const SizedBox(height: 24),
          const Text(
            "Các giao dịch gần đây",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 12),
          ...state.spendings.map(
            (spending) => _buildSpendingItem(
              context,
              spending,
              state.categoryMap[spending.categoryId],
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    } else if (state is HomeRefreshing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopCards(
            HomeLoaded(
              spendings: state.spendings,
              categoryMap: state.categoryMap,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Các giao dịch gần đây",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 12),
          ...state.spendings.map(
            (spending) => _buildSpendingItem(
              context,
              spending,
              state.categoryMap[spending.categoryId],
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    } else if (state is HomeError) {
      return Center(child: Text(state.message));
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildTopCards(HomeLoaded state) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (var s in state.spendings) {
      if (state.categoryMap[s.categoryId]?.type == 'income') {
        totalIncome += s.amount;
      } else {
        totalExpense += s.amount;
      }
    }

    return Column(
      children: [
        _buildSummaryCard(
          double.infinity,
          120,
          'Số dư',
          totalIncome - totalExpense,
          const Color(0xFF0040FF),
          onTap: () {},
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard2(
                double.infinity,
                90,
                "Tổng thu nhập",
                Colors.white,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard2(
                double.infinity,
                90,
                "Tổng chi tiêu",
                const Color(0xFF0040FF),
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard2(
    double width,
    double height,
    String title,
    Color color, {
    required VoidCallback onTap,
  }) {
    final isBlue = color == const Color(0xFF0040FF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.credit_card,
              color: isBlue ? Colors.white : const Color(0xFF0040FF),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isBlue ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    double width,
    double height,
    String title,
    double amount,
    Color color, {
    required VoidCallback onTap,
  }) {
    final isBlue = color == const Color(0xFF0040FF);
    final formatter = NumberFormat("#,###", "en_US");
    String? textamount = formatter.format(amount);
    if (textamount == '0') textamount = null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.credit_card,
              color: isBlue ? Colors.white : const Color(0xFF0040FF),
            ),
            const SizedBox(height: 8),
            Text(
              textamount ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isBlue ? Colors.white : const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isBlue ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingItem(BuildContext context, Spending s, var category) {
    final formatter = NumberFormat("#,###", "en_US");
    if (category == null) return const SizedBox.shrink();
    final isIncome = category.type == 'income';

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            icon: Icons.delete,
            backgroundColor: Colors.red,
            spacing: 4.0,
            flex: 1,
            label: 'Xóa',
            onPressed: (ctx) {
              context.read<HomeCubit>().deleteSpending(s.id);
            },
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                category.icon ?? "❓",
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            category.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF111111),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(s.date),
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                s.note ?? '',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: Text(
            "${isIncome ? '+' : '-'}\$${formatter.format(s.amount)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red[500],
            ),
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditSpendingPage(spending: s)),
            );
            if (context.mounted) {
              context.read<HomeCubit>().notifySpendingUpdated();
            }
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final isLoading = state is HomeLoading || state is HomeRefreshing;
        if (isLoading) return const SizedBox.shrink();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'homecubit_chat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIChatPage()),
                );
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.chat_bubble, color: Colors.white),
            ),
            const SizedBox(height: 10),
            FloatingActionButton.extended(
              heroTag: 'homecubit_analysis',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AIAdviceDialog(
                    onGetAdvice: () async {
                      context.read<HomeCubit>().getAIAdvice();
                      return 'Loading...';
                    },
                    title: 'Phân tích tài chính',
                    icon: Icons.analytics,
                  ),
                );
              },
              icon: const Icon(Icons.psychology),
              label: const Text('Phân tích'),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            const SizedBox(height: 60),
          ],
        );
      },
    );
  }
}
