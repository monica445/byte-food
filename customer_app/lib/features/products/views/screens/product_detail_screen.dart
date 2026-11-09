import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/shop/models/product_model.dart';
import 'package:customer_app/features/shop/models/shop_model.dart';
import 'package:customer_app/features/shop/view/widgets/shop_card.dart';
import 'package:customer_app/features/shop/view/widgets/widget_helper.dart';
import 'package:customer_app/features/products/view_models/product_view_model.dart';
import '../../repositories/product_repository.dart';
import '../widgets/collapsingImageAppBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
    this.shop,
    this.onShopTap,
    this.onAddToCart,
    this.currencySymbol = r'$',
    this.priceInMinorUnits = true,
  });


  static Future<void> open(
    BuildContext context, {
    required String productId,
    ProductModel? initialProduct,
    ShopModel? shop,
    ValueChanged<ShopModel>? onShopTap,
    void Function(ProductModel product, int quantity)? onAddToCart,
  }) {
    final repository = context.read<ProductRepository>();

    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ProductDetailViewModel(repository),
          child: ProductDetailScreen(
            productId: productId,
            initialProduct: initialProduct,
            shop: shop,
            onShopTap: onShopTap,
            onAddToCart: onAddToCart,
          ),
        ),
      ),
    );
  }

  final String productId;
  final ProductModel? initialProduct;
  final ShopModel? shop;
  final ValueChanged<ShopModel>? onShopTap;

  final void Function(ProductModel product, int quantity)? onAddToCart;

  final String currencySymbol;
  final bool priceInMinorUnits;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const double _imageHeight = 320;
  static const int _maxQuantity = 99;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    if (!mounted) return Future.value();
    return context.read<ProductDetailViewModel>().loadProduct(widget.productId);
  }

  void _addToCart(ProductModel product) {
    final callback = widget.onAddToCart;
    callback?.call(product, _quantity);

    if (callback != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity x ${product.name}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductDetailViewModel>();

    // Ignore anything left over from a different product.
    final loaded = vm.product;
    final ProductModel? product =
        ((loaded != null && loaded.id == widget.productId)
        ? loaded
        : widget.initialProduct) as ProductModel?;

    // Nothing to show yet: full-screen loading / error.
    if (product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: vm.error != null
              ? _ErrorView(
                  message: vm.error!.replaceFirst('Exception: ', ''),
                  onRetry: _load,
                )
              : const CircularProgressIndicator(),
        ),
      );
    }

    final shop = widget.shop;
    final shopClosed = shop != null && !shop.isOpen;
    final canOrder = product.isAvailable && !shopClosed;

    final buttonLabel = !product.isAvailable
        ? 'Unavailable'
        : shopClosed
        ? 'Shop is closed'
        : 'Add to cart · ${formatPrice(product.price * _quantity, symbol: widget.currencySymbol, minorUnits: widget.priceInMinorUnits)}';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        edgeOffset: _imageHeight,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            CollapsingImageAppBar(
              title: product.name,
              imageUrl: product.imageUrl,
              expandedHeight: _imageHeight,
              grayscale: !product.isAvailable,
              fallbackIcon: Icons.fastfood_outlined,
            ),
            SliverToBoxAdapter(
              child: _ProductInfo(
                product: product,
                shop: shop,
                onShopTap: widget.onShopTap,
                currencySymbol: widget.currencySymbol,
                priceInMinorUnits: widget.priceInMinorUnits,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _QuantityStepper(
                  quantity: _quantity,
                  enabled: canOrder,
                  max: _maxQuantity,
                  onChanged: (q) => setState(() => _quantity = q),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canOrder ? () => _addToCart(product) : null,
                    child: Text(
                      buttonLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({
    required this.product,
    required this.shop,
    required this.onShopTap,
    required this.currencySymbol,
    required this.priceInMinorUnits,
  });

  final ProductModel product;
  final ShopModel? shop;
  final ValueChanged<ShopModel>? onShopTap;
  final String currencySymbol;
  final bool priceInMinorUnits;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final description = product.description;
    final shop = this.shop;

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
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
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: product.isAvailable
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
              ),
              if (!product.isAvailable) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
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
                ),
              ],
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'About this item',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (shop != null) ...[
            const SizedBox(height: 20),
            _SoldByTile(
              shop: shop,
              onTap: onShopTap == null ? null : () => onShopTap!(shop),
            ),
            if (!shop.isOpen) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This shop is currently closed, so ordering is unavailable.',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SoldByTile extends StatelessWidget {
  const _SoldByTile({required this.shop, this.onTap});

  final ShopModel shop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundTint,
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
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: ClipOval(
                  child: AppNetworkImage(
                    url: shop.logoUrl,
                    fallbackIcon: Icons.store_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sold by',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ShopStatusBadge(isOpen: shop.isOpen),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.enabled,
    required this.max,
    required this.onChanged,
  });

  final int quantity;
  final bool enabled;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove),
            color: AppColors.primary,
            onPressed: enabled && quantity > 1
                ? () => onChanged(quantity - 1)
                : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: enabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: enabled && quantity < max
                ? () => onChanged(quantity + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}