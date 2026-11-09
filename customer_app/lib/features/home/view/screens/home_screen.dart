import 'dart:async';

import 'package:customer_app/features/home/view/widgets/search_banner.dart';
import 'package:customer_app/features/products/views/screens/product_detail_screen.dart';
import 'package:customer_app/features/products/views/widgets/product_section.dart';
import 'package:customer_app/features/shop/models/shop_model.dart';
import 'package:customer_app/features/shop/view/screens/shop_detail_screen.dart';
import 'package:customer_app/features/shop/view/widgets/shop_category_section.dart';
import 'package:customer_app/features/shop/view/widgets/shop_section.dart';
import 'package:customer_app/features/shop/view_models/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _shopLimit = 20;
  static const _searchDebounce = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedCategoryId;

  bool get _isFiltering =>
      _selectedCategoryId != null || _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ShopViewModel>();
      vm.fetchShopCategories();
      vm.fetchFeaturedProducts();
      _loadShops();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ---- data ---------------------------------------------------------------

  Future<void> _loadShops() {
    final query = _searchController.text.trim();
    return context.read<ShopViewModel>().fetchShops(
      categoryId: _selectedCategoryId,
      search: query.isEmpty ? null : query,
      limit: _shopLimit,
    );
  }

  Future<void> _refresh() {
    final vm = context.read<ShopViewModel>();
    return Future.wait([
      vm.fetchShopCategories(),
      vm.fetchFeaturedProducts(),
      _loadShops(),
    ]);
  }

  // ---- search / filter ----------------------------------------------------

  void _onSearchChanged(String _) {
    setState(() {}); // product section visibility + "Results" title
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, _loadShops);
  }

  void _onSearchSubmitted(String _) {
    _debounce?.cancel();
    _loadShops();
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {});
    _loadShops();
  }

  void _onCategoryTap(String categoryId) {
    setState(() {
      // Tapping the selected category again clears the filter.
      _selectedCategoryId = _selectedCategoryId == categoryId
          ? null
          : categoryId;
    });
    _loadShops();
  }

  // ---- navigation ---------------------------------------------------------

  void _openShop(ShopModel shop) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShopDetailScreen(shopId: shop.id, initialShop: shop),
      ),
    );
  }

  // ---- ui -----------------------------------------------------------------

  Widget _buildFeaturedProducts() {
    return Builder(
      builder: (context) {
        final state = context.select(
          (ShopViewModel vm) => vm.featuredProductsState,
        );
        final featured = state.data; // list of product + its shop

        return ProductSection(
          title: 'Popular products',
          layout: ProductSectionLayout.horizontal,
          horizontalPadding: 16,
          products: featured?.map((f) => f.product).toList() ?? const [],
          isLoading: featured == null && state.error == null,
          errorMessage: state.error?.toString(),
          onRetry: () => context.read<ShopViewModel>().fetchFeaturedProducts(),
          emptyMessage: 'No products available right now.',
          onProductTap: (product) => ProductDetailScreen.open(
            context,
            productId: product.id,
            initialProduct: product,
            shop: featured?.firstWhere((f) => f.product.id == product.id).shop,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _AppBarTitle(), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            HomeSearchBanner(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              onClear: _clearSearch,
            ),
            const SizedBox(height: 20),
            ShopCategorySection(
              selectedCategoryId: _selectedCategoryId,
              onCategoryTap: _onCategoryTap,
            ),
            if (!_isFiltering) ...[
              const SizedBox(height: 16),
              _buildFeaturedProducts(),
            ],
            const SizedBox(height: 24),
            ShopSection(
              title: _isFiltering ? 'Results' : 'Shops',
              onRetry: _loadShops,
              onShopTap: _openShop,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 36,
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        const Text(
          'bytefood',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}