import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/shop/models/shop_category_model.dart';
import 'package:customer_app/features/shop/view/widgets/widget_helper.dart';
import 'package:flutter/material.dart';

class ShopCategoryCard extends StatelessWidget {
  const ShopCategoryCard({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.size = 72,
  });

  final ShopCategoryModel category;
  final bool selected;
  final VoidCallback? onTap;

  /// Width/height of the image tile.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 16,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: size,
                height: size,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: selected ? AppColors.primaryLight : AppColors.surface,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AppNetworkImage(
                    url: category.imageUrl,
                    fallbackIcon: Icons.category_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
