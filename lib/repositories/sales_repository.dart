import '../database/database_helper.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';

class SalesRepository {
  final DatabaseHelper _databaseHelper;

  SalesRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<int> createSale(Sale sale, List<SaleItem> items) async {
    return await _databaseHelper.insertSale(sale, items);
  }

  Future<List<Map<String, dynamic>>> getSalesWithCustomers() async {
    return await _databaseHelper.getAllSalesWithCustomers();
  }
}
