import 'shop_category_model.dart';
import 'product_category_model.dart';

class ShopModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isOpen;

  final ShopCategoryModel? shopCategory;

  // Available when fetching shop details.
  final List<ProductCategoryModel> productCategories;

  const ShopModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isOpen,
    this.shopCategory,
    this.productCategories = const [],
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      coverUrl: json['coverUrl'],
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isOpen: json['isOpen'] ?? false,

      shopCategory: json['shopCategory'] != null
          ? ShopCategoryModel.fromJson(json['shopCategory'])
          : null,

      productCategories: (json['productCategories'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                ProductCategoryModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
