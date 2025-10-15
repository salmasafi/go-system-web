import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_text_field_widget.dart';
import 'package:systego/features/home/presentation/screens/categories_screen/view/widgets/category_card_widget.dart';
import 'package:systego/features/home/presentation/screens/categories_screen/view/widgets/delete_category_dialog.dart';
import '../../../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../../../core/widgets/custom_error/custom_error_state.dart';
import '../../../../../../core/widgets/custom_loading/custom_loading_state.dart';
import '../logic/cubit/categories_cubit.dart';
import '../logic/cubit/categories_states.dart';
import '../logic/model/get_categories_model.dart';
import 'create_category_screen.dart';
import 'edit_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = TextEditingController();
  String _searchQuery = '';

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
        .where((cat) => cat.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is DeleteCategorySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          CategoriesCubit.get(context).getCategories();
        } else if (state is DeleteCategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
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
                    horizontal: ResponsiveUI.horizontalPadding(context),
                    vertical: ResponsiveUI.spacing(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: ResponsiveUI.borderRadius(context, 8),
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
                Expanded(
                  child: BlocBuilder<CategoriesCubit, CategoriesState>(
                    builder: (context, state) {
                      if (state is GetCategoriesLoading) {
                        return Center(
                          child: CustomLoadingState(
                            size: ResponsiveUI.iconSize(context, 60),
                          ),
                        );
                      }

                      if (state is GetCategoriesError) {
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
                            horizontal: ResponsiveUI.horizontalPadding(context),
                            vertical: ResponsiveUI.spacing(context, 8),
                          ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
                              child: CategoryCardWidget(
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
                                        CategoriesCubit.get(context).deleteCategory(
                                          filteredCategories[index].id,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
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