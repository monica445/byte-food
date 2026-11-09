import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<Map<String, dynamic>> getProductById(
    String productId,
  ) async {
    final response = await _dio.get('/products/$productId');

    return response.data as Map<String, dynamic>;
  }
}