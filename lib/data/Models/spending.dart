class Spending {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  Spending({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory Spending.fromMap(Map<String, dynamic> map) {
    return Spending(
      id: map['id'].toString(),
      userId: map['userid'].toString(),
      categoryId: map['category_id'].toString(),
      amount: double.parse(map['amount'].toString()),
      note: map['note'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    // Parse categoryId to int if database uses integer type
    final categoryIdValue = int.tryParse(categoryId.toString()) ?? categoryId;

    return {
      if (id.isNotEmpty) 'id': id,
      'userid': userId,
      'category_id': categoryIdValue,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Spending.fromJson(Map<String, dynamic> json) {
    return Spending(
      id: json['id'].toString(),
      userId: json['userid'].toString(),
      categoryId: json['category_id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    // Parse categoryId to int if database uses integer type
    final categoryIdValue = int.tryParse(categoryId.toString()) ?? categoryId;

    return {
      'id': id,
      'userid': userId,
      'category_id': categoryIdValue,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
