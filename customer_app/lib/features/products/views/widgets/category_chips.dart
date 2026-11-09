import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/shop/models/product_category_model.dart';
import 'package:flutter/material.dart';

class CategoryChipsDelegate extends SliverPersistentHeaderDelegate {
  CategoryChipsDelegate({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ProductCategoryModel> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  static const double _height = 60;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent ? AppColors.border : Colors.transparent,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _FilterChip(
            label: 'All',
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),

          for (final category in categories) ...[
            const SizedBox(width: 8),

            _FilterChip(
              label: category.name,
              selected: category.id == selectedId,
              onTap: () => onSelected(category.id),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CategoryChipsDelegate oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.selectedId != selectedId;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.onPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
