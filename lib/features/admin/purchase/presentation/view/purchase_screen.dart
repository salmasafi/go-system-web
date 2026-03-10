// import 'package:flutter/material.dart';

// import '../../../../../core/constants/app_colors.dart';

// class PurchaseScreen extends StatelessWidget {
//   const PurchaseScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.white,
//       ),
//     );
//   }
// }


import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:systego/features/admin/purchase/presentation/view/create_purchase_screen.dart';
import 'package:systego/features/admin/purchase/presentation/widgets/purchase_list_screen.dart';

import 'package:systego/generated/locale_keys.g.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  
  void purchasesInit() async {
    // Assuming you have this method in your cubit
    context.read<PurchaseCubit>().getAllPurchases(); 
  }

  @override
  void initState() {
    super.initState();
    purchasesInit();
  }

  Future<void> _refresh() async {
    purchasesInit();
  }

  Widget _buildListContent() {
    return BlocConsumer<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is GetPurchasesError) {
          CustomSnackbar.showError(context, state.error);
        } else if (state is DeletePurchaseError) {
          CustomSnackbar.showError(context, state.error);
          purchasesInit();
        } else if (state is DeletePurchaseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          purchasesInit();
        } 
        // Add Create/Update listeners if you implement those screens
      },
      builder: (context, state) {
        if (state is GetPurchasesLoading || state is DeletePurchaseLoading) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.primaryBlue,
            child: CustomLoadingShimmer(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            ),
          );
        } else if (state is GetPurchasesSuccess) {
          // Assuming your state has a combined list or you choose one (e.g. state.purchases.partial)
          // For this example, I assume the cubit flattens them or you pick one list
          final purchases = state.data; 
   
          if (purchases.purchases.partial.isEmpty) {
            return CustomEmptyState(
              icon: Icons.shopping_bag_outlined,
              title: "No Purchases Found", // Use LocaleKeys
              message: "No purchase records available", // Use LocaleKeys
              onRefresh: _refresh,
              actionLabel: LocaleKeys.retry.tr(),
              onAction: _refresh,
            );
          } else {
            return RefreshIndicator(
              onRefresh: _refresh,
              color: AppColors.primaryBlue,
              child: PurchaseList(purchases: purchases.purchases.partial),
            );
          }
        } else {
          return CustomEmptyState(
            icon: Icons.shopping_bag_outlined,
            title: "No Purchases Found",
            message: LocaleKeys.no_popups_default_message.tr(), // Adjust key
            onRefresh: _refresh,
            actionLabel: LocaleKeys.retry.tr(),
            onAction: _refresh,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: "Purchases", // Use LocaleKeys.purchases
        showActions: true,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePurchaseScreen()),
          );
          if (result == true && mounted) {
            purchasesInit();
          }
        },
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: AnimatedElement(
            delay: const Duration(milliseconds: 200),
            child: _buildListContent(),
          ),
        ),
      ),
    );
  }
}