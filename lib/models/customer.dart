class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
