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
      id: map['id'],
      userId: map['userid'],
      categoryId: map['category_id'],
      amount: double.parse(map['amount'].toString()),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userid': userId,
      'category_id': categoryId,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
