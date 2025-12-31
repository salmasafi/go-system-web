// // lib/features/POS/home/widgets/variation_selector_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:systego/features/admin/print_labels/model/price_variation_model.dart';
// import '../../../product/models/product_model.dart';

// import '../../../../../core/constants/app_colors.dart';

// class VariationSelectorDialog extends StatefulWidget {
//   final Product product;
//   final ValueChanged<PriceVariation> onVariationSelected;

//   const VariationSelectorDialog({
//     required this.product,
//     required this.onVariationSelected,
//     super.key,
//   });

//   @override
//   State<VariationSelectorDialog> createState() =>
//       _VariationSelectorDialogState();
// }

// class _VariationSelectorDialogState extends State<VariationSelectorDialog> {
//   PriceVariation? _selectedVariation;

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Header with product info
//             _buildHeader(),

//             // Product details section
//             _buildProductDetails(),

//             const Divider(height: 1),

//             // Variations list
//             Expanded(child: _buildVariationsList()),

//             // Action buttons
//             _buildActionButtons(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.primaryBlue,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           if (widget.product.image != null)
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: AppColors.white,
//                 image: DecorationImage(
//                   image: NetworkImage(widget.product.image!),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           if (widget.product.image != null) const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.product.name,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Select your price item',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: AppColors.white.withOpacity(0.9),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.close, color: AppColors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductDetails() {
//     if (widget.product.description.isEmpty) return const SizedBox.shrink();

//     return Container(
//       padding: const EdgeInsets.all(20),
//       color: AppColors.lightBlueBackground.withOpacity(0.3),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.info_outline,
//             size: 20,
//             color: AppColors.primaryBlue,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               widget.product.description,
//               style: const TextStyle(fontSize: 14, color: AppColors.darkGray),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVariationsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: widget.product.prices.length,
//       itemBuilder: (context, index) {
//         final variation = widget.product.prices[index];
//         final isSelected = _selectedVariation == variation;

//         return GestureDetector(
//           onTap: () => setState(() => _selectedVariation = variation),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? AppColors.primaryBlue.withOpacity(0.01)
//                   : AppColors.white,
//               border: Border.all(
//                 color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
//                 width: isSelected ? 2 : 1,
//               ),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: isSelected
//                   ? [
//                       BoxShadow(
//                         color: AppColors.primaryBlue.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ]
//                   : [],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   // Radio indicator
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: isSelected
//                             ? AppColors.primaryBlue
//                             : AppColors.lightGray,
//                         width: 2,
//                       ),
//                       color: isSelected
//                           ? AppColors.primaryBlue
//                           : AppColors.white,
//                     ),
//                     child: isSelected
//                         ? const Icon(
//                             Icons.check,
//                             size: 16,
//                             color: AppColors.white,
//                           )
//                         : null,
//                   ),
//                   const SizedBox(width: 16),

//                   // Variation details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           variation.code,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? AppColors.darkBlue
//                                 : AppColors.darkGray,
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         // Quantity badge
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: variation.quantity > 0
//                                     ? AppColors.successGreen.withOpacity(0.1)
//                                     : AppColors.red.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     variation.quantity > 0
//                                         ? Icons.inventory_2
//                                         : Icons.remove_circle_outline,
//                                     size: 14,
//                                     color: variation.quantity > 0
//                                         ? AppColors.successGreen
//                                         : AppColors.red,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     'Qty: ${variation.quantity}',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: variation.quantity > 0
//                                           ? AppColors.successGreen
//                                           : AppColors.red,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         //const SizedBox(height: 8),

//                         // Variation options
//                         if (variation.variations.isNotEmpty) ...[
//                           const SizedBox(height: 8),
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 6,
//                             children: variation.variations.expand((v) {
//                               return v.options.map((opt) {
//                                 return Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 5,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.lightBlueBackground,
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(
//                                       color: AppColors.primaryBlue.withOpacity(
//                                         0.3,
//                                       ),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     '${v.name}: ${opt.name}',
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: AppColors.darkGray,
//                                     ),
//                                   ),
//                                 );
//                               });
//                             }).toList(),
//                           ),
//                         ],
//                         const SizedBox(height: 10),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? AppColors.primaryBlue
//                                 : AppColors.mediumBlue700,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             '\$${variation.price.toStringAsFixed(2)}',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.shadowGray.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: OutlinedButton(
//               onPressed: () => Navigator.pop(context),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 side: const BorderSide(color: AppColors.lightGray, width: 2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Cancel',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.darkGray,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: _selectedVariation != null
//                   ? () {
//                       widget.onVariationSelected(_selectedVariation!);
//                       Navigator.pop(context);
//                     }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: AppColors.primaryBlue,
//                 disabledBackgroundColor: AppColors.lightGray,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: _selectedVariation != null ? 2 : 0,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.shopping_cart,
//                     size: 20,
//                     color: _selectedVariation != null
//                         ? AppColors.white
//                         : AppColors.darkGray,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Add to Cart',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _selectedVariation != null
//                           ? AppColors.white
//                           : AppColors.darkGray,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
