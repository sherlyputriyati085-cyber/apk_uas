enum FoodStatus { aman, hampir, expired }

class FoodItem {
  final String id;
  final String name;
  final String category;
  final DateTime expiryDate;
  final String? notes;
  final String? imagePath;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.expiryDate,
    this.notes,
    this.imagePath,
  });

  FoodStatus get status {
    final now = DateTime.now();
    final difference = expiryDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (difference < 0) return FoodStatus.expired;
    if (difference <= 7) return FoodStatus.hampir;
    return FoodStatus.aman;
  }

  int get daysLeft {
    final now = DateTime.now();
    return expiryDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  FoodItem copyWith({
    String? name,
    String? category,
    DateTime? expiryDate,
    String? notes,
    String? imagePath,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'expiryDate': expiryDate.toIso8601String(),
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      expiryDate: DateTime.parse(map['expiryDate']),
      notes: map['notes'],
      imagePath: map['imagePath'],
    );
  }
}
