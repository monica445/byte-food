import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ShopService {
  final Dio _dio;

  ShopService(ApiClient apiClient) : _dio = apiClient.dio;

  Future<Map<String, dynamic>> getShopCategories() async {
    final response = await _dio.get('/shop-categories');

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getShops({
    String? categoryId,
    String? search,
    bool? isOpen,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/shops',
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (isOpen != null) 'isOpen': isOpen,
        'page': page,
        'limit': limit,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getShopById(String shopId) async {
    final response = await _dio.get('/shops/$shopId');

    return response.data as Map<String, dynamic>;
  }
}
