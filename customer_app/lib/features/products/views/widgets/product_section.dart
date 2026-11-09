import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/products/views/widgets/product_card.dart';
import 'package:customer_app/features/shop/models/product_model.dart';
import 'package:flutter/material.dart';

enum ProductSectionLayout {
  grid,
  horizontal,
}

class ProductSection extends StatelessWidget {
  const ProductSection({
    super.key,
    required this.products,
    this.layout = ProductSectionLayout.grid,
    this.title,
    this.showCount = false,
    this.onProductTap,
    this.onProductAdd,
    this.horizontalPadding = 0,
    this.gridColumns = 2,
    this.horizontalCardWidth = 160,
    this.spacing = 12,
    this.emptyMessage = 'No products available.',
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.currencySymbol = r'$',
    this.priceInMinorUnits = true,
  });

  final List<ProductModel> products;
  final ProductSectionLayout layout;
  final String? title;
  final bool showCount;

  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onProductAdd;

  final double horizontalPadding;

  final int gridColumns;
  final double horizontalCardWidth;
  final double spacing;

  final String? emptyMessage;
  final bool isLoading;

  final String? errorMessage;
  final VoidCallback? onRetry;

  final String currencySymbol;
  final bool priceInMinorUnits;

  // Height of the name + price area under the square image (default text scale).
  static const double _infoHeight = 96;

  @override
  Widget build(BuildContext context) {
    final sidePadding = EdgeInsets.symmetric(horizontal: horizontalPadding);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: sidePadding.copyWith(bottom: 12),
            child: _Header(title: title!, count: showCount ? products.length : null),
          ),
        if (products.isEmpty && errorMessage != null)
          Padding(
            padding: sidePadding,
            child: _ErrorBox(message: errorMessage!, onRetry: onRetry),
          )
        else if (products.isEmpty && isLoading)
          const SizedBox(
            height: 120,
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          )
        else if (products.isEmpty)
          emptyMessage == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: sidePadding,
                  child: _EmptyBox(message: emptyMessage!),
                )
        else
          switch (layout) {
            ProductSectionLayout.grid => Padding(
              padding: sidePadding,
              child: _buildGrid(context),
            ),
            ProductSectionLayout.horizontal => _buildHorizontal(context),
          },
      ],
    );
  }

  Widget _card(ProductModel product) {
    return ProductGridCard(
      product: product,
      currencySymbol: currencySymbol,
      priceInMinorUnits: priceInMinorUnits,
      onTap: onProductTap == null ? null : () => onProductTap!(product),
      onAdd: onProductAdd == null ? null : () => onProductAdd!(product),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (gridColumns - 1)) / gridColumns;
        final textScale = MediaQuery.textScalerOf(context).scale(1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            mainAxisExtent: itemWidth + _infoHeight * textScale,
          ),
          itemBuilder: (_, i) => _card(products[i]),
        );
      },
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return SizedBox(
      height: horizontalCardWidth + _infoHeight * textScale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: products.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing),
        itemBuilder: (_, i) =>
            SizedBox(width: horizontalCardWidth, child: _card(products[i])),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}