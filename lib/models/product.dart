class Product {
  final int? id;
  final String name;
  final double stockQuantity;
  final String unit;
  final int costPriceBif;
  final int sellingPriceBif;
  final double lowStockThreshold;
  final DateTime createdAt;

  Product({
    this.id,
    required this.name,
    required this.stockQuantity,
    required this.unit,
    required this.costPriceBif,
    required this.sellingPriceBif,
    required this.lowStockThreshold,
    required this.createdAt,
  });

  Product copyWith({
    int? id,
    String? name,
    double? stockQuantity,
    String? unit,
    int? costPriceBif,
    int? sellingPriceBif,
    double? lowStockThreshold,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      costPriceBif: costPriceBif ?? this.costPriceBif,
      sellingPriceBif: sellingPriceBif ?? this.sellingPriceBif,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stock_quantity': stockQuantity,
      'unit': unit,
      'cost_price_bif': costPriceBif,
      'selling_price_bif': sellingPriceBif,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      stockQuantity: map['stock_quantity'],
      unit: map['unit'],
      costPriceBif: map['cost_price_bif'],
      sellingPriceBif: map['selling_price_bif'],
      lowStockThreshold: map['low_stock_threshold'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
