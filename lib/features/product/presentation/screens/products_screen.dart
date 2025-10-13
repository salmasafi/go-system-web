import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:systego/features/product/cubit/product_cubit.dart';
import 'package:systego/features/product/cubit/product_state.dart';
import 'package:systego/features/product/data/models/product_model.dart';
import 'package:systego/features/product/presentation/widgets/product_list.dart';
import '../widgets/search_bar_widget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  TextEditingController controller = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedBrandId;
  bool _showCategoriesFilter = false;
  bool _showBrandsFilter = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
      controller.clear();
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _showCategoriesFilter = false;
      _showBrandsFilter = false;
    });
    await context.read<ProductsCubit>().getProducts();
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      // Search filter
      bool matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          product.price.toString().contains(_searchQuery.toLowerCase()) ||
          product.quantity.toString().contains(_searchQuery.toLowerCase());

      // Category filter
      bool matchesCategory =
          _selectedCategoryId == null ||
          product.categoryId.any((cat) => cat.id == _selectedCategoryId);

      // Brand filter
      bool matchesBrand =
          _selectedBrandId == null || product.brandId.id == _selectedBrandId;

      return matchesSearch && matchesCategory && matchesBrand;
    }).toList();
  }

  Widget _buildListContent(ProductsState state) {
    if (state is ProductsLoading) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: const CustomLoadingShimmer(),
      );
    }

    if (state is ProductsSuccess) {
      final products = state.products;
      List<Product> displayProducts = _filterProducts(products);

      if (displayProducts.isEmpty) {
        String title = products.isEmpty
            ? 'No Products Found'
            : 'No Matching Products';
        String message = products.isEmpty
            ? 'Add your first product to get started'
            : 'Try adjusting your search or filters';
        return CustomEmptyState(
          icon: Icons.inventory_2_outlined,
          title: title,
          message: message,
          onRefresh: _refresh,
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: ProductsList(products: displayProducts),
      );
    }

    if (state is ProductsError) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: CustomEmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Error Occurred',
          message: state.message,
          onRefresh: null,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: CustomEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No Products Found',
        message: 'Pull to refresh or check your connection',
        onRefresh: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, 'Products', () {
        Navigator.pop(context);
      }),
      body: BlocConsumer<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            _showErrorSnackbar(context, state.message);
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
                      controller: controller,
                      onChanged: (String query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),
                  AnimatedElement(
                    delay: const Duration(milliseconds: 100),
                    child: FilterButtons(
                      showCategories: _showCategoriesFilter,
                      showBrands: _showBrandsFilter,
                      onCategoriesToggle: () {
                        setState(() {
                          _showCategoriesFilter = !_showCategoriesFilter;
                          if (_showCategoriesFilter) _showBrandsFilter = false;
                        });
                      },
                      onBrandsToggle: () {
                        setState(() {
                          _showBrandsFilter = !_showBrandsFilter;
                          if (_showBrandsFilter) _showCategoriesFilter = false;
                        });
                      },
                    ),
                  ),
                  if (_showCategoriesFilter && state is ProductsSuccess)
                    AnimatedElement(
                      delay: Duration.zero,
                      child: CategoriesFilterPanel(
                        products: state.products,
                        selectedCategoryId: _selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          setState(() {
                            _selectedCategoryId = categoryId;
                          });
                        },
                        onClose: () {
                          setState(() {
                            _showCategoriesFilter = false;
                          });
                        },
                      ),
                    ),
                  if (_showBrandsFilter && state is ProductsSuccess)
                    AnimatedElement(
                      delay: Duration.zero,
                      child: BrandsFilterPanel(
                        products: state.products,
                        selectedBrandId: _selectedBrandId,
                        onBrandSelected: (brandId) {
                          setState(() {
                            _selectedBrandId = brandId;
                          });
                        },
                        onClose: () {
                          setState(() {
                            _showBrandsFilter = false;
                          });
                        },
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

  void _showErrorSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error!',
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class FilterButtons extends StatelessWidget {
  final bool showCategories;
  final bool showBrands;
  final VoidCallback onCategoriesToggle;
  final VoidCallback onBrandsToggle;

  const FilterButtons({
    Key? key,
    required this.showCategories,
    required this.showBrands,
    required this.onCategoriesToggle,
    required this.onBrandsToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
        vertical: ResponsiveUI.padding(context, 8),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilterButton(
              label: 'Categories',
              isActive: showCategories,
              onTap: onCategoriesToggle,
            ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: FilterButton(
              label: 'Brands',
              isActive: showBrands,
              onTap: onBrandsToggle,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveUI.padding(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 8),
          ),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryBlue : Colors.grey[700],
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 6)),
            Icon(
              isActive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isActive ? AppColors.primaryBlue : Colors.grey[600],
              size: ResponsiveUI.iconSize(context, 20),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesFilterPanel extends StatelessWidget {
  final List<Product> products;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final VoidCallback onClose;

  const CategoriesFilterPanel({
    Key? key,
    required this.products,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onClose,
  }) : super(key: key);

  Map<String, CategoryInfo> _getUniqueCategories() {
    Map<String, CategoryInfo> categoriesMap = {};

    for (var product in products) {
      for (var category in product.categoryId) {
        if (!categoriesMap.containsKey(category.id)) {
          categoriesMap[category.id] = CategoryInfo(
            category: category,
            productCount: 1,
          );
        } else {
          categoriesMap[category.id]!.productCount++;
        }
      }
    }

    return categoriesMap;
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getUniqueCategories();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
      ),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterPanelHeader(title: 'Categories', onClose: onClose),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          SizedBox(
            height: ResponsiveUI.value(context, 200),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: ResponsiveUI.spacing(context, 12),
                mainAxisSpacing: ResponsiveUI.spacing(context, 12),
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryInfo = categories.values.elementAt(index);
                final category = categoryInfo.category;
                final isSelected = selectedCategoryId == category.id;

                return CategoryItem(
                  category: category,
                  productCount: categoryInfo.productCount,
                  isSelected: isSelected,
                  onTap: () {
                    onCategorySelected(isSelected ? null : category.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BrandsFilterPanel extends StatelessWidget {
  final List<Product> products;
  final String? selectedBrandId;
  final Function(String?) onBrandSelected;
  final VoidCallback onClose;

  const BrandsFilterPanel({
    Key? key,
    required this.products,
    required this.selectedBrandId,
    required this.onBrandSelected,
    required this.onClose,
  }) : super(key: key);

  Map<String, BrandInfo> _getUniqueBrands() {
    Map<String, BrandInfo> brandsMap = {};

    for (var product in products) {
      if (!brandsMap.containsKey(product.brandId.id)) {
        brandsMap[product.brandId.id] = BrandInfo(
          brand: product.brandId,
          productCount: 1,
        );
      } else {
        brandsMap[product.brandId.id]!.productCount++;
      }
    }

    return brandsMap;
  }

  @override
  Widget build(BuildContext context) {
    final brands = _getUniqueBrands();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUI.padding(context, 16),
      ),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterPanelHeader(title: 'Brands', onClose: onClose),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          SizedBox(
            height: ResponsiveUI.value(context, 200),
            child: ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brandInfo = brands.values.elementAt(index);
                final brand = brandInfo.brand;
                final isSelected = selectedBrandId == brand.id;

                return BrandItem(
                  brand: brand,
                  productCount: brandInfo.productCount,
                  isSelected: isSelected,
                  onTap: () {
                    onBrandSelected(isSelected ? null : brand.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterPanelHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const FilterPanelHeader({
    Key? key,
    required this.title,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 24)),
          onPressed: onClose,
        ),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final int productCount;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.productCount,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 8),
          ),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveUI.value(context, 50),
              height: ResponsiveUI.value(context, 50),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              child: category.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8),
                      ),
                      child: Image.network(
                        category.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.category,
                            size: ResponsiveUI.iconSize(context, 30),
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.category,
                      size: ResponsiveUI.iconSize(context, 30),
                      color: Colors.grey,
                    ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 6)),
            Text(
              category.name,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 11),
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryBlue : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              '$productCount',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 10),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandItem extends StatelessWidget {
  final Brand brand;
  final int productCount;
  final bool isSelected;
  final VoidCallback onTap;

  const BrandItem({
    Key? key,
    required this.brand,
    required this.productCount,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 8)),
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 8),
          ),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveUI.value(context, 40),
              height: ResponsiveUI.value(context, 40),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              child: brand.logo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8),
                      ),
                      child: Image.network(
                        brand.logo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.business,
                            size: ResponsiveUI.iconSize(context, 24),
                            color: Colors.grey,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.business,
                      size: ResponsiveUI.iconSize(context, 24),
                      color: Colors.grey,
                    ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand.name,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    '$productCount Products',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 12),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: ResponsiveUI.iconSize(context, 20),
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryInfo {
  final Category category;
  int productCount;

  CategoryInfo({required this.category, required this.productCount});
}

class BrandInfo {
  final Brand brand;
  int productCount;

  BrandInfo({required this.brand, required this.productCount});
}

class AnimatedElement extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AnimatedElement({super.key, required this.child, required this.delay});

  @override
  State<AnimatedElement> createState() => _AnimatedElementState();
}

class _AnimatedElementState extends State<AnimatedElement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}
