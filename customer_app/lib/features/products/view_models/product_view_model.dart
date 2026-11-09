import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductDetailViewModel(this._repository);

  ProductModel? product;

  bool isLoading = false;
  String? error;

  int _requestId = 0;

  // Load product details
  Future<void> loadProduct(String productId) async {
    final requestId = ++_requestId;

    isLoading = true;
    error = null;
    product = null;

    notifyListeners();

    try {
      final result = await _repository.getProductById(productId);

      if (requestId != _requestId) return;

      product = result;
    } catch (e) {
      if (requestId != _requestId) return;

      error = e.toString();
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  // Refresh product details
  Future<void> refresh(String productId) async {
    await loadProduct(productId);
  }
}