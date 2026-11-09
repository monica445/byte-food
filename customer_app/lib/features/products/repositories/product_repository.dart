import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _service;

  ProductRepository(this._service);

  // Get product details
  Future<ProductModel> getProductById(String productId) async {
    final response = await _service.getProductById(productId);

    return ProductModel.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }
}

// Result object for product list + pagination
class ProductListResult {
  final List<ProductModel> products;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const ProductListResult({
    required this.products,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}