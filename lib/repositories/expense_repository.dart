import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final DatabaseHelper _databaseHelper;

  ExpenseRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<Expense>> getExpenses() async {
    return await _databaseHelper.getAllExpenses();
  }

  Future<int> createExpense(Expense expense) async {
    return await _databaseHelper.insertExpense(expense);
  }
}
