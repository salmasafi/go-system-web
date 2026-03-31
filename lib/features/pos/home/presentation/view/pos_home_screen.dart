import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/POS/history/cubit/history_cubit.dart';
import 'package:systego/features/POS/history/cubit/history_state.dart';
import 'package:systego/features/POS/history/presentation/views/pending_orders_screen.dart';
import 'package:systego/features/admin/dashboard/cubit/notifications_cubit.dart';
import 'package:systego/features/admin/dashboard/presentation/view/notifications_screen.dart';

// Cubits
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/shift/cubit/pos_shift_cubit.dart';
import 'package:systego/features/POS/customer/cubit/pos_customer_cubit.dart';

// Models
import 'package:systego/features/POS/home/model/pos_models.dart';

// Services & Screens
import '../../../../admin/product/presentation/screens/barcode_scanner_screen.dart';
import '../../../checkout/presentation/widgets/cart_bottom_sheet.dart';
import '../../../checkout/presentation/widgets/cart_fab.dart';
import '../../../checkout/presentation/widgets/cart_summary.dart';
import '../../../shift/presentation/views/cashier_selection_screen.dart';
import '../../../shift/presentation/views/start_shift_screen.dart';

// Widgets
import '../widgets/filter_by_category_brand_widgets.dart';
import '../widgets/header_section.dart';
import '../widgets/pos_drawer.dart';
import '../widgets/product_details_dialog.dart';
import '../widgets/product_grid.dart';
import '../widgets/tab_bar.dart';
import '../widgets/variation_selector_dialog.dart';
import '../widgets/bundles_grid.dart';

class POSHomeScreen extends StatefulWidget {
  const POSHomeScreen({super.key});

  @override
  State<POSHomeScreen> createState() => _POSHomeScreenState();
}

class _POSHomeScreenState extends State<POSHomeScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _shiftTimer;
  String _shiftDuration = "00:00:00";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final shiftCubit = context.read<PosShiftCubit>();
    final homeCubit = context.read<PosCubit>();

    if (shiftCubit.isShiftOpen) {
      homeCubit.loadPosData();
      context.read<PosCustomerCubit>().fetchCustomers();
      _startLocalTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _shiftTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startLocalTimer();
    }
  }

  void _startLocalTimer() {
    _shiftTimer?.cancel();

    void updateTime() {
      final cubit = context.read<PosShiftCubit>();
      if (cubit.isShiftOpen && cubit.currentShift != null) {
        final duration = DateTime.now().difference(cubit.currentShift!.startTime);
        if (mounted) {
          setState(() => _shiftDuration = _formatDuration(duration));
        }
      }
    }

    updateTime();
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  String _formatDuration(Duration duration) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}";
  }

  void _addToCart(Product product) {
    final checkoutCubit = context.read<CheckoutCubit>();
    final posCubit = context.read<PosCubit>();

    if (product.differentPrice && product.prices.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => VariationSelectorDialog(
          product: product,
          onVariationSelected: (variation) {
            checkoutCubit.addToCart(product, variation: variation);
            posCubit.selectTab(tab: posCubit.selectedTab, noFliterRefresh: true);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => ProductDetailsDialog(
          product: product,
          onAddToCart: () {
            checkoutCubit.addToCart(product);
            posCubit.selectTab(tab: posCubit.selectedTab, noFliterRefresh: true);
          },
        ),
      );
    }
  }

  void _showCartDialog() {
    final posCubit = context.read<PosCubit>();
    final checkoutCubit = context.read<CheckoutCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => POSCartBottomSheet(
        onQuantityChanged: (index, delta) {
          checkoutCubit.updateQuantity(index, delta);
          posCubit.refreshCartProducts();
        },
        onRemove: (index) {
          checkoutCubit.removeFromCart(index);
          posCubit.refreshCartProducts();
        },
      ),
    );
  }

  double get _total => context.read<CheckoutCubit>().cartItems.fold(
        0,
        (s, i) => s + i.effectivePrice * i.quantity,
      );

  void _handleBarcodeScan(String code) async {
    final posCubit = context.read<PosCubit>();
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    final product = await posCubit.getProductByCode(code);
    if (product != null && mounted) {
      _addToCart(product);
    }
  }

  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      return _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.price.toString().contains(_searchQuery.toLowerCase()) ||
          product.prices.any(
            (v) => v.code.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PosShiftCubit, PosShiftState>(
          listener: (context, state) {
            if (state is PosShiftActionError) {
              CustomSnackbar.showError(context, state.message);
            }
            if (state is PosSelectCashierError) {
              CustomSnackbar.showError(context, state.message);
            }
            if (state is PosShiftStarted) {
              context.read<PosCubit>().loadPosData();
              context.read<PosCustomerCubit>().fetchCustomers();
              _startLocalTimer();
            }
            if (state is PosShiftEnded) {
              _shiftTimer?.cancel();
              context.read<PosCustomerCubit>().clearAll();
            }
          },
        ),
        BlocListener<PosCubit, PosState>(
          listener: (context, state) {
            if (state is PosError) {
              CustomSnackbar.showError(
                context,
                ErrorHandler.handleError(state.message),
              );
            }
          },
        ),
        BlocListener<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              context.read<PosCustomerCubit>().clearSelectedCustomer();
            }
          },
        ),
      ],
      child: BlocBuilder<PosShiftCubit, PosShiftState>(
        builder: (context, state) {
          final shiftCubit = context.read<PosShiftCubit>();

          if (shiftCubit.selectedCashier == null) {
            return const CashierSelectionScreen();
          }

          if (!shiftCubit.isShiftOpen) {
            return const StartShiftScreen();
          }

          return _buildPosLayout(shiftCubit);
        },
      ),
    );
  }

  Widget _buildPosLayout(PosShiftCubit shiftCubit) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, checkoutState) {
        final checkoutCubit = context.read<CheckoutCubit>();
        final cartItems = checkoutCubit.cartItems;
        final bool hasItems = cartItems.isNotEmpty;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.lightBlueBackground,
          drawer: POSDrawer(shiftDuration: _shiftDuration),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, notifState) {
                final unreadCount =
                    notifState is NotificationsSuccess ? notifState.unreadCount : 0;

                return AppBar(
                  scrolledUnderElevation: 1,
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  leading: Container(
                    margin: EdgeInsetsDirectional.only(
                        start: ResponsiveUI.padding(context, 8), top: ResponsiveUI.padding(context, 8), bottom: ResponsiveUI.padding(context, 8)),
                    decoration: BoxDecoration(
                      color: AppColors.lightBlueBackground,
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.menu_rounded,
                          color: AppColors.primaryBlue),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shiftCubit.selectedCashier?.name ?? "Cashier",
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveUI.fontSize(context, 15),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  titleSpacing: 0,
                  // Timer in center
                  flexibleSpace: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 120)),
                        child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUI.padding(context, 12), vertical: ResponsiveUI.padding(context, 5)),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBackground,
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: ResponsiveUI.iconSize(context, 18), color: AppColors.primaryBlue),
                            SizedBox(width: ResponsiveUI.value(context, 6)),
                            Text(
                              _shiftDuration,
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 17),
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                    ),
                  ),
                  actions: [
                    // Pending Orders button
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          end: ResponsiveUI.padding(context, 4), top: ResponsiveUI.padding(context, 8), bottom: ResponsiveUI.padding(context, 8)),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      ),
                      child: BlocBuilder<HistoryCubit, HistoryState>(
                        buildWhen: (p, c) => c is PendingLoaded,
                        builder: (context, state) {
                          final count = state is PendingLoaded
                              ? state.pendingSales.length
                              : 0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PendingOrdersScreen()),
                                ),
                                icon: Icon(
                                  Icons.pending_actions_rounded,
                                  color: Colors.orange.shade700,
                                  size: ResponsiveUI.iconSize(context, 24),
                                ),
                                padding: EdgeInsets.zero,
                                tooltip: 'Pending Orders',
                              ),
                              if (count > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade700,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.white, width: ResponsiveUI.value(context, 1.5)),
                                    ),
                                    constraints: const BoxConstraints(
                                        minWidth: 18, minHeight: 18),
                                    child: Center(
                                      child: Text(
                                        '$count',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ResponsiveUI.fontSize(context, 9),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Notification Bell
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          end: ResponsiveUI.padding(context, 8), top: ResponsiveUI.padding(context, 8), bottom: ResponsiveUI.padding(context, 8)),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightBlueBackground,
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen()),
                              ),
                              icon: Icon(
                                Icons.notifications_outlined,
                                color: AppColors.mediumBlue700[700],
                                size: ResponsiveUI.iconSize(context, 25),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
                                decoration: BoxDecoration(
                                  color: AppColors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.white, width: ResponsiveUI.value(context, 2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.red.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                    minWidth: 20, minHeight: 20),
                                child: Center(
                                  child: Text(
                                    unreadCount > 99 ? '99+' : '$unreadCount',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: ResponsiveUI.fontSize(context, 10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          body: _buildPosBody(context.read<PosCubit>()),
          bottomSheet: hasItems ? POSCartSummary(total: _total) : null,
          floatingActionButton: hasItems
              ? AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: POSCartFAB(
                    itemCount: cartItems.fold(0, (s, i) => s + i.quantity),
                    onPressed: _showCartDialog,
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildPosBody(PosCubit homeCubit) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        if (state is PosLoading) {
          return const CustomLoadingState();
        }

        return Column(
          children: [
            POSHeaderSection(
              searchController: _searchController,
              onChanged: (query) => setState(() => _searchQuery = query),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                );
                if (result != null && result is String && result != '-1') {
                  _handleBarcodeScan(result);
                }
              },
            ),
            const POSTabBar(),
            const POSFilterBar(),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state is PosBundlesLoaded) {
                    return POSBundlesGrid(bundles: state.bundles);
                  }
                  if (state is PosDataLoaded) {
                    final filtered = _filterProducts(state.displayedProducts);
                    return POSProductGrid(filteredProducts: filtered);
                  }
                  return const POSProductGrid(filteredProducts: []);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
