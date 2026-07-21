import '../models/sale.dart';
import '../models/sale_item.dart';
import '../repositories/sales_repository.dart';

class SalesService {
  final SalesRepository _repository;

  SalesService({
    SalesRepository? repository,
  }) : _repository = repository ?? SalesRepository();

  Future<int> createSale(
      Sale sale,
      List<SaleItem> items
  ) async {
    if(items.isEmpty){
      throw Exception('Sale requires items');
    }
    return await _repository.createSale(
      sale,
      items,
    );
  }

  Future<List<Map<String,dynamic>>> getSales() async {
    return await _repository.getSalesWithCustomers();
  }
}
