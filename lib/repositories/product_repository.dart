import '../database/database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  final DatabaseHelper _databaseHelper;

  ProductRepository({
    DatabaseHelper? databaseHelper,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<Product>> getProducts() async {
    return await _databaseHelper.getAllProducts();
  }

  Future<int> createProduct(Product product) async {
    return await _databaseHelper.insertProduct(product);
  }

  Future<int> updateProduct(Product product) async {
    return await _databaseHelper.updateProduct(product);
  }

  Future<int> deleteProduct(int id) async {
    return await _databaseHelper.deleteProduct(id);
  }
}
