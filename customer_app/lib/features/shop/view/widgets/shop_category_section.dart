import 'package:customer_app/features/home/view/widgets/async_state_view.dart';
import 'package:customer_app/features/shop/view/widgets/shop_category_card.dart';
import 'package:customer_app/features/shop/view_models/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopCategorySection extends StatelessWidget {
  const ShopCategorySection({
    super.key,
    required this.selectedCategoryId,
    required this.onCategoryTap,
  });

  static const double _height = 124;

  final String? selectedCategoryId;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final state = context.select((ShopViewModel vm) => vm.shopCategoriesState);

    return AsyncStateView(
      state: state,
      placeholderHeight: _height,
      onRetry: () => context.read<ShopViewModel>().fetchShopCategories(),
      builder: (context, categories) {
        if (categories.isEmpty) return const SizedBox.shrink();

        final sorted = [...categories]
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        return SizedBox(
          height: _height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (_, i) => ShopCategoryCard(
              category: sorted[i],
              selected: sorted[i].id == selectedCategoryId,
              onTap: () => onCategoryTap(sorted[i].id),
            ),
          ),
        );
      },
    );
  }
}