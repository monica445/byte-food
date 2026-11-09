import 'package:customer_app/features/home/view/widgets/async_state_view.dart';
import 'package:customer_app/features/shop/models/shop_model.dart';
import 'package:customer_app/features/shop/view/widgets/shop_card.dart';
import 'package:customer_app/features/shop/view_models/shop_viewmodel.dart';
import 'package:customer_app/widgets/section_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({
    super.key,
    required this.title,
    required this.onRetry,
    required this.onShopTap,
  });

  final String title;

  /// Reload with the current search / category (owned by the home screen).
  final VoidCallback onRetry;
  final ValueChanged<ShopModel> onShopTap;

  @override
  Widget build(BuildContext context) {
    final state = context.select((ShopViewModel vm) => vm.shopsState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        const SizedBox(height: 12),
        AsyncStateView(
          state: state,
          onRetry: onRetry,
          builder: (context, result) {
            final shops = result.shops;
            if (shops.isEmpty) {
              return const EmptyMessage(
                'No shops found. Try a different search or category.',
              );
            }

            // Open shops first (keeps server order within each group).
            final ordered = [
              ...shops.where((s) => s.isOpen),
              ...shops.where((s) => !s.isOpen),
            ];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  for (var i = 0; i < ordered.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    ShopCard(
                      shop: ordered[i],
                      onTap: () => onShopTap(ordered[i]),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}