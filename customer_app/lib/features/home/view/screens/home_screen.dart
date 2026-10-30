import 'dart:async';

import 'package:customer_app/core/constants/app_colors.dart';
import 'package:customer_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:customer_app/features/home/view/widgets/async_state_view.dart';
import 'package:customer_app/features/shop/models/shop_model.dart';
import 'package:customer_app/features/shop/view/widgets/product_card.dart';
import 'package:customer_app/features/shop/view/widgets/shop_card.dart';
import 'package:customer_app/features/shop/view/widgets/shop_category_card.dart';
import 'package:customer_app/features/shop/view_models/shop_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onShopTap});

  final ValueChanged<ShopModel>? onShopTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _shopLimit = 20;

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

  Future<void> _loadShops() {
    final query = _searchController.text.trim();
    return context.read<ShopViewModel>().fetchShops(
      categoryId: _selectedCategoryId,
      search: query.isEmpty ? null : query,
      limit: _shopLimit,
    );
  }

  void _onSearchChanged(String _) {
    setState(() {}); // refresh clear button + product section visibility
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadShops);
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

  Future<void> _refresh() {
    final vm = context.read<ShopViewModel>();
    return Future.wait([
      vm.fetchShopCategories(),
      vm.fetchFeaturedProducts(),
      _loadShops(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().user;
    final vm = context.watch<ShopViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
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
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
          children: [
            // Greeting + search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _GreetingBanner(
                name: user?.name,
                searchField: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: 'Search shops',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearSearch,
                          ),
                  ),
                ),
              ),
            ),

            // Shop categories
            const SizedBox(height: 20),
            AsyncStateView(
              state: vm.shopCategoriesState,
              onRetry: vm.fetchShopCategories,
              placeholderHeight: 124,
              builder: (context, categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                final sorted = [...categories]
                  ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                return SizedBox(
                  height: 124,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 4),
                    itemBuilder: (_, i) => ShopCategoryCard(
                      category: sorted[i],
                      selected: sorted[i].id == _selectedCategoryId,
                      onTap: () => _onCategoryTap(sorted[i].id),
                    ),
                  ),
                );
              },
            ),

            // Popular products (hidden while searching / filtering)
            if (!_isFiltering) ...[
              const SizedBox(height: 16),
              const _SectionTitle('Popular products'),
              const SizedBox(height: 12),
              AsyncStateView(
                state: vm.featuredProductsState,
                onRetry: vm.fetchFeaturedProducts,
                placeholderHeight: 120,
                builder: (context, products) {
                  if (products.isEmpty) {
                    return const _EmptyMessage(
                      'No products available right now.',
                    );
                  }
                  return SizedBox(
                    height: 262,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => SizedBox(
                        width: 160,
                        child: ProductGridCard(
                          product: products[i].product,
                          onTap: () => widget.onShopTap?.call(products[i].shop),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            // Shops
            const SizedBox(height: 24),
            _SectionTitle(_isFiltering ? 'Results' : 'Shops'),
            const SizedBox(height: 12),
            AsyncStateView(
              state: vm.shopsState,
              onRetry: _loadShops,
              builder: (context, result) {
                final shops = result.shops;
                if (shops.isEmpty) {
                  return const _EmptyMessage(
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
                          onTap: () => widget.onShopTap?.call(ordered[i]),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner({required this.name, required this.searchField});

  final String? name;
  final Widget searchField;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${name ?? 'there'}!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What would you like to eat today?',
            style: TextStyle(color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          searchField,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
