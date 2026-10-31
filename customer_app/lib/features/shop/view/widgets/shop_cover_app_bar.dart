import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/shop/models/shop_model.dart';
import 'package:customer_app/features/shop/view/widgets/widget_helper.dart';
import 'package:flutter/material.dart';

class ShopCoverAppBar extends StatelessWidget {
  const ShopCoverAppBar({
    super.key,
    required this.shop,
    required this.expandedHeight,
  });

  final ShopModel shop;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      automaticallyImplyLeading: false,
      leading: Center(
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back, size: 20),
            ),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = MediaQuery.paddingOf(context).top;
          final minExtent = kToolbarHeight + top;
          final maxExtent = expandedHeight + top;

          final t =
              ((constraints.maxHeight - minExtent) / (maxExtent - minExtent))
                  .clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              GrayscaleIf(
                enabled: !shop.isOpen,
                child: AppNetworkImage(
                  url: shop.coverUrl,
                  fallbackIcon: Icons.storefront_outlined,
                ),
              ),

              Opacity(
                opacity: 1 - t,
                child: const ColoredBox(color: AppColors.surface),
              ),

              Positioned(
                left: 64,
                right: 16,
                bottom: 0,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: 1 - t,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
