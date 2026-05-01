// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:GoSystem/core/constants/app_colors.dart';
// import 'package:GoSystem/core/utils/responsive_ui.dart';
// import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
// import 'package:GoSystem/core/widgets/custom_button_widget.dart';
// import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
// import 'package:GoSystem/core/widgets/custom_error/custom_error_state.dart';
// import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
// import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
// import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
// import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
// import 'package:GoSystem/features/admin/suppliers/cubit/supplier_cubit.dart';
// import 'package:GoSystem/features/admin/suppliers/cubit/supplier_state.dart';
// import 'package:GoSystem/features/admin/taxes/cubit/taxes_cubit.dart';
// import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
// import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';
// import 'package:GoSystem/generated/locale_keys.g.dart';

// class CreatePurchaseScreen extends StatefulWidget {
//   const CreatePurchaseScreen({super.key});

//   @override
//   State<CreatePurchaseScreen> createState() => _CreatePurchaseScreenState();
// }

// class _CreatePurchaseScreenState extends State<CreatePurchaseScreen> {
//   final _referenceController = TextEditingController();
//   final _noteController = TextEditingController();
//   final _shippingCostController = TextEditingController();
//   final _discountController = TextEditingController();

//   // In a real app, use DateTime picker
//   final _dateController = TextEditingController(
//     text: DateTime.now().toIso8601String().split('T')[0],
//   );

//   File? _receiptImage;
//   final _picker = ImagePicker();

//   // Temporary IDs for simulation - Replace with Dropdowns fetching from Cubits
//   String? _selectedWarehouseId;
//   String? _selectedSupplierId;
//   String? _selectedTaxId;
//   String? _selectedPaymentType;
//   String? _selectedBankAccount;
//   DateTime? purchaseDate;

//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _receiptImage = File(pickedFile.path);
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     context.read<WareHouseCubit>().getWarehouses();
//     context.read<SupplierCubit>().getSuppliers();
//     context.read<TaxesCubit>().getTaxes();
//     context.read<BankAccountCubit>().getBankAccounts();
//   }

//   void _removeImage() {
//     setState(() {
//       _receiptImage = null;
//     });
//   }

//   void _validateAndSubmit() {
//     if (_referenceController.text.trim().isEmpty) {
//       CustomSnackbar.showWarning(context, "Please enter reference");
//       return;
//     }

//     // // Call Cubit
//     // context.read<PurchaseCubit>().createPurchase(
//     //   reference: _referenceController.text.trim(),
//     //   date: _dateController.text.trim(),
//     //   note: _noteController.text.trim(),
//     //   shippingCost: double.tryParse(_shippingCostController.text.trim()),
//     //   discount: double.tryParse(_discountController.text.trim()),
//     //   warehouseId: _selectedWarehouseId!,
//     //   supplierId: _selectedSupplierId!,
//     //   taxId: _selectedTaxId!,
//     //   receiptImage: _receiptImage,
//     // );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PurchaseCubit, PurchaseState>(
//       listener: (context, state) {
//         if (state is CreatePurchaseSuccess) {
//           CustomSnackbar.showSuccess(context, state.message);
//           Navigator.pop(context, true);
//         } else if (state is CreatePurchaseError) {
//           CustomSnackbar.showError(context, state.error);
//         }
//       },
//       builder: (context, state) {
//         if (state is CreatePurchaseSuccess) {
//           return Scaffold(
//             backgroundColor: AppColors.lightBlueBackground,
//             body: CustomErrorState(
//               message: state.message,
//               onRetry: _validateAndSubmit,
//             ),
//           );
//         }

//         final isLoading = state is CreatePurchaseLoading;

//         return Scaffold(
//           backgroundColor: const Color.fromARGB(255, 243, 249, 254),
//           appBar: appBarWithActions(context, title: "Create Purchase"),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(
//                 horizontal: ResponsiveUI.padding(context, 16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                    BlocBuilder<WareHouseCubit, WarehousesState>(
//                     builder: (context, state) {
//                       // Default values
//                       List<String> warehouseIds = [];
//                       List<String> warehouseNames = [];

//                       // Loading state
//                       if (state is WarehousesLoading) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }

//                       // Success – we have data
//                       if (state is WarehousesLoaded) {
//                         warehouseIds = state.warehouses
//                             .map((w) => w.id)
//                             .toList();
//                         warehouseNames = state.warehouses
//                             .map((w) => w.name)
//                             .toList();
//                       }

//                       // If we have no warehouses at all (even after loading)
//                       if (warehouseIds.isEmpty) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Text(
//                             LocaleKeys.no_warehouses_found.tr(),
//                             style: TextStyle(color: Colors.grey[600]),
//                             textAlign: TextAlign.center,
//                           ),
//                         );
//                       }

//                       return buildDropdownField<String>(
//                         context,
//                         value: _selectedWarehouseId,
//                         items: warehouseIds,
//                         label: LocaleKeys.warehouse.tr(),
//                         hint: LocaleKeys.select_warehouse.tr(),
//                         icon: Icons.warehouse_rounded,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedWarehouseId = value;
//                           });
//                         },
//                         itemLabel: (id) {
//                           final index = warehouseIds.indexOf(id);
//                           return index != -1
//                               ? warehouseNames[index]
//                               : 'Unknown';
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return LocaleKeys.please_select_warehouse.tr();
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                   ),

//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),

//                   BlocBuilder<SupplierCubit, SupplierStates>(
//                     builder: (context, state) {
//                       // Default values
//                       List<String> supplierIds = [];
//                       List<String> supplierNames = [];

//                       // Loading state
//                       if (state is SupplierLoading) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }

//                       // Success – we have data
//                       if (state is SupplierSuccess) {
//                         final cubit = context.read<SupplierCubit>();
//                         if (cubit.suppliers != null &&
//                             cubit.suppliers!.isNotEmpty) {
//                           supplierIds = cubit.suppliers!
//                               .map((supplier) => supplier.id ?? '')
//                               .where((id) => id.isNotEmpty)
//                               .toList();
//                           supplierNames = cubit.suppliers!
//                               .map(
//                                 (supplier) =>
//                                     supplier.username ??
//                                     supplier.companyName ??
//                                     'Unknown',
//                               )
//                               .toList();
//                         }
//                       }

//                       // If we have no warehouses at all (even after loading)
//                       if (supplierIds.isEmpty) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Text(
//                             LocaleKeys.no_suppliers_title.tr(),
//                             style: TextStyle(color: Colors.grey[600]),
//                             textAlign: TextAlign.center,
//                           ),
//                         );
//                       }

//                       return buildDropdownField<String>(
//                         context,
//                         value: _selectedSupplierId,
//                         items: supplierIds,
//                         label: "Supplier",
//                         hint: "Select Supplier",
//                         icon: Icons.warehouse_rounded,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedSupplierId = value;
//                           });
//                         },
//                         itemLabel: (id) {
//                           final index = supplierIds.indexOf(id);
//                           return index != -1 ? supplierNames[index] : 'Unknown';
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please Select Supplier";
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                   ),

//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),

//                   BlocBuilder<TaxesCubit, TaxesState>(
//                     builder: (context, state) {
//                       // Default values
//                       List<String> taxesIds = [];
//                       List<String> takesNames = [];

//                       // Loading state
//                       if (state is GetTaxesLoading) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }

//                       // Success – we have data
//                       if (state is GetTaxesSuccess) {
//                         taxesIds = state.taxes.map((w) => w.id).toList();
//                         takesNames = state.taxes.map((w) => w.name).toList();
//                       }

//                       // If we have no warehouses at all (even after loading)
//                       if (taxesIds.isEmpty) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Text(
//                             LocaleKeys.no_taxes.tr(),
//                             style: TextStyle(color: Colors.grey[600]),
//                             textAlign: TextAlign.center,
//                           ),
//                         );
//                       }

//                       return buildDropdownField<String>(
//                         context,
//                         value: _selectedTaxId,
//                         items: taxesIds,
//                         label: "Tax",
//                         hint: "Select Tax",
//                         icon: Icons.warehouse_rounded,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedTaxId = value;
//                           });
//                         },
//                         itemLabel: (id) {
//                           final index = taxesIds.indexOf(id);
//                           return index != -1 ? takesNames[index] : 'Unknown';
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return "Please Select Tax";
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                   ),

//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),

//                   BlocBuilder<BankAccountCubit, BankAccountState>(
//                     builder: (context, state) {
//                       // Default values
//                       List<String> financialAccountsIds = [];
//                       List<String> financialAccountsNames = [];

//                       // Loading state
//                       if (state is GetBankAccountsLoading) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Center(child: CircularProgressIndicator()),
//                         );
//                       }

//                       // Success – we have data
//                       if (state is GetBankAccountsSuccess) {
//                         financialAccountsIds = state.accounts
//                             .map((w) => w.id)
//                             .toList();
//                         financialAccountsNames = state.accounts
//                             .map((w) => w.name)
//                             .toList();
//                       }

//                       // If we have no warehouses at all (even after loading)
//                       if (financialAccountsIds.isEmpty) {
//                         return Padding(
//                           padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
//                           child: Text(
//                             "No Financial Accounts",
//                             style: TextStyle(color: Colors.grey[600]),
//                             textAlign: TextAlign.center,
//                           ),
//                         );
//                       }

//                       return buildDropdownField<String>(
//                         context,
//                         value: _selectedBankAccount,
//                         items: financialAccountsIds,
//                         label: "Financial Account",
//                         hint: "Select Financial Account",
//                         icon: Icons.warehouse_rounded,
//                         onChanged: (value) {
//                           setState(() {
//                             _selectedBankAccount = value;
//                           });
//                         },
//                         itemLabel: (id) {
//                           final index = financialAccountsIds.indexOf(id);
//                           return index != -1
//                               ? financialAccountsNames[index]
//                               : 'Unknown';
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return LocaleKeys.please_select_financial_account.tr();
//                           }
//                           return null;
//                         },
//                       );
//                     },
//                   ),

//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),

//                   buildTextField(
//                     context,
//                     controller: _dateController,
//                     label: "Purchase Date",
//                     icon: Icons.date_range,
//                     readOnly: true,
//                     hint: "Pick Purchase Date",
//                     onTap: _pickDate,
//                     validator: (v) {
//                       if (v == null || v.isEmpty) {
//                         return LocaleKeys.pick_expiration_date.tr();
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),
//                   buildTextField(
//                     context,
//                     controller: _noteController,
//                     label: "Note",
//                     hint: "Enter notes",
//                     maxLines: 2,
//                     icon: Icons.note,
//                   ),
//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: buildTextField(
//                     context,
//                           controller: _shippingCostController,
//                           label: "Shipping Cost",
//                           hint: "0.0",
//                           icon: Icons.local_shipping
//                         ),
//                       ),
//                       SizedBox(width: ResponsiveUI.spacing(context, 16)),
//                       Expanded(
//                         child: buildTextField(
//                     context,
//                           controller: _discountController,
//                           label: "Discount",
//                           hint: "0.0",
//                           icon: Icons.local_offer
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: ResponsiveUI.spacing(context, 12)),

//                   buildDropdownField<String>(
//                     context,
//                     value: _selectedPaymentType,
//                     items: ["full", "later", "partial"],
//                     label: "Payment Type",
//                     hint: "Select Payment Type",
//                     icon: Icons.warehouse_rounded,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedPaymentType = value;
//                       });
//                     },
//                     itemLabel: (item) => item,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return LocaleKeys.please_select_warehouse.tr();
//                       }
//                       return null;
//                     },
//                   ),

//                   _buildImagePicker(
//                     selectedImage: _receiptImage,
//                     title: "Receipt Image",
//                     onPick: _pickImage,
//                     onRemove: _removeImage,
//                   ),

//                   SizedBox(height: ResponsiveUI.spacing(context, 24)),

//                   SizedBox(
//                     width: double.infinity,
//                     height: ResponsiveUI.value(context, 48),
//                     child: CustomElevatedButton(
//                       onPressed: isLoading ? null : _validateAndSubmit,
//                       text: isLoading ? "Saving..." : "Save Purchase",
//                       isLoading: isLoading,
//                     ),
//                   ),
//                   SizedBox(height: ResponsiveUI.spacing(context, 16)),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _pickDate() async {
//     DateTime now = DateTime.now();
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: now,
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       _dateController.text = picked.toIso8601String().split("T").first;
//     }
//   }

//   Widget _buildImagePicker({
//     required File? selectedImage,
//     required String title,
//     required VoidCallback onPick,
//     required VoidCallback onRemove,
//   }) {
//     final width = ResponsiveUI.screenWidth(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: ResponsiveUI.spacing(context, 16)),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: ResponsiveUI.fontSize(context, 14),
//                 color: AppColors.darkGray,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             if (selectedImage != null)
//               TextButton.icon(
//                 icon: Icon(Icons.delete, color: AppColors.red, size: ResponsiveUI.iconSize(context, 18)),
//                 label: Text(
//                   LocaleKeys.remove.tr(),
//                   style: TextStyle(color: AppColors.red),
//                 ),
//                 onPressed: onRemove,
//               ),
//           ],
//         ),
//         SizedBox(height: ResponsiveUI.spacing(context, 8)),
//         GestureDetector(
//           onTap: onPick,
//           child: Container(
//             width: width * 0.35,
//             height: width * 0.35,
//             decoration: BoxDecoration(
//               color: AppColors.white,
//               borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
//               border: Border.all(color: AppColors.lightGray),
//             ),
//             child: selectedImage != null
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
//                     child: Image.file(selectedImage, fit: BoxFit.cover),
//                   )
//                 : Icon(
//                     Icons.camera_alt,
//                     size: ResponsiveUI.iconSize(context, 40),
//                     color: AppColors.primaryBlue,
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _referenceController.dispose();
//     _noteController.dispose();
//     _shippingCostController.dispose();
//     _discountController.dispose();
//     _dateController.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart'
    as purchase_model;
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_cubit.dart';
import 'package:GoSystem/features/admin/suppliers/cubit/supplier_state.dart';
import 'package:GoSystem/features/admin/taxes/cubit/taxes_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

import '../../../product/models/product_model.dart';

class CreatePurchaseScreen extends StatefulWidget {
  const CreatePurchaseScreen({super.key});

  @override
  State<CreatePurchaseScreen> createState() => _CreatePurchaseScreenState();
}

class _CreatePurchaseScreenState extends State<CreatePurchaseScreen> {
  // final _referenceController = TextEditingController();
  final _noteController = TextEditingController();
  final _shippingCostController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _exchangeRateController = TextEditingController(text: '1');
  final _partialAmountController = TextEditingController();
  final _duePaymentDateController = TextEditingController();  final _duePaymentAmountController = TextEditingController();

  final _dateController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );

  File? _receiptImage;
  final _picker = ImagePicker();

  String? _selectedWarehouseId;
  String? _selectedSupplierId;
  String? _selectedTaxId;
  String? _selectedPaymentType = 'full';
  String? _selectedBankAccount;

  DateTime? purchaseDate;
  DateTime? duePaymentDate;

  List<purchase_model.PurchaseItemModel> purchaseItems = [];
  List<purchase_model.PaymentModel> financials = [];
  List<purchase_model.DuePaymentModel> duePayments = [];

  double get subtotal =>
      purchaseItems.fold(0, (sum, item) => sum + item.subtotal);
  double get shippingCost => double.tryParse(_shippingCostController.text) ?? 0;
  double get discount => double.tryParse(_discountController.text) ?? 0;
  double get taxAmount =>
      _selectedTaxId != null ? subtotal * 0.15 : 0; // Example: 15% tax
  double get grandTotal => subtotal + shippingCost - discount + taxAmount;
  double get totalPaid =>
      financials.fold(0, (sum, payment) => sum + payment.paymentAmount);
  double get totalDue => duePayments.fold(0, (sum, due) => sum + due.amount);

  @override
  void initState() {
    super.initState();
    context.read<WareHouseCubit>().getWarehouses();
    context.read<SupplierCubit>().getSuppliers();
    context.read<TaxesCubit>().getTaxes();
    context.read<BankAccountCubit>().getBankAccounts();
    context.read<ProductsCubit>().getProducts();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _receiptImage = null;
    });
  }

  Future<void> _showProductSelectionDialog() async {
    // final productsCubit = context.read<ProductsCubit>();
    // final products = productsCubit.state.products;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
        child: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state is ProductsLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (state is ProductsError) {
              return Padding(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
                child: Text(state.message),
              );
            }

            if (state is ProductsSuccess) {
              final products = state.products;
              return Column(
                children: [
                  AppBar(
                    title: const Text('Select Products'),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ListTile(
                          leading: product.image.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(product.image),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.inventory),
                                ),
                          title: Text(product.name),
                          subtitle: Text(
                            'Stock: ${product.quantity} | Price: \$${product.price}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _showProductDetailsDialog(product),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  void _showProductDetailsDialog(Product product) {
    Navigator.pop(context); // Close product list dialog

    if (product.differentPrice && product.prices?.isNotEmpty == true) {
      _showVariationSelectionDialog(product);
    } else {
      _showSimpleProductDialog(product);
    }
  }

  void _showSimpleProductDialog(Product product) {
    final quantityController = TextEditingController(text: '1');
    final unitCostController = TextEditingController(
      text: product.price.toString(),
    );
    final discountController = TextEditingController(text: '0');
    DateTime? selectedExpirationDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 20)),

                  // Quantity
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),

                  // Unit Cost
                  TextField(
                    controller: unitCostController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Unit Cost',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),

                  // Discount
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Discount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),

                  // Expiration Date (if product has expiration ability)
                  if (product.expAbility)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Expiration Date'),
                        SizedBox(height: ResponsiveUI.value(context, 8)),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 10),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                selectedExpirationDate = date;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: ResponsiveUI.iconSize(context, 20)),
                                SizedBox(width: ResponsiveUI.value(context, 10)),
                                Text(
                                  selectedExpirationDate != null
                                      ? selectedExpirationDate!
                                            .toIso8601String()
                                            .split('T')[0]
                                      : 'Select expiration date',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 16)),
                      ],
                    ),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 10)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final quantity =
                                int.tryParse(quantityController.text) ?? 1;
                            final unitCost =
                                double.tryParse(unitCostController.text) ??
                                product.price;
                            final discount =
                                double.tryParse(discountController.text) ?? 0;
                            final tax = 0.0; // Calculate tax based on tax rate
                            final subtotal =
                                (unitCost * quantity) - discount + tax;

                            final item = purchase_model.PurchaseItemModel(
                              productId: product.id,
                              productCode: product.prices?.isNotEmpty == true
                                  ? product.prices!.first.code
                                  : 'PROD-${product.id.substring(0, 8)}',
                              quantity: quantity,
                              dateOfExpiery: selectedExpirationDate,
                              unitCost: unitCost,
                              discount: discount,
                              tax: tax,
                              subtotal: subtotal,
                              variations: [],
                              product: product,
                            );

                            setState(() {
                              purchaseItems.add(item);
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Add to Purchase'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showVariationSelectionDialog(Product product) {
    final List<VariationSelection> selectedVariations = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Variations for ${product.name}',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 20)),

                  // List of prices/variations
                 ...(product.prices ?? []).map((price) {
                    final quantityController = TextEditingController(text: '0');
                    DateTime? selectedExpirationDate;

                    return Card(
                      margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 10)),
                      child: Padding(
                        padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: \$${price.price}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Code: ${price.code}'),
                            Text('Stock: ${price.quantity}'),

                            // Show variation details
                            if (price.variations.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: ResponsiveUI.value(context, 8)),
                                  const Text('Variations:'),
                                  ...price.variations.map((variation) {
                                    return Padding(
                                      padding: EdgeInsets.only(left: ResponsiveUI.padding(context, 8)),
                                      child: Text(
                                        '${variation.name}: ${variation.options.map((o) => o.name).join(', ')}',
                                      ),
                                    );
                                  }),
                                ],
                              ),

                            SizedBox(height: ResponsiveUI.value(context, 12)),

                            // Quantity input
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final qty = int.tryParse(value) ?? 0;
                                final index = selectedVariations.indexWhere(
                                  (v) => v.priceId == price.id,
                                );

                                if (qty > 0 && index == -1) {
                                  selectedVariations.add(
                                    VariationSelection(
                                      priceId: price.id,
                                      quantity: qty,
                                      expirationDate: selectedExpirationDate,
                                    ),
                                  );
                                } else if (qty > 0 && index != -1) {
                                  selectedVariations[index] =
                                      selectedVariations[index].copyWith(
                                        quantity: qty,
                                      );
                                } else if (qty == 0 && index != -1) {
                                  selectedVariations.removeAt(index);
                                }
                              },
                            ),

                            // Expiration date
                            if (product.expAbility)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: ResponsiveUI.value(context, 12)),
                                  const Text('Expiration Date'),
                                  GestureDetector(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365 * 10),
                                        ),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          selectedExpirationDate = date;
                                        });

                                        final index = selectedVariations
                                            .indexWhere(
                                              (v) => v.priceId == price.id,
                                            );
                                        if (index != -1) {
                                          selectedVariations[index] =
                                              selectedVariations[index]
                                                  .copyWith(
                                                    expirationDate: date,
                                                  );
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: ResponsiveUI.iconSize(context, 20),
                                          ),
                                          SizedBox(width: ResponsiveUI.value(context, 10)),
                                          Text(
                                            selectedExpirationDate != null
                                                ? selectedExpirationDate!
                                                      .toIso8601String()
                                                      .split('T')[0]
                                                : 'Select expiration date',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  SizedBox(height: ResponsiveUI.value(context, 20)),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 10)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: selectedVariations.isEmpty
                              ? null
                              : () {
                                  // Create purchase item with variations
                                  final variations = selectedVariations
                                      .where((v) => v.quantity > 0)
                                      .map(
                                        (selection) => purchase_model.VariationModel(
                                          productPriceId: selection.priceId,
                                          quantity: selection.quantity,
                                          dateOfExpiery:
                                              selection.expirationDate,
                                        ),
                                      )
                                      .toList();

                                  final totalQuantity = variations.fold(
                                    0,
                                    (sum, variation) =>
                                        sum + variation.quantity,
                                  );

                                  final item = purchase_model.PurchaseItemModel(
                                    productId: product.id,
                                    productCode: product.prices?.isNotEmpty == true
    ? product.prices!.first.code
    : 'PROD-${product.id.substring(0, 8)}',

                                    quantity: totalQuantity,
                                    unitCost: product.price,
                                    discount: 0,
                                    tax: 0,
                                    subtotal: product.price * totalQuantity,
                                    variations: variations,
                                    product: product,
                                  );

                                  setState(() {
                                    purchaseItems.add(item);
                                  });
                                  Navigator.pop(context);
                                },
                          child: const Text('Add to Purchase'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _removePurchaseItem(int index) {
    setState(() {
      purchaseItems.removeAt(index);
    });
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Details',
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 18), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 20)),

                  // Payment Type
                  DropdownButtonFormField<String>(
                    value: _selectedPaymentType,
                    items: const [
                      DropdownMenuItem(
                        value: 'full',
                        child: Text('Full Payment'),
                      ),
                      DropdownMenuItem(
                        value: 'partial',
                        child: Text('Partial Payment'),
                      ),
                      DropdownMenuItem(
                        value: 'later',
                        child: Text('Pay Later'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentType = value;
                        if (value == 'full') {
                          financials.clear();
                          duePayments.clear();
                        } else if (value == 'partial') {
                          duePayments.clear();
                        }
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),

                  // Financial Accounts Dropdown
                  BlocBuilder<BankAccountCubit, BankAccountState>(
                    builder: (context, state) {
                      if (state is GetBankAccountsLoading) {
                        return const CircularProgressIndicator();
                      }

                      if (state is GetBankAccountsSuccess) {
                        return DropdownButtonFormField<String>(
                          value: _selectedBankAccount,
                          items: state.accounts.map((account) {
                            return DropdownMenuItem(
                              value: account.id,
                              child: Text(account.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBankAccount = value;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Financial Account',
                            border: OutlineInputBorder(),
                          ),
                        );
                      }

                      return const Text('No financial accounts available');
                    },
                  ),

                  // Current Payment Amount (for full or partial)
                  if (_selectedPaymentType == 'full' ||
                      _selectedPaymentType == 'partial')
                    Column(
                      children: [
                        SizedBox(height: ResponsiveUI.value(context, 16)),
                        TextField(
                          controller: _partialAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _selectedPaymentType == 'full'
                                ? 'Full Amount'
                                : 'Amount to Pay Now',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),

                  // Due Payment (for partial or later)
                  if (_selectedPaymentType == 'partial' ||
                      _selectedPaymentType == 'later')
                    Column(
                      children: [
                        SizedBox(height: ResponsiveUI.value(context, 16)),
                        TextField(
                          controller: _duePaymentAmountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Due Amount',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 16)),
                        GestureDetector(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(
                                const Duration(days: 30),
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                duePaymentDate = date;
                                _duePaymentDateController.text = date
                                    .toIso8601String()
                                    .split('T')[0];
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: ResponsiveUI.iconSize(context, 20)),
                                SizedBox(width: ResponsiveUI.value(context, 10)),
                                Text(
                                  duePaymentDate != null
                                      ? duePaymentDate!.toIso8601String().split(
                                          'T',
                                        )[0]
                                      : 'Select due date',
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.value(context, 16)),
                        ElevatedButton(
                          onPressed: () {
                            final amount =
                                double.tryParse(
                                  _duePaymentAmountController.text,
                                ) ??
                                0;
                            if (amount > 0 && duePaymentDate != null) {
                              setState(() {
                                duePayments.add(
                                  purchase_model.DuePaymentModel(
                                    amount: amount,
                                    date: duePaymentDate!,
                                  ),
                                );
                                _duePaymentAmountController.clear();
                              });
                            }
                          },
                          child: const Text('Add Due Payment'),
                        ),
                      ],
                    ),

                  // Display added due payments
                  if (duePayments.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: ResponsiveUI.value(context, 16)),
                        const Text('Due Payments:'),
                        ...duePayments
                            .map(
                              (due) => ListTile(
                                title: Text('\$${due.amount}'),
                                subtitle: Text(
                                  due.date.toIso8601String().split('T')[0],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      duePayments.remove(due);
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),

                  SizedBox(height: ResponsiveUI.value(context, 20)),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 10)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Add current payment to financials
                            if (_selectedBankAccount != null &&
                                (_selectedPaymentType == 'full' ||
                                    _selectedPaymentType == 'partial')) {
                              final amount =
                                  double.tryParse(
                                    _partialAmountController.text,
                                  ) ??
                                  0;
                              if (amount > 0) {
                                financials.add(
                                  purchase_model.PaymentModel(
                                    financialId: _selectedBankAccount!,
                                    paymentAmount: amount,
                                  ),
                                );
                              }
                            }

                            Navigator.pop(context);
                          },
                          child: const Text('Save Payment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _validateAndSubmit() {


    if (_selectedWarehouseId == null) {
      CustomSnackbar.showWarning(context, "Please select warehouse");
      return;
    }

    if (_selectedSupplierId == null) {
      CustomSnackbar.showWarning(context, "Please select supplier");
      return;
    }

    if (purchaseItems.isEmpty) {
      CustomSnackbar.showWarning(context, "Please add at least one product");
      return;
    }

    // Prepare the data for API
    final purchaseData = {
      'date': _dateController.text.trim(),
      'warehouse_id': _selectedWarehouseId,
      'supplier_id': _selectedSupplierId,
      'tax_id': _selectedTaxId,
      'payment_status': _selectedPaymentType,
      'exchange_rate': double.tryParse(_exchangeRateController.text) ?? 1,
      'total': subtotal,
      'shipping_cost': shippingCost,
      'discount': discount,
      'grand_total': grandTotal,
      'note': _noteController.text.trim(),
      'purchase_items': purchaseItems.map((item) => item.toJson()).toList(),
      'financials': financials.map((payment) => payment.toJson()).toList(),
      if (duePayments.isNotEmpty)
        'purchase_due_payment': duePayments.map((due) => due.toJson()).toList(),
    };

    // Convert image to base64 if exists
    if (_receiptImage != null) {
      final bytes = _receiptImage!.readAsBytesSync();
      final base64Image = base64Encode(bytes);
      purchaseData['receipt_img'] = 'data:image/png;base64,$base64Image';
    }

    // Call the cubit to create purchase
    // context.read<PurchaseCubit>().createPurchase(purchaseData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is CreatePurchaseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreatePurchaseError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreatePurchaseLoading;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: "Create Purchase"),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reference field
                 

                  // // Warehouse dropdown
                  // BlocBuilder<WareHouseCubit, WarehousesState>(
                  //   builder: (context, state) {
                  //     // ... existing warehouse dropdown code ...
                  //   },
                  // ),
                  // SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  // // Supplier dropdown
                  // BlocBuilder<SupplierCubit, SupplierStates>(
                  //   builder: (context, state) {
                  //     // ... existing supplier dropdown code ...
                  //   },
                  // ),
                  // SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  // // Tax dropdown
                  // BlocBuilder<TaxesCubit, TaxesState>(
                  //   builder: (context, state) {
                  //     // ... existing tax dropdown code ...
                  //   },
                  // ),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  // Exchange Rate
                  buildTextField(
                    context,
                    controller: _exchangeRateController,
                    label: "Exchange Rate",
                    hint: "1.0",
                    icon: Icons.currency_exchange,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  // Products Section
                  Card(
                    margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 16)),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Products',
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.add),
                                label: const Text('Add Product'),
                                onPressed: _showProductSelectionDialog,
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUI.value(context, 16)),

                          // Display selected products
                          if (purchaseItems.isEmpty)
                            Center(
                              child: Text(
                                'No products added',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          else
                            ...purchaseItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              return Card(
                                margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 8)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red[50],
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(item.product.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Quantity: ${item.quantity}'),
                                      if (item.dateOfExpiery != null)
                                        Text(
                                          'Expires: ${item.dateOfExpiery!.toIso8601String().split('T')[0]}',
                                        ),
                                      Text(
                                        'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                      ),
                                      if (item.variations.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: item.variations.map((
                                            variation,
                                          ) {
                                            return Text(
                                              '  - Variation: ${variation.quantity} units',
                                              style: TextStyle(
                                                fontSize: ResponsiveUI.fontSize(context, 12),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removePurchaseItem(index),
                                  ),
                                ),
                              );
                            }).toList(),

                          // Summary
                          if (purchaseItems.isNotEmpty)
                            Column(
                              children: [
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Subtotal:'),
                                    Text('\$${subtotal.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Shipping:'),
                                    Text(
                                      '\$${shippingCost.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Discount:'),
                                    Text('-\$${discount.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tax:'),
                                    Text('\$${taxAmount.toStringAsFixed(2)}'),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Grand Total:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveUI.fontSize(context, 16),
                                      ),
                                    ),
                                    Text(
                                      '\$${grandTotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ResponsiveUI.fontSize(context, 16),
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Payment Section
                  Card(
                    margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 16)),
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Payment',
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.payment),
                                label: const Text('Configure Payment'),
                                onPressed: _showPaymentDialog,
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUI.value(context, 16)),

                          // Display payment summary
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Type: ${_selectedPaymentType?.toUpperCase()}',
                              ),
                              if (financials.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Payments:'),
                                    ...financials
                                        .map(
                                          (payment) => Text(
                                            '  - \$${payment.paymentAmount}',
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              if (duePayments.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Due Payments:'),
                                    ...duePayments
                                        .map(
                                          (due) => Text(
                                            '  - \$${due.amount} on ${due.date.toIso8601String().split('T')[0]}',
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              SizedBox(height: ResponsiveUI.value(context, 8)),
                              Text(
                                'Total Paid: \$${totalPaid.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total Due: \$${totalDue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: totalDue > 0
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Other fields (note, shipping, discount, date, image)
                  buildTextField(
                    context,
                    controller: _noteController,
                    label: "Note",
                    hint: "Enter notes",
                    maxLines: 2,
                    icon: Icons.note,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          context,
                          controller: _shippingCostController,
                          label: "Shipping Cost",
                          hint: "0.0",
                          icon: Icons.local_shipping,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 16)),
                      Expanded(
                        child: buildTextField(
                          context,
                          controller: _discountController,
                          label: "Discount",
                          hint: "0.0",
                          icon: Icons.local_offer,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 12)),

                  buildTextField(
                    context,
                    controller: _dateController,
                    label: "Purchase Date",
                    icon: Icons.date_range,
                    readOnly: true,
                    hint: "Pick Purchase Date",
                    onTap: _pickDate,
                  ),

                  _buildImagePicker(
                    selectedImage: _receiptImage,
                    title: "Receipt Image",
                    onPick: _pickImage,
                    onRemove: _removeImage,
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 24)),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 48),
                    child: CustomElevatedButton(
                      onPressed: isLoading ? null : _validateAndSubmit,
                      text: isLoading ? "Saving..." : "Save Purchase",
                      isLoading: isLoading,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = picked.toIso8601String().split("T").first;
    }
  }

  Widget _buildImagePicker({
    required File? selectedImage,
    required String title,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final width = ResponsiveUI.screenWidth(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedImage != null)
              TextButton.icon(
                icon: Icon(Icons.delete, color: AppColors.red, size: ResponsiveUI.iconSize(context, 18)),
                label: Text(
                  LocaleKeys.remove.tr(),
                  style: TextStyle(color: AppColors.red),
                ),
                onPressed: onRemove,
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: width * 0.35,
            height: width * 0.35,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    child: Image.file(selectedImage, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.camera_alt,
                    size: ResponsiveUI.iconSize(context, 40),
                    color: AppColors.primaryBlue,
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _shippingCostController.dispose();
    _discountController.dispose();
    _exchangeRateController.dispose();
    _partialAmountController.dispose();
    _duePaymentDateController.dispose();
    _duePaymentAmountController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

// Helper class for variation selection
class VariationSelection {
  final String priceId;
  int quantity;
  DateTime? expirationDate;

  VariationSelection({
    required this.priceId,
    required this.quantity,
    this.expirationDate,
  });

  VariationSelection copyWith({int? quantity, DateTime? expirationDate}) {
    return VariationSelection(
      priceId: priceId,
      quantity: quantity ?? this.quantity,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }
}
