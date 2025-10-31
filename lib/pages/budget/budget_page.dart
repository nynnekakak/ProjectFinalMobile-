import 'package:flutter/material.dart';
import '../../core/utils/format.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngân sách tháng này',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fmMoney(5_000_000),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    // TODO: chỉnh sửa ngân sách
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('TODO: Sửa ngân sách')),
                    );
                  },
                  child: const Text('Sửa'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Hạng mục', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...[
          _BudgetRow(title: 'Ăn uống', used: 1200000, limit: 2000000),
          _BudgetRow(title: 'Xăng xe', used: 300000, limit: 600000),
          _BudgetRow(title: 'Mua sắm', used: 900000, limit: 1500000),
        ],
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String title;
  final int used;
  final int limit;
  const _BudgetRow({
    required this.title,
    required this.used,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = (used / limit).clamp(0.0, 1.0);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${fmMoney(used)} / ${fmMoney(limit)}',
                  style: TextStyle(color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: p,
                minHeight: 8,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
