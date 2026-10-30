import 'product_model.dart';

class ProductCategoryModel {
  final String id;
  final String name;
  final int sortOrder;
  final List<ProductModel> products;

  const ProductCategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.products,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'],
      name: json['name'],
      sortOrder: json['sortOrder'] ?? 0,
      products: (json['products'] as List<dynamic>? ?? [])
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
