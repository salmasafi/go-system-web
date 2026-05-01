// // lib/features/pos/home/presentation/widgets/warhouse_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
// import 'package:systego/features/pos/home/cubit/pos_home_cubit.dart';
// import 'package:systego/features/pos/home/cubit/pos_home_state.dart';
// import '../../../../../core/constants/app_colors.dart';
// import '../../../../../core/utils/responsive_ui.dart';
// import 'selection_option.dart';

// class POSWarhouseDialog extends StatelessWidget {
//   const POSWarhouseDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(
//           ResponsiveUI.borderRadius(context, 20),
//         ),
//       ),
//       title: Row(
//         children: [
//           Icon(Icons.warehouse, color: AppColors.primaryBlue),
//           SizedBox(width: ResponsiveUI.spacing(context, 12)),
//           Text(
//             'Select Warehouse',
//             style: TextStyle(
//               fontSize: ResponsiveUI.fontSize(context, 20),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       content: SizedBox(
//         // <-- Constrain height
//         width: double.maxFinite,
//         height: MediaQuery.of(context).size.height * 0.5, // 50% of screen
//         child: BlocBuilder<PosCubit, PosState>(
//           builder: (context, state) {
//             final cubit = context.read<PosCubit>();
//             final warehouses = cubit.warehouses;

//             if (warehouses.isEmpty) {
//               return CustomEmptyState(
//                 icon: Icons.inventory_2_outlined,
//                 title: 'No Warehouses Found',
//                 message: 'Pull to refresh or check your connection',
//                 actionLabel: 'Retry',
//                 onAction: () => cubit.loadPosData(),
//               );
//             }

//             return ListView.builder(
//               itemCount: warehouses.length,
//               itemBuilder: (context, index) {
//                 final warehouse = warehouses[index];
//                 return POSSelectionOption(
//                   label: warehouse.name,
//                   icon: Icons.warehouse,
//                   onTap: () {
//                     cubit.changeWarhouseValue(warehouse);
//                     Navigator.pop(context);
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel', style: TextStyle(color: AppColors.black)),
//         ),
//       ],
//     );
//   }
// }
