import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:systego/features/pos/home/model/pos_models.dart';
import '../../../../../core/constants/app_colors.dart';

class POSProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const POSProductCard({required this.product, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.white, AppColors.lightBlueBackground]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.lightBlueBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: product.image != null
                    ? CachedNetworkImage(
                        imageUrl: product.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const CircularProgressIndicator(),
                        errorWidget: (_, __, ___) => const Icon(Icons.image, size: 40),
                      )
                    : const Icon(Icons.image, size: 40),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.all(Radius.circular(8))),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}