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

  @override
  void initState() {
    super.initState();
    context.read<ProductsCubit>().getProducts();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
      controller.clear();
    });
    await context.read<ProductsCubit>().getProducts();
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

      List<Product> displayProducts = products
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.price.toString().contains(_searchQuery.toLowerCase()) ||
                product.quantity.toString().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();

      if (displayProducts.isEmpty) {
        String title = products.isEmpty
            ? 'No Products Found'
            : 'No Matching Products';
        String message = products.isEmpty
            ? 'Add your first product to get started'
            : 'Try adjusting your search terms';
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

    // Initial state fallback
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
