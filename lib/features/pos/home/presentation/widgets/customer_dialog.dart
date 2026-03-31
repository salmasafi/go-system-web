// // ── Checkout dialog ───────────────────────────────────────────────────────
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
// import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
// import '../../../../../core/constants/app_colors.dart';
// import '../../../../../core/utils/responsive_ui.dart';
// import '../../../../../core/widgets/custom_error/custom_empty_state.dart';
// import 'selection_option.dart';

// class POSCustomerDialog extends StatelessWidget {
//   const POSCustomerDialog({super.key});

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
//           Icon(Icons.person, color: AppColors.primaryBlue),
//           SizedBox(width: ResponsiveUI.spacing(context, 12)),
//           Text(
//             'Select Customer',
//             style: TextStyle(
//               fontSize: ResponsiveUI.fontSize(context, 18),
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
//             final customers = cubit.customers;

//             if (customers.isEmpty) {
//               return CustomEmptyState(
//                 icon: Icons.attach_money_rounded,
//                 title: 'No Customers Found',
//                 message: 'Pull to refresh or check your connection',
//                 actionLabel: 'Retry',
//                 onAction: () => cubit.loadPosData(),
//               );
//             }

//             return ListView.builder(
//               itemCount: customers.length,
//               itemBuilder: (context, index) {
//                 final customer = customers[index];
//                 return POSSelectionOption(
//                   label: customer.name,
//                   icon: Icons.person,
//                   onTap: () {
//                     cubit.changeCustomerValue(customer);
//                     Navigator.pop(context);
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       actions: [
//         // TextButton(
//         //   onPressed: () => Navigator.pop(context),
//         //   child: const Text('Change Currency', style: TextStyle(color: AppColors.black)),
//         // ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel', style: TextStyle(color: AppColors.black)),
//         ),
//       ],
//     );
//   }
// }
