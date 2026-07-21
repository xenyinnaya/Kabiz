import '../models/product.dart';
import '../repositories/product_repository.dart';

class InventoryService {
  final ProductRepository _repository;

  InventoryService({
    ProductRepository? repository,
  }) : _repository = repository ?? ProductRepository();

  Future<List<Product>> getProducts() async {
    return await _repository.getProducts();
  }

  Future<int> createProduct(
      Product product
  ) async {
    if(product.name.trim().isEmpty){
      throw Exception('Product name required');
    }
    return await _repository.createProduct(product);
  }

  Future<int> updateProduct(
      Product product
  ) async {
    return await _repository.updateProduct(product);
  }

  Future<int> deleteProduct(
      int id
  ) async {
    return await _repository.deleteProduct(id);
  }
}
