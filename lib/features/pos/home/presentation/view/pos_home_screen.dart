import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/error_handler.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';

// Cubits
import 'package:systego/features/POS/checkout/cubit/checkout_cubit/checkout_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_cubit.dart';
import 'package:systego/features/POS/home/cubit/pos_home_state.dart';
import 'package:systego/features/POS/shift/cubit/pos_shift_cubit.dart';

// Models
import 'package:systego/features/POS/home/model/pos_models.dart';

// Services & Screens
import '../../../../../core/services/cache_helper.dart';
import '../../../../admin/auth/presentation/view/login_screen.dart';
import '../../../../admin/product/presentation/screens/barcode_scanner_screen.dart';
import '../../../checkout/presentation/widgets/cart_bottom_sheet.dart';
import '../../../checkout/presentation/widgets/cart_fab.dart';
import '../../../checkout/presentation/widgets/cart_summary.dart';
import '../../../sales/presentation/views/sales_screen.dart';
import '../../../shift/presentation/views/cashier_selection_screen.dart';
import '../../../shift/presentation/views/start_shift_screen.dart';


// Widgets
import '../widgets/filter_by_category_brand_widgets.dart';
import '../widgets/header_section.dart';
import '../widgets/product_details_dialog.dart';
import '../widgets/product_grid.dart'; // هذا الملف سنكتبه في الجزء الثاني
import '../widgets/tab_bar.dart';
import '../widgets/variation_selector_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // التحقق المبدئي: إذا كان الشيفت مفتوحاً، ابدأ المؤقت وحمل البيانات
    final shiftCubit = context.read<PosShiftCubit>();
    final homeCubit = context.read<PosCubit>();
    
    if (shiftCubit.isShiftOpen) {
      homeCubit.loadPosData();
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

  // ─── Shift Timer Logic ───
  void _startLocalTimer() {
    _shiftTimer?.cancel();

    void updateTime() {
      final cubit = context.read<PosShiftCubit>();
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
    }

    updateTime(); 
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // ─── Cart Logic ───
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
        (s, i) => s + i.product.price * i.quantity, 
      );

  // ─── Barcode Logic ───
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

  // ─── Filter Logic ───
  List<Product> _filterProducts(List<Product> products) {
    return products.where((product) {
      bool matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.price.toString().contains(_searchQuery.toLowerCase()) ||
          product.prices.any(
            (v) => v.code.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // استماع لأحداث الشيفت والكاشير
        BlocListener<PosShiftCubit, PosShiftState>(
          listener: (context, state) {
            if (state is PosShiftActionError) {
              CustomSnackbar.showError(context, state.message);
            }
            if (state is PosSelectCashierError) {
              CustomSnackbar.showError(context, state.message);
            }

            // عند بدء الشيفت بنجاح
            if (state is PosShiftStarted) {
              context.read<PosCubit>().loadPosData();
              _startLocalTimer();
            }

            // عند إنهاء الشيفت
            if (state is PosShiftEnded) {
              _shiftTimer?.cancel();
            }
          },
        ),
        // استماع لأخطاء المنتجات (PosCubit)
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
      ],
      // بناء الواجهة بناءً على حالة الشيفت
      child: BlocBuilder<PosShiftCubit, PosShiftState>(
        builder: (context, state) {
          final shiftCubit = context.read<PosShiftCubit>();
          final homeCubit = context.read<PosCubit>();

          // السيناريو 1: لم يتم اختيار كاشير بعد
          if (shiftCubit.selectedCashier == null) {
            return const CashierSelectionScreen();
          }

          // السيناريو 2: تم اختيار كاشير، لكن الشيفت مغلق
          if (!shiftCubit.isShiftOpen) {
            return const StartShiftScreen();
          }

          // السيناريو 3: الشيفت مفتوح -> عرض شاشة البيع (POS Layout)
          return _buildPosLayout(homeCubit, shiftCubit);
        },
      ),
    );
  }

  // ─── POS Layout (Scaffold & Body) ───
  Widget _buildPosLayout(PosCubit homeCubit, PosShiftCubit shiftCubit) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, checkoutState) {
        final checkoutCubit = context.read<CheckoutCubit>();
        final cartItems = checkoutCubit.cartItems;
        final bool hasItems = cartItems.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          
          // AppBar
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              scrolledUnderElevation: 1,
              backgroundColor: AppColors.white,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shiftCubit.selectedCashier?.name ?? "Unknown Cashier",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Shift Time: $_shiftDuration",
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
              actions: [
                // زر إنهاء الشيفت
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, color: AppColors.red),
                  tooltip: "End Shift",
                  onPressed: () async {
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
                      await shiftCubit.endShift();
                    }
                  },
                ),
                // زر تسجيل الخروج
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  tooltip: "Logout (Keep Shift Open)",
                  onPressed: () async {
                    await shiftCubit.logoutShift();
                    await CacheHelper.clearAllData();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                // زر التاريخ
                IconButton(
                  icon: const Icon(Icons.history, color: AppColors.primaryBlue),
                  tooltip: "Sales History",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Body
          body: _buildPosBody(homeCubit),

          // Bottom Sheet (Cart Summary)
          bottomSheet: hasItems ? POSCartSummary(total: _total) : null,

          // FAB (Cart Button)
          floatingActionButton: hasItems
              ? AnimatedOpacity(
                  opacity: hasItems ? 1.0 : 0.0,
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

  // ─── POS Body Content ───
  Widget _buildPosBody(PosCubit homeCubit) {
    return BlocBuilder<PosCubit, PosState>(
      builder: (context, state) {
        if (state is PosLoading) {
          return const CustomLoadingState();
        }

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

            // Product Grid (الآن سنمرر لها المنتجات المفلترة بالبحث)
            Expanded(
              child: Builder(
                builder: (context) {
                  // ملاحظة: الـ Grid سيتعامل مع حالة التحميل الخاصة بالفلتر داخلياً
                  if (state is PosDataLoaded) {
                    final filtered = _filterProducts(state.displayedProducts);
                    return POSProductGrid(
                      filteredProducts: filtered, // نمرر المنتجات بعد فلتر البحث
                    );
                  }
                  
                  // fallback
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