class Budget {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'].toString(),
      userId: map['userid'].toString(),
      categoryId: map['category_id'].toString(),
      amount: double.parse(map['amount'].toString()),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    // Parse categoryId to int if database uses integer type
    final categoryIdValue = int.tryParse(categoryId.toString()) ?? categoryId;

    return {
      'id': id,
      'userid': userId,
      'category_id': categoryIdValue,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class BudgetInsert {
  final int userId;
  final int categoryId;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  BudgetInsert({
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userid': userId,
      'category_id': categoryId,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
