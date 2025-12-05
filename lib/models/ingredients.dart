// lib/models/ingredient.dart
class Ingredient {
  final int? id;
  final String name;
  final String? description;
  final String? quantity;
  final DateTime? expirationDate;

  Ingredient({
    this.id,
    required this.name,
    this.description,
    this.quantity,
    this.expirationDate,
  });

  Ingredient copyWith({
    int? id,
    String? name,
    String? description,
    String? quantity,
    DateTime? expirationDate,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'expirationDate': expirationDate?.toIso8601String(),
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      quantity: map['quantity'] as String?,
      expirationDate: map['expirationDate'] != null
          ? DateTime.parse(map['expirationDate'] as String)
          : null,
    );
  }
}