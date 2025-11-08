// lib/data/mock/mock_data.dart
import 'package:intl/intl.dart';

/// In-memory mock cho demo UI (không cần backend)

final Map<String, dynamic> mockUser = {
  'id': 'u_001',
  'name': 'Huy MoneyBoy',
  'email': 'huy@example.com',
  'created_at': DateTime(2024, 1, 1).toIso8601String(),
};

final List<Map<String, dynamic>> mockCategories = [
  {'id': 'c_food', 'name': 'Ăn uống', 'icon': '🍜'},
  {'id': 'c_move', 'name': 'Di chuyển', 'icon': '🚌'},
  {'id': 'c_shop', 'name': 'Mua sắm', 'icon': '🛒'},
];

final List<Map<String, dynamic>> mockBudgets = [
  {
    'id': 'b1',
    'user_id': 'u_001',
    'category_id': 'c_food',
    'amount': 1500000.0,
    'start_date': DateTime(2025, 11, 1).toIso8601String(),
    'end_date': DateTime(2025, 11, 30).toIso8601String(),
    'created_at': DateTime(2025, 10, 28).toIso8601String(),
  },
  {
    'id': 'b2',
    'user_id': 'u_001',
    'category_id': 'c_move',
    'amount': 500000.0,
    'start_date': DateTime(2025, 11, 1).toIso8601String(),
    'end_date': DateTime(2025, 11, 30).toIso8601String(),
    'created_at': DateTime(2025, 10, 29).toIso8601String(),
  },
];

final List<Map<String, dynamic>> mockSpendings = [
  {
    'id': 's1',
    'user_id': 'u_001',
    'category_id': 'c_food',
    'amount': 45000.0,
    'note': 'Bánh mì + sữa',
    'date': DateTime(2025, 11, 2).toIso8601String(),
  },
  {
    'id': 's2',
    'user_id': 'u_001',
    'category_id': 'c_food',
    'amount': 120000.0,
    'note': 'Bữa trưa',
    'date': DateTime(2025, 11, 3).toIso8601String(),
  },
  {
    'id': 's3',
    'user_id': 'u_001',
    'category_id': 'c_move',
    'amount': 15000.0,
    'note': 'Xe buýt',
    'date': DateTime(2025, 11, 4).toIso8601String(),
  },
];

Map<String, dynamic>? findCategory(String id) {
  try {
    return mockCategories.firstWhere((c) => c['id'] == id);
  } catch (_) {
    return null;
  }
}

double sumSpendingsFor(String categoryId, DateTime start, DateTime end) {
  return mockSpendings
      .where((s) {
        final d = DateTime.parse(s['date']);
        return s['category_id'] == categoryId &&
            !d.isBefore(start) &&
            !d.isAfter(end);
      })
      .fold<double>(0.0, (acc, s) => acc + (s['amount'] as num).toDouble());
}
