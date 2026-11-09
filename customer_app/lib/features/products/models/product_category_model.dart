class ProductCategoryModel {
  final String id;
  final String shopId;
  final String name;
  final int sortOrder;

  const ProductCategoryModel({
    required this.id,
    required this.shopId,
    required this.name,
    this.sortOrder = 0,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}