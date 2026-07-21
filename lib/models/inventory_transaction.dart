class InventoryTransaction {
  final int? id;
  final int productId;
  final String type;
  final double quantity;
  final int? referenceId;
  final String? note;
  final DateTime createdAt;

  InventoryTransaction({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.referenceId,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'reference_id': referenceId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantity: map['quantity'],
      referenceId: map['reference_id'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
