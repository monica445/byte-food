import 'package:customer_app/features/home/view/widgets/async_state_view.dart';
import 'package:customer_app/features/shop/models/product_category_model.dart';
import 'package:customer_app/features/shop/models/product_model.dart';
import 'package:customer_app/features/shop/models/shop_model.dart';
import 'package:customer_app/features/shop/view/widgets/category_chips.dart';
import 'package:customer_app/features/shop/view/widgets/empty_products.dart';
import 'package:customer_app/features/shop/view/widgets/product_category_section.dart';
import 'package:customer_app/features/shop/view/widgets/shop_cover_app_bar.dart';
import 'package:customer_app/features/shop/view/widgets/shop_header.dart';
import 'package:customer_app/features/shop/view_models/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShopDetailScreen extends StatefulWidget {
  const ShopDetailScreen({
    super.key,
    required this.shopId,
    this.initialShop,
    this.onProductTap,
    this.onProductAdd,
  });

  final String shopId;
  final ShopModel? initialShop;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onProductAdd;

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  static const double _coverHeight = 200;

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    if (!mounted) return Future.value();

    return context.read<ShopViewModel>().fetchShopDetails(widget.shopId);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopViewModel>();

    // Avoid displaying details from a previously opened shop.
    final loaded = vm.shopDetailState.data;

    final ShopModel? detail = loaded != null && loaded.id == widget.shopId
        ? loaded
        : null;

    final ShopModel? shop = detail ?? widget.initialShop;

    // Show loading or error when no initial shop is available.
    if (shop == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: AsyncStateView<ShopModel>(
            state: vm.shopDetailState,
            onRetry: _load,
            placeholderHeight: 200,
            builder: (_, __) => const SizedBox.shrink(),
          ),
        ),
      );
    }

    final categories =
        detail?.productCategories ?? const <ProductCategoryModel>[];

    final selectedId =
        categories.any((category) => category.id == _selectedCategoryId)
        ? _selectedCategoryId
        : null;

    final visibleCategories = selectedId == null
        ? categories
        : categories.where((category) => category.id == selectedId).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        edgeOffset: _coverHeight,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ShopCoverAppBar(shop: shop, expandedHeight: _coverHeight),

            SliverToBoxAdapter(child: ShopHeader(shop: shop)),

            if (detail == null)
              SliverToBoxAdapter(
                child: AsyncStateView<ShopModel>(
                  state: vm.shopDetailState,
                  onRetry: _load,
                  placeholderHeight: 160,
                  builder: (_, __) => const SizedBox.shrink(),
                ),
              )
            else if (categories.isEmpty)
              const SliverToBoxAdapter(child: EmptyProducts())
            else ...[
              if (categories.length > 1)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: CategoryChipsDelegate(
                    categories: categories,
                    selectedId: selectedId,
                    onSelected: (id) {
                      setState(() {
                        _selectedCategoryId = id;
                      });
                    },
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList.separated(
                  itemCount: visibleCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (_, index) {
                    return ProductCategorySection(
                      category: visibleCategories[index],
                      onProductTap: widget.onProductTap,
                      onProductAdd: shop.isOpen ? widget.onProductAdd : null,
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
