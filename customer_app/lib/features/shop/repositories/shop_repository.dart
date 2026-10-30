import '../models/shop_model.dart';
import '../models/shop_category_model.dart';
import '../services/shop_service.dart';

class ShopRepository {
  final ShopService _service;

  ShopRepository(this._service);

  // Get shop categories
  Future<List<ShopCategoryModel>> getShopCategories() async {
    final response = await _service.getShopCategories();

    final data = response['data'] as List<dynamic>;

    return data
        .map((item) => ShopCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Get shops
  Future<ShopListResult> getShops({
    String? categoryId,
    String? search,
    bool? isOpen,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _service.getShops(
      categoryId: categoryId,
      search: search,
      isOpen: isOpen,
      page: page,
      limit: limit,
    );

    final shops = (response['data'] as List<dynamic>)
        .map((item) => ShopModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final pagination = response['pagination'] as Map<String, dynamic>;

    return ShopListResult(
      shops: shops,
      page: pagination['page'],
      limit: pagination['limit'],
      total: pagination['total'],
      totalPages: pagination['totalPages'],
    );
  }

  // Get shop details
  Future<ShopModel> getShopById(String shopId) async {
    final response = await _service.getShopById(shopId);

    return ShopModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}

// Result object for shop list + pagination
class ShopListResult {
  final List<ShopModel> shops;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const ShopListResult({
    required this.shops,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}
