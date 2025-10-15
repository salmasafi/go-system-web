import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_popup_menu.dart';
import 'package:systego/core/widgets/custom_text_field_widget.dart';
import '../../../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../../../core/widgets/custom_error/custom_error_state.dart';
import '../../../../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../logic/cubit/categories_cubit.dart';
import '../../logic/cubit/categories_states.dart';
import '../../logic/model/get_categories_model.dart';
import '../create_category_screen.dart';
import '../edit_category_screen.dart';
import 'delete_category_dialog.dart';


class CategoryCardWidget extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightBlueBackground,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCategoryImage(context),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(child: _buildCategoryInfo(context)),
          CustomPopupMenu(
            onEdit: onEdit,
            onDelete: onDelete,
            backgroundColor: AppColors.white,
            backgroundColorMenu: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryImage(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 60),
      height: ResponsiveUI.value(context, 60),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
        child: Image.network(
          category.image ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.category,
            color: AppColors.lightGray,
            size: ResponsiveUI.iconSize(context, 24),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name ?? '',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (category.parentId != null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveUI.spacing(context, 4)),
            child: Text(
              'Parent category: ${category.parentId!.name}',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: AppColors.darkBlue,
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: ResponsiveUI.spacing(context, 4)),
          child: Text(
            '${category.productQuantity ?? 0} Products',
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 12),
              color: AppColors.darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = TextEditingController();
  String _searchQuery = '';
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    CategoriesCubit.get(context).getCategories();
    _controller.addListener(() {
      setState(() => _searchQuery = _controller.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<CategoryItem> _getFilteredCategories(List<CategoryItem> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories
        .where((cat) => (cat.name ?? '').toLowerCase().contains(_searchQuery))
        .toList();
  }

  void _clearMessage() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _message = null;
          _isSuccess = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is DeleteCategorySuccess) {
          setState(() {
            _message = state.message;
            _isSuccess = true;
          });
          CategoriesCubit.get(context).getCategories();
          _clearMessage();
        } else if (state is DeleteCategoryError) {
          setState(() {
            _message = state.error;
            _isSuccess = false;
          });
          _clearMessage();
        }
      },
      child: Scaffold(
        appBar: appBarWithActions(
          context,
          "Categories",
              () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCategoryScreen()),
            );
            if (result == true && mounted) {
              CategoriesCubit.get(context).getCategories();
            }
          },
          showActions: true,
        ),
        backgroundColor: Colors.grey[100],
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveUI.contentMaxWidth(context)),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                    vertical: ResponsiveUI.spacing(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
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
                    hintText: 'Search categories...',
                    prefixIcon: Icons.search,
                    hasBoxDecoration: false,
                    hasBorder: false,
                    prefixIconColor: AppColors.darkGray.withOpacity(0.7),
                  ),
                ),
                if (_message != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUI.padding(context, 16),
                      vertical: ResponsiveUI.spacing(context, 8),
                    ),
                    child: CustomErrorState(
                      message: _message!,
                      title: _isSuccess ? 'Success' : 'Error',
                      icon: _isSuccess ? Icons.check_circle : Icons.error_outline,
                      iconColor: _isSuccess ? Colors.green : AppColors.red,
                      onRetry: _isSuccess ? null : () => CategoriesCubit.get(context).getCategories(),
                    ),
                  ),
                Expanded(
                  child: BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, state) {
                      if (state is GetCategoriesLoading) {
                        return CustomLoadingShimmer(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 16),
                            vertical: ResponsiveUI.spacing(context, 8),
                          ),
                          itemCount: 5,
                        );
                      }

                      if (state is GetCategoriesError && _message == null) {
                        return CustomErrorState(
                          message: state.error,
                          onRetry: () => CategoriesCubit.get(context).getCategories(),
                        );
                      }

                      final cubit = CategoriesCubit.get(context);
                      final filteredCategories = _getFilteredCategories(cubit.allCategories);

                      if (filteredCategories.isEmpty) {
                        return CustomEmptyState(
                          icon: _searchQuery.isEmpty ? Icons.category : Icons.search_off,
                          title: _searchQuery.isEmpty ? 'No Categories Available' : 'No Results Found',
                          message: _searchQuery.isEmpty
                              ? 'Add a new category to get started'
                              : 'No categories match "$_searchQuery"',
                          actionLabel: _searchQuery.isEmpty ? 'Add a Category' : null,
                          onAction: _searchQuery.isEmpty
                              ? () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AddCategoryScreen()),
                          ).then((result) {
                            if (result == true && mounted) {
                              CategoriesCubit.get(context).getCategories();
                            }
                          })
                              : null,
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        onRefresh: () => cubit.getCategories(),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 16),
                            vertical: ResponsiveUI.spacing(context, 8),
                          ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            return CategoryCardWidget(
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
                                    categoryName: filteredCategories[index].name ?? '',
                                    onDelete: () {
                                      Navigator.pop(dialogContext);
                                      CategoriesCubit.get(context).deleteCategory(
                                        filteredCategories[index].id ?? '',
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