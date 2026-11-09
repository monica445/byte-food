import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/shop/models/product_model.dart';
import 'package:customer_app/features/shop/view/widgets/widget_helper.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
    this.currencySymbol = r'$',
    this.priceInMinorUnits = true,
  });

  final ProductModel product;
  final VoidCallback? onTap;

  /// Shows a "+" button on the image when provided and the product is available.
  final VoidCallback? onAdd;
  final String currencySymbol;
  final bool priceInMinorUnits;

  static const double _imageSize = 96;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final available = product.isAvailable;
    final description = product.description;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _imageSize),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: available
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                          if (description != null &&
                              description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            formatPrice(
                              product.price,
                              symbol: currencySymbol,
                              minorUnits: priceInMinorUnits,
                            ),
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: available
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                          if (!available) ...[
                            const SizedBox(width: 8),
                            const _UnavailableTag(),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ProductImage(product: product, size: _imageSize, onAdd: onAdd),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical product tile for 2-column grids.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
    this.currencySymbol = r'$',
    this.priceInMinorUnits = true,
  });

  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final String currencySymbol;
  final bool priceInMinorUnits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final available = product.isAvailable;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GrayscaleIf(
                    enabled: !available,
                    child: AppNetworkImage(
                      url: product.imageUrl,
                      fallbackIcon: Icons.fastfood_outlined,
                    ),
                  ),
                  if (!available)
                    const Positioned(top: 8, left: 8, child: _UnavailableTag()),
                  if (available && onAdd != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _AddButton(onPressed: onAdd!),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: available
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(
                      product.price,
                      symbol: currencySymbol,
                      minorUnits: priceInMinorUnits,
                    ),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: available
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.size, this.onAdd});

  final ProductModel product;
  final double size;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final available = product.isAvailable;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GrayscaleIf(
              enabled: !available,
              child: AppNetworkImage(
                url: product.imageUrl,
                fallbackIcon: Icons.fastfood_outlined,
              ),
            ),
          ),
          if (available && onAdd != null)
            Positioned(
              right: 6,
              bottom: 6,
              child: _AddButton(onPressed: onAdd!),
            ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.add, size: 20, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}

class _UnavailableTag extends StatelessWidget {
  const _UnavailableTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Unavailable',
        style: TextStyle(
          color: AppColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
