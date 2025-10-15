import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/core/widgets/custom_text_field_widget.dart';
import 'package:systego/features/home/presentation/screens/brands_screen/logic/model/get_brands_model.dart';

import '../../../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../../../core/widgets/custom_error/custom_error_state.dart';
import '../../../../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../../logic/cubit/brand_cubit.dart';
import '../../logic/cubit/brand_states.dart';
import '../create_brand.dart';
import '../edit_brand_screen.dart';
import 'delete_brand_widget.dart';

class BrandCardWidget extends StatelessWidget {
  final Brands brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BrandCardWidget({
    super.key,
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _buildBrandLogo(context),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(child: _buildBrandInfo(context)),
          CustomPopupMenu(
            onEdit: onEdit,
            onDelete: onDelete,
            backgroundColor: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogo(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 60),
      height: ResponsiveUI.value(context, 60),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 8),
        ),
        child: brand.logo != null && brand.logo!.isNotEmpty
            ? Image.network(
                brand.logo!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.branding_watermark,
                  color: Colors.grey,
                  size: ResponsiveUI.iconSize(context, 24),
                ),
              )
            : Icon(
                Icons.branding_watermark,
                color: Colors.grey,
                size: ResponsiveUI.iconSize(context, 24),
              ),
      ),
    );
  }

  Widget _buildBrandInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brand.name ?? '',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 4)),
        Text(
          'Created: ${_formatDate(brand.createdAt)}',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 12),
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final _controller = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    BrandsCubit.get(context).getBrands();
    _controller.addListener(() {
      setState(() => _searchQuery = _controller.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Brands> _getFilteredBrands(List<Brands> brands) {
    if (_searchQuery.isEmpty) return brands;
    return brands
        .where(
          (brand) => (brand.name ?? '').toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BrandsCubit, BrandsState>(
      listener: (context, state) {
        if (state is DeleteBrandSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          BrandsCubit.get(context).getBrands();
        } else if (state is DeleteBrandError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: appBarWithActions(context, "Brands", () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddBrandScreen()),
          );
          if (result == true && mounted) {
            BrandsCubit.get(context).getBrands();
          }
        }, showActions: true),
        backgroundColor: Colors.grey[100],
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUI.contentMaxWidth(context),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                    vertical: ResponsiveUI.spacing(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: _controller,
                    labelText: '',
                    hintText: 'Search brands...',
                    prefixIcon: Icons.search,
                    hasBoxDecoration: false,
                    hasBorder: false,
                    prefixIconColor: AppColors.darkGray.withOpacity(0.7),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<BrandsCubit, BrandsState>(
                    builder: (context, state) {
                      if (state is GetBrandsLoading) {
                        return const Center(child: CustomLoadingState());
                      }

                      if (state is GetBrandsError) {
                        return CustomErrorState(
                          message: state.error,
                          onRetry: () => BrandsCubit.get(context).getBrands(),
                        );
                      }

                      final cubit = BrandsCubit.get(context);
                      final filteredBrands = _getFilteredBrands(
                        cubit.allBrands,
                      );

                      if (filteredBrands.isEmpty) {
                        return CustomEmptyState(
                          icon: _searchQuery.isEmpty
                              ? Icons.branding_watermark
                              : Icons.search_off,
                          title: _searchQuery.isEmpty
                              ? 'No Brands Available'
                              : 'No Results Found',
                          message: _searchQuery.isEmpty
                              ? 'Add a new brand to get started'
                              : 'No brands match "$_searchQuery"',
                          actionLabel: _searchQuery.isEmpty
                              ? 'Add a Brand'
                              : null,
                          onAction: _searchQuery.isEmpty
                              ? () =>
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddBrandScreen(),
                                      ),
                                    ).then((result) {
                                      if (result == true && mounted) {
                                        BrandsCubit.get(context).getBrands();
                                      }
                                    })
                              : null,
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        onRefresh: () => cubit.getBrands(),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 16),
                            vertical: ResponsiveUI.spacing(context, 8),
                          ),
                          itemCount: filteredBrands.length,
                          itemBuilder: (context, index) {
                            return BrandCardWidget(
                              brand: filteredBrands[index],
                              onEdit: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
                                    child: EditBrandBottomSheet(
                                      brandId: filteredBrands[index].id ?? '',
                                    ),
                                  ),
                                ).then((result) {
                                  if (result == true && mounted) {
                                    BrandsCubit.get(context).getBrands();
                                  }
                                });
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => DeleteBrandDialog(
                                    brandName: filteredBrands[index].name ?? '',
                                    onDelete: () {
                                      Navigator.pop(dialogContext);
                                      BrandsCubit.get(context).deleteBrand(
                                        filteredBrands[index].id ?? '',
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
