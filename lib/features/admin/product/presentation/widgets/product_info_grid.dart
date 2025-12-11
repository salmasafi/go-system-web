import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/product/presentation/widgets/product_info_item.dart';

// class ProductInfoGrid extends StatelessWidget {
//   final List<ProductInfoItem> items;

//   final Widget? gallery;

//   const ProductInfoGrid({super.key, required this.items, this.gallery});

//   @override
//   Widget build(BuildContext context) {
//     final columns = ResponsiveUI.gridColumns(context);

//     return Container(
//       padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
//       decoration: BoxDecoration(
//         color: AppColors.shadowGray[50],
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 12),
//         ),
//         border: Border.all(color: AppColors.shadowGray[200]!),
//       ),
//       child: Column(
//         children: List.generate((items.length / columns).ceil(), (index) {
//           final leftIndex = index * columns;
//           final rightIndex = leftIndex + 1;
//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: index < (items.length / columns).ceil() - 1
//                   ? ResponsiveUI.spacing(context, 16)
//                   : 0,
//             ),
//             child: Row(
//               children: [
//                 Expanded(child: items[leftIndex]),
//                 if (rightIndex < items.length) ...[
//                   SizedBox(width: ResponsiveUI.spacing(context, 16)),
//                   Expanded(child: items[rightIndex]),
//                 ] else
//                   const Expanded(child: SizedBox()),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
class ProductInfoGrid extends StatelessWidget {
  final List<ProductInfoItem> items;
  final Widget? gallery;

  const ProductInfoGrid({super.key, required this.items, this.gallery});

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUI.gridColumns(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: AppColors.shadowGray[200]!),
      ),
      child: Column(
        children: [
          // Grid items
          ...List.generate((items.length / columns).ceil(), (index) {
            final leftIndex = index * columns;
            final rightIndex = leftIndex + 1;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < (items.length / columns).ceil() - 1
                    ? ResponsiveUI.spacing(context, 16)
                    : 0,
              ),
              child: Row(
                children: [
                  Expanded(child: items[leftIndex]),
                  if (rightIndex < items.length) ...[
                    SizedBox(width: ResponsiveUI.spacing(context, 16)),
                    Expanded(child: items[rightIndex]),
                  ] else
                    const Expanded(child: SizedBox()),
                ],
              ),
            );
          }),
          
          // Gallery section
          if (gallery != null) ...[
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            gallery!,
          ],
        ],
      ),
    );
  }
}