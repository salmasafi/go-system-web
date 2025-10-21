import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/features/home/presentation/screens/brands_screen/view/create_brand_screen.dart';
import 'package:systego/features/product/presentation/widgets/search_bar_widget.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
import '../logic/cubit/brand_cubit.dart';
import '../logic/cubit/brand_states.dart';
import '../logic/model/get_brands_model.dart';
import 'edit_brand_screen.dart';
import 'widgets/brand_card_widget.dart';
import 'widgets/delete_brand_widget.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  String _searchQuery = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    BrandsCubit.get(context).getBrands();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
    });
    await BrandsCubit.get(context).getBrands();
  }

  Widget _buildListContent(BrandsState state) {
    if (state is GetBrandsLoading) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: const CustomLoadingShimmer(),
      );
    }

    if (state is GetBrandsError) {
      return CustomEmptyState(
        icon: Icons.branding_watermark,
        title: 'Error Occurred',
        message: state.error,
        onRefresh: _refresh,
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    }

    final cubit = BrandsCubit.get(context);
    final brands = cubit.allBrands;

    List<Brands> filteredBrands = brands
        .where(
          (brand) => (brand.name ?? '').toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();

    if (filteredBrands.isEmpty) {
      String title = brands.isEmpty
          ? 'No Brands Available'
          : 'No Matching Brands';
      String message = brands.isEmpty
          ? 'Add your first brand to get started'
          : 'Try adjusting your search terms';
      return CustomEmptyState(
        icon: Icons.branding_watermark,
        title: title,
        message: message,
        onRefresh: _refresh,
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        itemCount: filteredBrands.length,
        itemBuilder: (context, index) {
          return AnimatedBrandCard(
            brand: filteredBrands[index],
            index: index,
            onEdit: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    BrandsCubit.get(
                      context,
                    ).deleteBrand(filteredBrands[index].id ?? '');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, "Brands", () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBrandScreen()),
        );
        if (result == true && mounted) {
          BrandsCubit.get(context).getBrands();
        }
      }, showActions: true),
      body: BlocConsumer<BrandsCubit, BrandsState>(
        listener: (context, state) {
          if (state is DeleteBrandSuccess) {
            _showSuccessSnackbar(context, state.message);
            BrandsCubit.get(context).getBrands();
          } else if (state is DeleteBrandError) {
            CustomSnackbar.showError(context, state.error);
          } else if (state is GetBrandsError) {
            CustomSnackbar.showError(context, state.error);
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUI.contentMaxWidth(context),
              ),
              child: Column(
                children: [
                  AnimatedElement(
                    delay: Duration.zero,
                    child: SearchBarWidget(
                      onChanged: (String query) {
                        setState(() {
                          _searchQuery = query.toLowerCase().trim();
                        });
                      },
                      controller: controller,
                      text: 'brands',
                    ),
                  ),
                  Expanded(
                    child: AnimatedElement(
                      delay: const Duration(milliseconds: 200),
                      child: _buildListContent(state),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
