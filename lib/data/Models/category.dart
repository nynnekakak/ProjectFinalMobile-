class Category {
  final String id;
  final String name;
  final String type; // 'income' hoặc 'expense'
  final String? icon;
  final String? color;
  final bool isShared;
  final String? userId;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isShared,
    this.userId,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'].toString(),
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      color: map['color'],
      isShared: map['is_shared'],
      userId: map['userid'].toString(),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_shared': isShared,
      'userid': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CategoryInsert {
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isShared;
  final String? userId;
  final DateTime createdAt;

  CategoryInsert({
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isShared,
    this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      // 👇 KHÔNG có id vì database tự auto-increment
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_shared': isShared,
      'userid': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
