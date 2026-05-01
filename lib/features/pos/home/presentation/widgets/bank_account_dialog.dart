// // pos_account_dialog.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
// import 'package:GoSystem/features/pos/home/cubit/pos_home_state.dart';
// import '../../../../../core/constants/app_colors.dart';

// class POSBankAccountDialog extends StatelessWidget {
//   const POSBankAccountDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Select Account'),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: BlocBuilder<PosCubit, PosState>(
//           builder: (context, state) {
//             final accounts = context.read<PosCubit>().accounts;
//             if (accounts.isEmpty) return Text('No accounts found');
//             return ListView.builder(
//               shrinkWrap: true,
//               itemCount: accounts.length,
//               itemBuilder: (context, i) {
//                 final acc = accounts[i];
//                 return ListTile(
//                   leading: Icon(Icons.account_balance_wallet, color: AppColors.categoryPurple),
//                   title: Text(acc.name),
//                   trailing: context.read<PosCubit>().selectedAccount?.id == acc.id
//                       ? Icon(Icons.check, color: AppColors.successGreen)
//                       : null,
//                   onTap: () {
//                     context.read<PosCubit>().changeAccount(acc);
//                     Navigator.pop(context);
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
