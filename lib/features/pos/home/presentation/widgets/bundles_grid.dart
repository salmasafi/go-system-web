import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/features/pos/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:GoSystem/features/pos/home/model/pos_models.dart';
import 'bundle_card.dart';
import 'bundle_attribute_selection_dialog.dart';
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUI.isMobile(context) ? 2 : 4,
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
          onAddToCart: () => _handleAddBundle(context, bundle),
        );
      },
    );
  }

  void _showBundleDetails(BuildContext context, BundleModel bundle) {
    showDialog(
      context: context,
      builder: (_) => BundleDetailsDialog(
        bundle: bundle,
        onAddToCart: () => _handleAddBundle(context, bundle),
      ),
    );
  }

  /// Determines whether any product in the bundle requires attribute selection.
  /// If yes → show BundleAttributeSelectionDialog.
  /// If no  → add directly to cart.
  void _handleAddBundle(BuildContext context, BundleModel bundle) {
    final hasAnyAttributes =
        bundle.products.any((p) => p.hasAttributes);

    if (hasAnyAttributes) {
      showDialog(
        context: context,
        builder: (_) => BundleAttributeSelectionDialog(
          bundle: bundle,
          onAttributesSelected: (bundleProductAttributes) {
            context.read<CheckoutCubit>().addBundleToCart(
                  bundle,
                  bundleProductAttributes: bundleProductAttributes,
                );
          },
        ),
      );
    } else {
      context.read<CheckoutCubit>().addBundleToCart(bundle);
    }
  }
}

