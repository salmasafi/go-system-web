import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/pandel/cubit/pandel_cubit.dart';
import 'package:systego/features/admin/pandel/model/pandel_model.dart';
import 'package:systego/features/admin/pandel/presentation/view/edit_pandel_screen.dart';
import 'package:systego/features/admin/pandel/presentation/widgets/animated_pandel_card.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';

class PandelsList extends StatefulWidget {
  final List<PandelModel> pandels;

  const PandelsList({super.key, required this.pandels});

  @override
  State<PandelsList> createState() => _PandelsListState();
}

class _PandelsListState extends State<PandelsList> {
  @override
  Widget build(BuildContext context) {
    if (widget.pandels.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
        bottom: ResponsiveUI.padding(context, 80), // Extra padding for FAB
      ),
      itemCount: widget.pandels.length,
      itemBuilder: (context, index) {
        final pandel = widget.pandels[index];  

        return AnimatedPandelCard(
          pandel: pandel,
          index: index,
          onDelete: () => _showDeleteDialog(context, pandel),
          onEdit: () => _navigateToEditScreen(context, pandel),
          onTap: () => _showPandelDetails(context, pandel),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark,
              size: ResponsiveUI.iconSize(context, 64),
              color: Colors.grey[400],
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Text(
              LocaleKeys.no_pandels_found.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            Text(
              LocaleKeys.create_first_pandel.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // void _showEditDialog(BuildContext context, PandelModel pandel) {
  //   // showModalBottomSheet(
  //   //   context: context,
  //   //   isScrollControlled: true,
  //   //   backgroundColor: Colors.transparent,
  //   //   builder: (context) => EditPandelScreen(pandel: pandel),
  //   // );
  //   EditPandelScreen(pandel: pandel);
  // }

    void _navigateToEditScreen(BuildContext context, PandelModel pandel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPandelScreen(pandel: pandel),
      ),
    ).then((value) {
      // If needed, refresh data when returning from edit screen
      if (value == true) {
        context.read<PandelCubit>().allPandels;
        // You can trigger a refresh here if needed
        // Example: context.read<PandelCubit>().getPandels();
      }
    });
  }

  void _showPandelDetails(BuildContext context, PandelModel pandel) {
    showDialog(
      context: context,
      builder: (context) => _buildPandelDetailsDialog(pandel),
    );
  }

  Widget _buildPandelDetailsDialog(PandelModel pandel) {
    // final now = DateTime.now();
    // final isActive = now.isAfter(pandel.startDate) && now.isBefore(pandel.endDate);
    // final isUpcoming = pandel.startDate.isAfter(now);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pandel.name,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 12),
                      vertical: ResponsiveUI.padding(context, 6),
                    ),
                    decoration: BoxDecoration(
                      color: pandel.status
                          ? Colors.green.withValues(alpha: 0.1)
                          // : isUpcoming
                          //   ? Colors.orange.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                    ),
                    child: Text(
                      pandel.status
                          ? LocaleKeys.active.tr()
                          // : isUpcoming
                          //   ? LocaleKeys.upcoming.tr()
                          : LocaleKeys.expired.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 12),
                        fontWeight: FontWeight.bold,
                        color: pandel.status
                            ? Colors.green
                            // : isUpcoming
                            //   ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Price
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: ResponsiveUI.iconSize(context, 18),
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: ResponsiveUI.spacing(context, 8)),
                  Text(
                    '\$${pandel.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 16)),

              // Products
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${LocaleKeys.products.tr()} (${pandel.products.length}):',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 10)),
                  ...pandel.products.take(10).map((product) {
                    final name = product.productName ?? product.productId;
                    final image = product.productImage;
                    final price = product.productPrice;

                    return Container(
                      margin: EdgeInsets.only(
                          bottom: ResponsiveUI.spacing(context, 8)),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 10),
                        vertical: ResponsiveUI.padding(context, 8),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
                        border: Border.all(color: AppColors.lightGray),
                      ),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                            child: image != null && image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: ResponsiveUI.value(context, 44),
                                    height: ResponsiveUI.value(context, 44),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _productPlaceholder(context),
                                  )
                                : _productPlaceholder(context),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 10)),
                          // Name + price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: ResponsiveUI.fontSize(context, 13),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGray,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (price != null)
                                  Text(
                                    '${price.toStringAsFixed(2)} EGP',
                                    style: TextStyle(
                                      fontSize: ResponsiveUI.fontSize(context, 12),
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Quantity badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUI.padding(context, 8),
                              vertical: ResponsiveUI.padding(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueBackground,
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                            ),
                            child: Text(
                              'x${product.quantity}',
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 12),
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (pandel.products.length > 10)
                    Padding(
                      padding:
                          EdgeInsets.only(top: ResponsiveUI.spacing(context, 4)),
                      child: Text(
                        '${LocaleKeys.and_more.tr()} ${pandel.products.length - 10} ${LocaleKeys.more.tr()}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 20)),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: ResponsiveUI.iconSize(context, 16),
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Text(
                              LocaleKeys.start_date.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          _formatDate(pandel.startDate),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: ResponsiveUI.spacing(context, 20)),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.event,
                              size: ResponsiveUI.iconSize(context, 16),
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: ResponsiveUI.spacing(context, 8)),
                            Text(
                              LocaleKeys.end_date.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 4)),
                        Text(
                          _formatDate(pandel.endDate),
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 16),
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: ResponsiveUI.spacing(context, 20)),

              // Images
              if (pandel.images.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${LocaleKeys.images.tr()} (${pandel.images.length}):',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: ResponsiveUI.spacing(context, 8),
                        mainAxisSpacing: ResponsiveUI.spacing(context, 8),
                        childAspectRatio: 1,
                      ),
                      itemCount: pandel.images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            border: Border.all(color: AppColors.lightGray),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            child: Image.network(
                              pandel.images[index],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[400],
                                    size: ResponsiveUI.iconSize(context, 24),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

              SizedBox(height: ResponsiveUI.spacing(context, 24)),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUI.padding(context, 14),
                    ),
                  ),
                  child: Text(
                    LocaleKeys.close.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 16),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PandelModel pandel) {
    if (pandel.id.isEmpty) {
      CustomSnackbar.showError(context, LocaleKeys.invalid_pandel_id.tr());
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: LocaleKeys.delete_pandel_title.tr(),
        message: '${LocaleKeys.delete_pandel_message.tr()}\n"${pandel.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<PandelCubit>().deletePandel(pandel.id);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _productPlaceholder(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 44),
      height: ResponsiveUI.value(context, 44),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
      ),
      child: Icon(Icons.inventory_2_outlined,
          size: ResponsiveUI.iconSize(context, 22), color: AppColors.primaryBlue),
    );
  }
}

