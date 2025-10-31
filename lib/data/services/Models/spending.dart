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
      id: map['id'],
      userId: map['userid'],
      categoryId: map['category_id'],
      amount: double.parse(map['amount'].toString()),
      note: map['note'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'userid': userId,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Spending.fromJson(Map<String, dynamic> json) {
    return Spending(
      id: json['id'] as String,
      userId: json['userid'] as String,
      categoryId: json['category_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userId,
      'category_id': categoryId,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
