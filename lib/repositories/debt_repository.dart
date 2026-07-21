import '../database/database_helper.dart';
import '../models/debt.dart';

class DebtRepository {
  final DatabaseHelper _databaseHelper;

  DebtRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<Map<String, dynamic>>> getDebtsWithCustomers() async {
    return await _databaseHelper.getAllDebtsWithCustomers();
  }

  Future<int> getOutstandingDebtsTotal() async {
    return await _databaseHelper.getOutstandingDebtsTotal();
  }

  Future<int> createDebt(Debt debt) async {
    return await _databaseHelper.insertDebt(debt);
  }

  Future<void> updateDebtStatus(int debtId, String status) async {
    await _databaseHelper.updateDebtStatus(debtId, status);
  }
}
