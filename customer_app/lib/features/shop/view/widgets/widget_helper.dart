import 'package:customer_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

String formatPrice(int price, {String symbol = r'$', bool minorUnits = false}) {
  if (minorUnits) return '$symbol${(price / 100).toStringAsFixed(2)}';
  final digits = price.toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$symbol$grouped';
}

/// Network image with a themed loading state and fallback.
/// Fills whatever tight constraints its parent gives it.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
  });

  final String? url;
  final BoxFit fit;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: AppColors.primaryLight,
      child: Center(child: Icon(fallbackIcon, color: AppColors.primary)),
    );

    final src = url;
    if (src == null || src.isEmpty) return fallback;

    return Image.network(
      src,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const ColoredBox(color: AppColors.backgroundTint),
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

/// Desaturates [child] when [enabled] — used for closed shops / unavailable products.
class GrayscaleIf extends StatelessWidget {
  const GrayscaleIf({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  static const _gray = ColorFilter.matrix(<double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) =>
      enabled ? ColorFiltered(colorFilter: _gray, child: child) : child;
}
