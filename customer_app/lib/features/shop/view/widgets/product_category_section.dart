import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/shop/models/product_category_model.dart';
import 'package:customer_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';
import 'product_card.dart';

class ProductCategorySection extends StatelessWidget {
  const ProductCategorySection({
    super.key,
    required this.category,
    this.onProductTap,
    this.onProductAdd,
    this.currencySymbol = r'$',
    this.priceInMinorUnits = true,
  });

  final ProductCategoryModel category;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onProductAdd;
  final String currencySymbol;
  final bool priceInMinorUnits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final products = category.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${products.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (products.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundTint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No products in this category yet.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          )
        else
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            ProductCard(
              product: products[i],
              currencySymbol: currencySymbol,
              priceInMinorUnits: priceInMinorUnits,
              onTap: onProductTap == null
                  ? null
                  : () => onProductTap!(products[i]),
              onAdd: onProductAdd == null
                  ? null
                  : () => onProductAdd!(products[i]),
            ),
          ],
      ],
    );
  }
}
