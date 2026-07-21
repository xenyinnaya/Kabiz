class Expense {
  final int? id;
  final String description;
  final String category;
  final int amountBif;
  final DateTime expenseDate;

  Expense({
    this.id,
    required this.description,
    required this.category,
    required this.amountBif,
    required this.expenseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'amount_bif': amountBif,
      'expense_date': expenseDate.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      category: map['category'],
      amountBif: map['amount_bif'],
      expenseDate: DateTime.parse(map['expense_date']),
    );
  }
}
