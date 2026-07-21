class Debt {
  final int? id;
  final int customerId;
  final int amountBif;
  final DateTime dueDate;
  final String status; 
  final DateTime createdAt;

  Debt({
    this.id,
    required this.customerId,
    required this.amountBif,
    required this.dueDate,
    required this.status,
    required this.createdAt,
  });

  Debt copyWith({
    int? id,
    int? customerId,
    int? amountBif,
    DateTime? dueDate,
    String? status,
    DateTime? createdAt,
  }) {
    return Debt(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amountBif: amountBif ?? this.amountBif,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'amount_bif': amountBif,
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      customerId: map['customer_id'],
      amountBif: map['amount_bif'],
      dueDate: DateTime.parse(map['due_date']),
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
