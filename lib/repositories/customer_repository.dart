import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _databaseHelper;

  CustomerRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<Customer>> getCustomers() async {
    return await _databaseHelper.getAllCustomers();
  }

  Future<int> createCustomer(Customer customer) async {
    return await _databaseHelper.insertCustomer(customer);
  }
}
