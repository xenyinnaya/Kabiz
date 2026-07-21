import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseService {
  final ExpenseRepository _repository;

  ExpenseService({
    ExpenseRepository? repository,
  }) : _repository = repository ?? ExpenseRepository();

  Future<List<Expense>> getExpenses() async {
    return await _repository.getExpenses();
  }

  Future<int> createExpense(
      Expense expense
  ) async {
    if(expense.description.trim().isEmpty){
      throw Exception('Expense description required');
    }
    if(expense.amountBif <= 0){
      throw Exception('Expense amount must be positive');
    }
    return await _repository.createExpense(expense);
  }
}
