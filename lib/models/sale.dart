class Sale {
  final int? id;
  final int? customerId;
  final int totalAmountBif;
  final DateTime createdAt;

  Sale({
    this.id,
    this.customerId,
    required this.totalAmountBif,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'total_amount_bif': totalAmountBif,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customer_id'],
      totalAmountBif: map['total_amount_bif'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
