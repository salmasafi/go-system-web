import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import 'bundle_card.dart';
import 'bundle_details_dialog.dart';

class POSBundlesGrid extends StatelessWidget {
  final List<BundleModel> bundles;

  const POSBundlesGrid({super.key, required this.bundles});

  @override
  Widget build(BuildContext context) {
    if (bundles.isEmpty) {
      return const CustomEmptyState(
        icon: Icons.card_giftcard,
        title: 'No Bundles Available',
      );
    }

    return GridView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
        bottom: ResponsiveUI.padding(context, 75),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: bundles.length,
      itemBuilder: (_, i) {
        final bundle = bundles[i];
        return BundleCard(
          bundle: bundle,
          index: i,
          onTap: () => _showBundleDetails(context, bundle),
          onAddToCart: () => _addBundleToCart(context, bundle),
        );
      },
    );
  }

  void _showBundleDetails(BuildContext context, BundleModel bundle) {
    showDialog(
      context: context,
      builder: (_) => BundleDetailsDialog(
        bundle: bundle,
        onAddToCart: () => _addBundleToCart(context, bundle),
      ),
    );
  }

  void _addBundleToCart(BuildContext context, BundleModel bundle) {
    context.read<CheckoutCubit>().addBundleToCart(bundle);
  }
}
