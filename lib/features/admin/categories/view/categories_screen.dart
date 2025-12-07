import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/admin/categories/view/widgets/category_card_widget.dart';
import 'package:systego/features/admin/categories/view/widgets/delete_category_dialog.dart';
import 'package:systego/features/admin/categories/view/create_category_screen.dart';
import 'package:systego/features/admin/categories/view/edit_category_screen.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../product/presentation/widgets/search_bar_widget.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_states.dart';
import '../model/get_categories_model.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _searchQuery = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    CategoriesCubit.get(context).getCategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
    });
    await CategoriesCubit.get(context).getCategories();
  }

  Widget _buildListContent(CategoriesState state) {
    if (state is GetCategoriesLoading) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: const CustomLoadingShimmer(),
      );
    }

    if (state is GetCategoriesError) {
      return CustomEmptyState(
        icon: Icons.category,
        title: LocaleKeys.error_occurred.tr(),
        message: state.error,
        onRefresh: _refresh,
      );
    }

    final cubit = CategoriesCubit.get(context);
    final categories = cubit.allCategories;

    List<CategoryItem> filteredCategories = categories
        .where(
          (category) =>
              category.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredCategories.isEmpty) {
      String title = categories.isEmpty
          ? LocaleKeys.no_categories_available.tr()
          : LocaleKeys.no_matching_categories.tr();
      String message = categories.isEmpty
          ? LocaleKeys.add_first_category_message.tr()
          : LocaleKeys.try_adjusting_search_terms.tr();
      return CustomEmptyState(
        icon: Icons.category,
        title: title,
        message: message,
        onRefresh: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.horizontalPadding(context),
          vertical: ResponsiveUI.spacing(context, 8),
        ),
        itemCount: filteredCategories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
            child: AnimatedCategoryCard(
              category: filteredCategories[index],
              onEdit: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: EditCategoryBottomSheet(
                      category: filteredCategories[index],
                    ),
                  ),
                ).then((result) {
                  if (result == true && mounted) {
                    CategoriesCubit.get(context).getCategories();
                  }
                });
              },
              onDelete: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => DeleteCategoryDialog(
                    categoryName: filteredCategories[index].name,
                    onDelete: () {
                      Navigator.pop(dialogContext);
                      CategoriesCubit.get(
                        context,
                      ).deleteCategory(filteredCategories[index].id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.categories_title.tr(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
          );
          if (result == true && mounted) {
            CategoriesCubit.get(context).getCategories();
          }
        },
        showActions: true,
      ),
      body: BlocConsumer<CategoriesCubit, CategoriesState>(
        listener: (context, state) {
          if (state is DeleteCategorySuccess) {
            CustomSnackbar.showSuccess(context, state.message);
            CategoriesCubit.get(context).getCategories();
          } else if (state is DeleteCategoryError) {
            CustomSnackbar.showError(context, state.error);
          } else if (state is GetCategoriesError) {
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
                      text: LocaleKeys.categories_title.tr(),
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
}
