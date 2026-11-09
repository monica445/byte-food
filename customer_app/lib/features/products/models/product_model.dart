import 'product_category_model.dart';

class ProductModel {
  final String id;
  final String shopId;
  final String? categoryId;
  final String name;
  final String? description;
  final int price;
  final String? imageUrl;
  final bool isAvailable;
  final ProductCategoryModel? category;

  const ProductModel({
    required this.id,
    required this.shopId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];

    return ProductModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      categoryId: json['categoryId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      category: categoryJson is Map
          ? ProductCategoryModel.fromJson(
              Map<String, dynamic>.from(categoryJson),
            )
          : null,
    );
  }
}