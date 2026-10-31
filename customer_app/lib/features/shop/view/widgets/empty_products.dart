import 'package:customer_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class EmptyProducts extends StatelessWidget {
  const EmptyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 40, color: AppColors.textMuted),

          SizedBox(height: 12),

          Text(
            'This shop has no products yet.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
