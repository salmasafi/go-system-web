import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_error_state.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/features/admin/pandel/cubit/pandel_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/pandel/model/pandel_model.dart';
import 'package:GoSystem/features/admin/categories/view/widgets/build_image_placeholder_widget.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class EditPandelScreen extends StatefulWidget {
  final PandelModel pandel;

  const EditPandelScreen({super.key, required this.pandel});

  @override
  State<EditPandelScreen> createState() => _EditPandelScreenState();
}

class _EditPandelScreenState extends State<EditPandelScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late DateTime _startDate;
  late DateTime _endDate;
  final List<File> _newImages = [];
  List<String> _existingImages = [];

  // Map of productId -> quantity
  final Map<String, int> _selectedProducts = {};
  // Map of productId -> productPriceId (for variations)
  final Map<String, String> _selectedProductPriceIds = {};
  bool _allWarehouses = true;
  var _selectedWarehouseIds = <String>[];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsCubit>().getProducts();
    });
    _nameController = TextEditingController(text: widget.pandel.name);
    _priceController = TextEditingController(
      text: widget.pandel.price.toString(),
    );
    _startDate = widget.pandel.startDate;
    _endDate = widget.pandel.endDate;
    _existingImages = List.from(widget.pandel.images);
    _allWarehouses = widget.pandel.allWarehouses;
    _selectedWarehouseIds = widget.pandel.warehouseIds ?? [];
    // Populate selected products map from existing pandel products
    // Note: productPriceId removed in migration 014
    for (final p in widget.pandel.products) {
      _selectedProducts[p.productId] = p.quantity;
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<ProductsCubit>().getProducts();
  //   });
  // }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty && mounted) {
      setState(() {
        for (final pickedFile in pickedFiles) {
          if (_newImages.length + _existingImages.length < 10) {
            _newImages.add(File(pickedFile.path));
          }
        }
      });

      if (pickedFiles.length > 10 ||
          (_newImages.length + _existingImages.length) > 10) {
        CustomSnackbar.showWarning(
          context,
          LocaleKeys.max_images_warning.tr(namedArgs: {'max': '10'}),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime(2000) : _startDate,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        CustomTextField(
          controller: controller,
          labelText: '',
          hintText: hint,
          hasBoxDecoration: false,
          hasBorder: true,
          prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required DateTime? selectedDate,
    required String title,
    required String hint,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 8),
              ),
              border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"
                      : hint,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: selectedDate != null
                        ? AppColors.darkGray
                        : AppColors.darkGray.withValues(alpha: 0.5),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: ResponsiveUI.iconSize(context, 20),
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    final allImages = [..._existingImages, ..._newImages];
    final width = ResponsiveUI.screenWidth(context);
    final imageSize = width * 0.28;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.pandel_images.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (allImages.isNotEmpty)
              TextButton.icon(
                icon: Icon(
                  Icons.delete,
                  color: AppColors.red,
                  size: ResponsiveUI.iconSize(context, 18),
                ),
                label: Text(
                  LocaleKeys.remove_all.tr(),
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: ResponsiveUI.fontSize(context, 12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _existingImages.clear();
                    _newImages.clear();
                  });
                },
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),

        if (allImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: ResponsiveUI.spacing(context, 8),
              mainAxisSpacing: ResponsiveUI.spacing(context, 8),
              childAspectRatio: 1,
            ),
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              final isExistingImage = index < _existingImages.length;

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8),
                      ),
                      border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8),
                      ),
                      child: isExistingImage
                          ? Image.network(
                              _existingImages[index],
                              fit: BoxFit.cover,
                              width: imageSize,
                              height: imageSize,
                              errorBuilder: (_, __, ___) =>
                                  const CustomImagePlaceholder(),
                            )
                          : Image.file(
                              _newImages[index - _existingImages.length],
                              fit: BoxFit.cover,
                              width: imageSize,
                              height: imageSize,
                            ),
                    ),
                  ),
                  Positioned(
                    top: ResponsiveUI.padding(context, 4),
                    right: ResponsiveUI.padding(context, 4),
                    child: GestureDetector(
                      onTap: () => isExistingImage
                          ? _removeExistingImage(index)
                          : _removeNewImage(index - _existingImages.length),
                      child: Container(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: ResponsiveUI.iconSize(context, 14),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!isExistingImage)
                    Positioned(
                      bottom: ResponsiveUI.padding(context, 4),
                      left: ResponsiveUI.padding(context, 4),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUI.padding(context, 6),
                          vertical: ResponsiveUI.padding(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 4)),
                        ),
                        child: Text(
                          LocaleKeys.new_label.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUI.fontSize(context, 10),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveUI.padding(context, 20),
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: ResponsiveUI.iconSize(context, 45),
                  color: AppColors.primaryBlue,
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                Text(
                  allImages.isEmpty
                      ? LocaleKeys.tap_to_upload_images.tr()
                      : LocaleKeys.tap_to_add_more_images.tr(),
                  style: TextStyle(
                    color: AppColors.darkGray.withValues(alpha: 0.7),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
                if (allImages.isNotEmpty)
                  Text(
                    '(${LocaleKeys.selected_images_count.tr(namedArgs: {'count': allImages.length.toString()})})',
                    style: TextStyle(
                      color: AppColors.darkGray.withValues(alpha: 0.5),
                      fontSize: ResponsiveUI.fontSize(context, 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openProductSelector(List productsState) async {
    await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 16))),
      ),
      builder: (context) {
        final tempSelected = Map<String, int>.from(_selectedProducts);
        final tempPriceIds = Map<String, String>.from(_selectedProductPriceIds);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.95,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    SizedBox(height: ResponsiveUI.value(context, 12)),
                    Container(
                      width: ResponsiveUI.value(context, 40),
                      height: ResponsiveUI.value(context, 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 2)),
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 16)),
                    Text(
                      LocaleKeys.select_products.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 8)),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: productsState.length,
                        itemBuilder: (context, index) {
                          final product = productsState[index];
                          final isSelected = tempSelected.containsKey(product.id);
                          final qty = tempSelected[product.id] ?? 1;
                          final selectedPriceId = tempPriceIds[product.id];

                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    tempSelected[product.id] = 1;
                                  } else {
                                    tempSelected.remove(product.id);
                                    tempPriceIds.remove(product.id);
                                  }
                                });
                              },
                            ),
                            title: Text(product.name),
                            subtitle: product.prices.isNotEmpty && isSelected
                                ? DropdownButton<String>(
                                    hint: Text(LocaleKeys.select_attribute.tr()),
                                    value: selectedPriceId,
                                    isExpanded: true,
                                    onChanged: (value) => setModalState(() {
                                      if (value != null) {
                                        tempPriceIds[product.id] = value;
                                      }
                                    }),
                                    items: product.prices.map((price) {
                                      return DropdownMenuItem<String>(
                                        value: price.id,
                                        child: Text('${price.code} - \$${price.price}'),
                                      );
                                    }).toList(),
                                  )
                                : null,
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        color: AppColors.primaryBlue,
                                        onPressed: qty > 1
                                            ? () => setModalState(() {
                                                  tempSelected[product.id] = qty - 1;
                                                })
                                            : null,
                                      ),
                                      Text('$qty',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: ResponsiveUI.fontSize(context, 16))),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        color: AppColors.primaryBlue,
                                        onPressed: () => setModalState(() {
                                          tempSelected[product.id] = qty + 1;
                                        }),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedProducts
                                ..clear()
                                ..addAll(tempSelected);
                              _selectedProductPriceIds
                                ..clear()
                                ..addAll(tempPriceIds);
                            });
                            Navigator.pop(context);
                          },
                          child: Text(LocaleKeys.done.tr()),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _validateAndSubmit() {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_pandel_name.tr(),
      );
      return;
    }

    // Validate products count
    if (_selectedProducts.length < 2) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_select_at_least_two_products.tr(),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_end_date_before_start.tr(),
      );
      return;
    }

    if (_existingImages.isEmpty && _newImages.isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_select_at_least_one_image.tr(),
      );
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_enter_price.tr());
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_valid_price.tr(),
      );
      return;
    }

    final products = _selectedProducts.entries
        .map((e) => PandelProduct(
              productId: e.key,
              // Note: productPriceId removed in migration 014
              quantity: e.value,
            ))
        .toList();

    context.read<PandelCubit>().updatePandel(
      pandelId: widget.pandel.id,
      name: _nameController.text.trim(),
      products: products,
      newImages: _newImages,
      existingImages: _existingImages,
      startDate: _startDate,
      endDate: _endDate,
      price: price,
      allWarehouses: _allWarehouses,
      warehouseIds: _allWarehouses ? null : _selectedWarehouseIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = BlocConsumer<PandelCubit, PandelState>(
      listener: (context, state) {
        if (state is UpdatePandelSuccess) {
          Navigator.pop(context, true);
        } else if (state is UpdatePandelError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdatePandelLoading;
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: LocaleKeys.edit_pandel.tr()),
          body: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, productsState) {
              return Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUI.padding(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            title: LocaleKeys.pandel_name.tr(),
                            hint: LocaleKeys.enter_pandel_name.tr(),
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 32)),
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUI.value(context, 48),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _validateAndSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ResponsiveUI.borderRadius(context, 12)),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: ResponsiveUI.iconSize(context, 20),
                                      width: ResponsiveUI.iconSize(context, 20),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.white),
                                      ),
                                    )
                                  : Text(
                                      LocaleKeys.update_pandel.tr(),
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(context, 16),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
