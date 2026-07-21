import '../models/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerService {
  final CustomerRepository _repository;

  CustomerService({
    CustomerRepository? repository,
  }) : _repository = repository ?? CustomerRepository();

  Future<List<Customer>> getCustomers() async {
    return await _repository.getCustomers();
  }

  Future<int> createCustomer(
      Customer customer
  ) async {
    if(customer.name.trim().isEmpty){
      throw Exception('Customer name required');
    }
    return await _repository.createCustomer(customer);
  }
}
