import '../models/debt.dart';
import '../repositories/debt_repository.dart';

class DebtService {
  final DebtRepository _repository;

  DebtService({
    DebtRepository? repository,
  }) : _repository = repository ?? DebtRepository();

  Future<List<Map<String,dynamic>>> getDebtsWithCustomers() async {
    return await _repository.getDebtsWithCustomers();
  }

  Future<int> createDebt(
      Debt debt
  ) async {
    if(debt.amountBif <= 0){
      throw Exception('Debt amount must be positive');
    }
    return await _repository.createDebt(debt);
  }

  Future<void> updateDebtStatus(
      int id,
      String status
  ) async {
    await _repository.updateDebtStatus(id, status);
  }

  Future<int> getOutstandingDebtsTotal() async {
    return await _repository.getOutstandingDebtsTotal();
  }
}
