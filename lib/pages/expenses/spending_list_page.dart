import 'package:flutter/material.dart';
import '../../core/utils/format.dart';

enum TxCategory { food, coffee, fuel, shopping, home, other }

extension TxCatX on TxCategory {
  String get label => switch (this) {
    TxCategory.food => 'Ăn uống',
    TxCategory.coffee => 'Cà phê',
    TxCategory.fuel => 'Xăng xe',
    TxCategory.shopping => 'Mua sắm',
    TxCategory.home => 'Nhà cửa',
    TxCategory.other => 'Khác',
  };
  IconData get icon => switch (this) {
    TxCategory.food => Icons.restaurant,
    TxCategory.coffee => Icons.local_cafe,
    TxCategory.fuel => Icons.local_gas_station,
    TxCategory.shopping => Icons.shopping_bag,
    TxCategory.home => Icons.home_outlined,
    TxCategory.other => Icons.category,
  };
}

class Tx {
  final String id;
  final String title;
  final int amount; // dương (đại diện cho chi tiêu)
  final DateTime date;
  final TxCategory category;
  const Tx({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

// Mock UI-only
final mockTxs = <Tx>[
  Tx(
    id: 't1',
    title: 'Ăn trưa',
    amount: 45000,
    date: DateTime.now(),
    category: TxCategory.food,
  ),
  Tx(
    id: 't2',
    title: 'Xăng xe',
    amount: 80000,
    date: DateTime.now().subtract(const Duration(days: 1)),
    category: TxCategory.fuel,
  ),
  Tx(
    id: 't3',
    title: 'Cà phê',
    amount: 30000,
    date: DateTime.now().subtract(const Duration(days: 2)),
    category: TxCategory.coffee,
  ),
  Tx(
    id: 't4',
    title: 'Áo phông',
    amount: 220000,
    date: DateTime.now().subtract(const Duration(days: 3)),
    category: TxCategory.shopping,
  ),
];

class SpendingListPage extends StatelessWidget {
  const SpendingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (mockTxs.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long,
        title: 'Chưa có chi tiêu',
        message: 'Nhấn nút “+” để thêm khoản đầu tiên',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: mockTxs.length,
      separatorBuilder: (_, __) => const Divider(height: 8),
      itemBuilder: (context, i) {
        final t = mockTxs[i];
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: CircleAvatar(
            backgroundColor: cs.primary.withOpacity(0.12),
            child: Icon(t.category.icon, color: cs.primary),
          ),
          title: Text(t.title),
          subtitle: Text('${fmDate(t.date)} • ${t.category.label}'),
          trailing: Text(
            '-${fmMoney(t.amount)}',
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
          ),
          onTap: () {
            // TODO: mở chi tiết giao dịch
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('TODO: Chi tiết “${t.title}”')),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: cs.outline),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}
