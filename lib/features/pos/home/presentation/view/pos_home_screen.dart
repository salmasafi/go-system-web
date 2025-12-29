import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/core/widgets/custom_error/custom_empty_state.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/home/model/pos_models.dart';
import '../../../../../core/services/cache_helper.dart';
import '../../../../../main.dart';
import '../../../../admin/auth/presentation/view/login_screen.dart';
import '../../../../admin/product/presentation/screens/barcode_scanner_screen.dart';
import '../../../checkout/presentation/widgets/cart_bottom_sheet.dart';
import '../../../checkout/presentation/widgets/cart_fab.dart';
import '../../../checkout/presentation/widgets/cart_summary.dart';
import '../widgets/filter_by_category_brand_widgets.dart';
import '../widgets/header_section.dart';
import '../widgets/product_details_dialog.dart';
import '../widgets/product_grid.dart';
import '../widgets/tab_bar.dart';
import '../widgets/variation_selector_dialog.dart';

class POSHomeScreen extends StatefulWidget {
  const POSHomeScreen({super.key});

  @override
  State<POSHomeScreen> createState() => _POSHomeScreenState();
}

class _POSHomeScreenState extends State<POSHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _shiftTimer;
  String _shiftDuration = "00:00:00";

  @override
  void initState() {
    super.initState();
    context.read<PosCubit>().loadPosData();
    _startLocalTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shiftTimer?.cancel();
    super.dispose();
  }

  // ─── Shift Timer Logic ───
  void _startLocalTimer() {
    _shiftTimer?.cancel();
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final cubit = context.read<PosCubit>();
      if (cubit.isShiftOpen && cubit.currentShift != null) {
        final duration = DateTime.now().difference(
          cubit.currentShift!.startTime,
        );
        if (mounted) {
          setState(() {
            _shiftDuration = _formatDuration(duration);
          });
        }
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // ─── Cart & Barcode Logic ───
  void _addToCart(Product product) {
    // ... (نفس الكود السابق الخاص بك)
    final checkoutCubit = context.read<CheckoutCubit>();
    final posCubit = context.read<PosCubit>();

    if (product.differentPrice && product.prices.isNotEmpty) {
      showDialog(
        context: context,
        builder: (_) => VariationSelectorDialog(
          product: product,
          onVariationSelected: (variation) {
            checkoutCubit.addToCart(product, variation: variation);
            posCubit.selectTab(
              tab: posCubit.selectedTab,
              noFliterRefresh: true,
            );
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
            posCubit.selectTab(
              tab: posCubit.selectedTab,
              noFliterRefresh: true,
            );
          },
        ),
      );
    }
  }

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

  double get _total => context.read<CheckoutCubit>().cartItems.fold(
    0,
    (s, i) => s + i.product.price * i.quantity,
  );

  List<Product> _filterProducts(List<Product> products) {
    // ... (نفس كود الفلتر السابق)
    return products.where((product) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.price.toString().contains(_searchQuery.toLowerCase()) ||
          product.prices.any(
            (v) => v.code.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      return matchesSearch;
    }).toList();
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

  // ─── UI Handling Methods ───

  // دالة لعرض التقرير بعد انتهاء الشيفت
  void _showReportDialog(Map<String, dynamic> reportData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Shift Ended & Report"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Sales: ${reportData['total_sale_amount'] ?? 0}"),
            Text("Cash in Drawer: ${reportData['net_cash_in_drawer'] ?? 0}"),
            // يمكنك إضافة المزيد من التفاصيل هنا
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PosCubit>().loadPosData(); // العودة لاختيار الكاشير
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PosCubit, PosState>(
      listener: (context, state) {
        if (state is PosError) {
          CustomSnackbar.showError(
            context,
            ErrorHandler.handleError(state.message),
          );
        }
        if (state is PosShiftEnded) {
          // يمكن استدعاء الـ Dialog هنا إذا كان التقرير في الـ state
        }
      },
      builder: (context, state) {
        final cubit = context.read<PosCubit>();
        final checkoutCubit = context.read<CheckoutCubit>();
        final cartItems = checkoutCubit.cartItems;

        return Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          // ─── 1. تعديل الـ AppBar ───
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              //forceMaterialTransparency: true,
              scrolledUnderElevation: 1,
              backgroundColor: Colors.white,
              elevation: 0,
              // عرض اسم الكاشير بدلاً من المستخدم
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cubit.selectedCashier?.name ?? "Select Cashier",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (cubit.isShiftOpen)
                    Text(
                      "Shift Time: $_shiftDuration",
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                ],
              ),
              actions: [
                if (cubit.isShiftOpen) ...[
                  // زر إنهاء الشيفت
                  IconButton(
                    icon: const Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.red,
                    ),
                    tooltip: "End Shift",
                    onPressed: () async {
                      // تأكيد إنهاء الشيفت
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("End Shift?"),
                          content: const Text(
                            "Are you sure you want to end this shift and generate report?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("End Shift"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        //final report =
                        await cubit.endShift();
                        // if (report != null && mounted) {
                        //   _showReportDialog(report);
                        // }
                        // navigatorKey.currentState?.pushAndRemoveUntil(
                        //   MaterialPageRoute(
                        //     builder: (context) => const LoginScreen(),
                        //   ),
                        //   (route) => false,
                        // );
                      }
                    },
                  ),
                  // زر تسجيل الخروج (Logout)
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    tooltip: "Logout (Keep Shift Open)",
                    onPressed: () async {
                      cubit.logoutShift();
                      await CacheHelper.clearAllData();
                      navigatorKey.currentState?.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                      // هنا يجب عليك توجيه المستخدم لصفحة تسجيل الدخول
                    },
                  ),
                ],
              ],
            ),
          ),

          body: _buildBody(cubit, state, cartItems),

          // ... (Cart FAB & BottomSheet logic remains same)
          bottomSheet: (cubit.isShiftOpen && cartItems.isNotEmpty)
              ? POSCartSummary(total: _total)
              : null,
          floatingActionButton: (cubit.isShiftOpen && cartItems.isNotEmpty)
              ? AnimatedOpacity(
                  opacity: cartItems.isNotEmpty ? 1.0 : 0.0,
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

  // ─── Main Body Logic ───
  Widget _buildBody(PosCubit cubit, PosState state, List<dynamic> cartItems) {
    if (state is PosLoading) {
      return const CustomLoadingState();
    }

    // الحالة 1: لم يتم اختيار كاشير بعد
    if (cubit.selectedCashier == null) {
      return _buildCashierSelectionList(cubit);
    }

    // الحالة 2: تم اختيار كاشير، لكن الشيفت مغلق
    if (!cubit.isShiftOpen) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront,
              size: 80,
              color: AppColors.primaryBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              "Hello, ${cubit.selectedCashier!.name}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Start your shift to begin selling"),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await cubit.startShift();
                _startLocalTimer(); // Start UI timer
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("START SHIFT"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // إلغاء اختيار الكاشير
                setState(() {
                  cubit.selectedCashier = null;
                });
                cubit.getCashiers();
              },
              child: const Text("Change Cashier"),
            ),
          ],
        ),
      );
    }

    // الحالة 3: الشيفت مفتوح (عرض محتوى الـ POS الطبيعي)
    return Column(
      children: [
        // Search + Header
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

        // Tabs
        const POSTabBar(),

        // Filter Panel
        const POSFilterBar(),

        // Product Grid
        Expanded(
          child: Builder(
            builder: (context) {
              if (state is PosProductsLoading) {
                return const CustomLoadingState();
              }

              if (state is PosDataLoaded &&
                  state.displayedProducts.isNotEmpty) {
                return POSProductGrid(
                  products: _filterProducts(state.displayedProducts),
                  onProductTap: _addToCart,
                );
              } else if (cubit.showBrandFilters || cubit.showCategoryFilters) {
                return const SizedBox();
              }

              return const CustomEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No Products Found',
                message: 'Try adjusting your search or filters',
              );
            },
          ),
        ),
      ],
    );
  }

  // ويدجت لعرض قائمة الكاشير
  Widget _buildCashierSelectionList(PosCubit cubit) {
    if (cubit.cashiersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_mall_directory_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 10),
            const Text("No Cashiers Found in this Warehouse"),
            IconButton(
              onPressed: () => cubit.getCashiers(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // const Padding(
        //   padding: EdgeInsets.all(20.0),
        //   child: Text(
        //     "Select Counter",
        //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        //   ),
        // ),
        Expanded(
          child: ListView.builder(
            itemCount: cubit.cashiersList.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final cashier = cubit.cashiersList[index];

              // التحقق مما إذا كان الكاشير مشغولاً (Active)
              // ملاحظة: تأكد أن الموديل CashierModel يحتوي على cashierActive
              final bool isBusy = cashier.cashierActive;

              return Card(
                elevation: isBusy ? 0 : 3, // تقليل الظل للمشغول
                color: isBusy
                    ? Colors.grey.shade200
                    : Colors.white, // لون باهت للمشغول
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  enabled: !isBusy, // تعطيل الضغط
                  leading: CircleAvatar(
                    backgroundColor: isBusy
                        ? Colors.grey
                        : AppColors.primaryBlue,
                    child: Icon(
                      isBusy ? Icons.lock_clock : Icons.point_of_sale,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    cashier.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isBusy ? Colors.grey : Colors.black,
                      decoration: isBusy
                          ? TextDecoration.lineThrough
                          : null, // خط اختياري
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cashier.arName,
                        style: TextStyle(color: isBusy ? Colors.grey : null),
                      ),
                      if (isBusy)
                        const Text(
                          "Currently Occupied (Active Shift)",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: isBusy
                      ? const Icon(
                          Icons.block,
                          color: Colors.red,
                        ) // أيقونة المنع
                      : const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                  onTap: isBusy
                      ? null // منع الضغط
                      : () => cubit.selectCashier(cashier),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
