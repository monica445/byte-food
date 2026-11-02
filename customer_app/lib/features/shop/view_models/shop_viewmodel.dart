import 'package:flutter/foundation.dart';

import '../../../core/state/async_state.dart';

import '../models/product_model.dart';
import '../models/shop_model.dart';
import '../models/shop_category_model.dart';

import '../repositories/shop_repository.dart';

/// A product paired with the shop it belongs to, so the UI can navigate
/// to the shop when the product is tapped.
class FeaturedProduct {
  final ProductModel product;
  final ShopModel shop;

  const FeaturedProduct({required this.product, required this.shop});
}

class ShopViewModel extends ChangeNotifier {
  final ShopRepository _repository;

  ShopViewModel(this._repository);

  // states
  AsyncState<List<ShopCategoryModel>> shopCategoriesState =
      const AsyncState.idle();
  AsyncState<ShopListResult> shopsState = const AsyncState.idle();
  AsyncState<ShopModel> shopDetailState = const AsyncState.idle();
  AsyncState<List<FeaturedProduct>> featuredProductsState =
      const AsyncState.idle();

  // Used to drop stale responses when the user types/filters quickly.
  int _shopsRequestId = 0;

  Future<void> fetchShopCategories() async {
    shopCategoriesState = const AsyncState.loading();
    notifyListeners();

    try {
      final categories = await _repository.getShopCategories();

      shopCategoriesState = AsyncState.success(categories);
    } catch (e) {
      shopCategoriesState = AsyncState.failure(_getErrorMessage(e));
    }

    notifyListeners();
  }

  Future<void> fetchShops({
    String? categoryId,
    String? search,
    bool? isOpen,
    int page = 1,
    int limit = 10,
  }) async {
    final requestId = ++_shopsRequestId;

    shopsState = const AsyncState.loading();
    notifyListeners();

    try {
      final result = await _repository.getShops(
        categoryId: categoryId,
        search: search,
        isOpen: isOpen,
        page: page,
        limit: limit,
      );

      if (requestId != _shopsRequestId) return;
      shopsState = AsyncState.success(result);
    } catch (e) {
      if (requestId != _shopsRequestId) return;
      shopsState = AsyncState.failure(_getErrorMessage(e));
    }

    notifyListeners();
  }

  Future<void> fetchShopDetails(String shopId) async {
    shopDetailState = const AsyncState.loading();
    notifyListeners();

    try {
      final shop = await _repository.getShopById(shopId);

      shopDetailState = AsyncState.success(shop);
    } catch (e) {
      shopDetailState = AsyncState.failure(_getErrorMessage(e));
    }

    notifyListeners();
  }

  /// Products only come with shop details, so this loads a few open shops,
  /// fetches their details in parallel, and takes a couple of available
  /// products from each. Independent of [shopsState], so searching/filtering
  /// the shop list doesn't change it.
  Future<void> fetchFeaturedProducts({
    int shopCount = 4,
    int productsPerShop = 2,
    int maxProducts = 8,
  }) async {
    featuredProductsState = const AsyncState.loading();
    notifyListeners();

    try {
      final list = await _repository.getShops(
        isOpen: true,
        page: 1,
        limit: shopCount,
      );

      final details = await Future.wait(
        list.shops.map((shop) => _repository.getShopById(shop.id)),
      );

      final featured = <FeaturedProduct>[];
      for (final shop in details) {
        final fromShop = <FeaturedProduct>[];
        for (final category in shop.productCategories) {
          for (final product in category.products) {
            if (product.isAvailable) {
              fromShop.add(FeaturedProduct(product: product, shop: shop));
            }
          }
        }
        featured.addAll(fromShop.take(productsPerShop));
      }

      featuredProductsState = AsyncState.success(
        featured.take(maxProducts).toList(),
      );
    } catch (e) {
      featuredProductsState = AsyncState.failure(_getErrorMessage(e));
    }

    notifyListeners();
  }

  // error handling
  String _getErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
