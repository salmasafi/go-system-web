import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_error/custom_error_state.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/pandel/cubit/pandel_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CreatePandelScreen extends StatefulWidget {
  const CreatePandelScreen({super.key});

  @override
  State<CreatePandelScreen> createState() => _CreatePandelScreenState();
}

class _CreatePandelScreenState extends State<CreatePandelScreen> {
  final _nameController = TextEditingController();
  final _productsIdController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  final List<File> _selectedImages = [];

  final _picker = ImagePicker();

  List<String> _selectedProductIds = [];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (final pickedFile in pickedFiles) {
          if (_selectedImages.length < 10) {
            // Limit to 10 images
            _selectedImages.add(File(pickedFile.path));
          }
        }
      });

      if (pickedFiles.length > 10) {
        CustomSnackbar.showWarning(
          context,
          LocaleKeys.max_images_warning.tr(namedArgs: {'max': '10'}),
        );
      }
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<ProductsCubit>().getProducts();
  //   });
  // }

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ProductsCubit>().getProducts();
  });
}


  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 30)));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
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

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
          // If end date is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
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
          prefixIconColor: AppColors.darkGray.withOpacity(0.7),
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
              border: Border.all(color: AppColors.lightGray, width: 1),
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
                        : AppColors.darkGray.withOpacity(0.5),
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

  Widget _buildImagesPicker() {
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
            if (_selectedImages.isNotEmpty)
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
                    _selectedImages.clear();
                  });
                },
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),

        // Selected images grid
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: ResponsiveUI.spacing(context, 8),
              mainAxisSpacing: ResponsiveUI.spacing(context, 8),
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8),
                      ),
                      border: Border.all(color: AppColors.lightGray, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUI.borderRadius(context, 8),
                      ),
                      child: Image.file(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                        width: imageSize,
                        height: imageSize,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: EdgeInsets.all(
                          ResponsiveUI.padding(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.9),
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
                ],
              );
            },
          ),

        // Add image button
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
              border: Border.all(color: AppColors.lightGray, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                  _selectedImages.isEmpty
                      ? LocaleKeys.tap_to_upload_images.tr()
                      : LocaleKeys.tap_to_add_more_images.tr(),
                  style: TextStyle(
                    color: AppColors.darkGray.withOpacity(0.7),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Text(
                    '(${LocaleKeys.selected_images_count.tr(namedArgs: {'count': _selectedImages.length.toString()})})',
                    style: TextStyle(
                      color: AppColors.darkGray.withOpacity(0.5),
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

  void _validateAndSubmit() {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_enter_pandel_name.tr(),
      );
      return;
    }

    // Validate products count
    if (_selectedProductIds.length < 2) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_select_at_least_two_products.tr(),
      );
      return;
    }

    // Validate products IDs
    // if (_productsIdController.text.trim().isEmpty) {
    //   CustomSnackbar.showWarning(
    //     context,
    //     LocaleKeys.warning_enter_products_ids.tr(),
    //   );
    //   return;
    // }

    // Parse products IDs
    // final productsId = _productsIdController.text
    //     .trim()
    //     .split(',')
    //     .map((id) => id.trim())s
    //     .where((id) => id.isNotEmpty)
    //     .toList();

    // if (productsId.isEmpty) {
    //   CustomSnackbar.showWarning(
    //     context,
    //     LocaleKeys.warning_enter_valid_products_ids.tr(),
    //   );
    //   return;
    // }

    // Validate dates
    if (_startDate == null) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_select_start_date.tr(),
      );
      return;
    }

    if (_endDate == null) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_select_end_date.tr(),
      );
      return;
    }

    // Validate date range
    if (_endDate!.isBefore(_startDate!)) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_end_date_before_start.tr(),
      );
      return;
    }

    // Validate images
    if (_selectedImages.isEmpty) {
      CustomSnackbar.showWarning(
        context,
        LocaleKeys.warning_select_at_least_one_image.tr(),
      );
      return;
    }

    // Validate price
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

    // Submit to cubit
    context.read<PandelCubit>().addPandel(
      name: _nameController.text.trim(),
      productsId: _selectedProductIds,
      images: _selectedImages,
      startDate: _startDate!,
      endDate: _endDate!,
      price: price,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PandelCubit, PandelState>(
      listener: (context, state) {
        if (state is CreatePandelSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreatePandelError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is CreatePandelSuccess) {
          return Scaffold(
            backgroundColor: AppColors.lightBlueBackground,
            appBar: appBarWithActions(
              context,
              title: LocaleKeys.new_pandel.tr(),
            ),
            body: CustomErrorState(
              message: state.message,
              onRetry: _validateAndSubmit,
            ),
          );
        }

        final isLoading = state is CreatePandelLoading;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: LocaleKeys.new_pandel.tr()),
          body: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, productsState) {
              return Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            title: LocaleKeys.pandel_name.tr(),
                            hint: LocaleKeys.enter_pandel_name.tr(),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: ResponsiveUI.spacing(context, 8),
                              ),
                              if (productsState is ProductsSuccess)
                                _buildMultiSelectDropdown<String>(
                                  label: LocaleKeys.products.tr(),
                                  hint: LocaleKeys.select_products.tr(),
                                  items: productsState.products
                                      .map((w) => w.id)
                                      .toList(),
                                  selectedItems: _selectedProductIds,
                                  itemLabel: (id) => productsState.products
                                      .firstWhere((w) => w.id == id)
                                      .name,
                                  onChanged: (List<String> v) {
                                    setState(() {
                                      _selectedProductIds = v;
                                    });
                                  },
                                  icon: Icons.inventory_2_rounded,
                                  validator: (v) => v.length < 2
                                      ? LocaleKeys
                                            .warning_select_at_least_two_products
                                            .tr()
                                      : null,
                                ),
                              if (productsState is ProductsError)
                                Text(
                                  productsState.message,
                                  style: TextStyle(color: AppColors.red),
                                ),
                            ],
                          ),

                          SizedBox(height: ResponsiveUI.spacing(context, 12)),

                          _buildDatePicker(
                            selectedDate: _startDate,
                            title: LocaleKeys.start_date.tr(),
                            hint: LocaleKeys.select_start_date.tr(),
                            onTap: () => _selectDate(context, true),
                          ),

                          _buildDatePicker(
                            selectedDate: _endDate,
                            title: LocaleKeys.end_date.tr(),
                            hint: LocaleKeys.select_end_date.tr(),
                            onTap: () => _selectDate(context, false),
                          ),

                          _buildTextField(
                            controller: _priceController,
                            title: LocaleKeys.price.tr(),
                            hint: LocaleKeys.enter_price.tr(),
                            keyboardType: TextInputType.number,
                          ),

                          _buildImagesPicker(),

                          SizedBox(height: ResponsiveUI.spacing(context, 24)),
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUI.value(context, 48),
                            child: CustomElevatedButton(
                              onPressed: isLoading ? null : _validateAndSubmit,
                              text: isLoading
                                  ? LocaleKeys.saving_pandel.tr()
                                  : LocaleKeys.save_pandel.tr(),
                              isLoading: isLoading,
                            ),
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        ],
                      ),
                    ),
                  ),
                  // Products loading overlay
                  if (productsState is ProductsLoading)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                            Text(LocaleKeys.processing.tr()),
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
  }

  Widget _buildMultiSelectDropdown<T>({
    required String label,
    required String hint,
    required List<T> items,
    required List<T> selectedItems,
    required String Function(T) itemLabel,
    required void Function(List<T>) onChanged,
    IconData? icon,
    String? Function(List<T>)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),

        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<List<T>>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                final tempSelected = List<T>.from(selectedItems);

                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            hint,
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Expanded(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return CheckboxListTile(
                                  title: Text(itemLabel(item)),
                                  value: tempSelected.contains(item),
                                  onChanged: (checked) {
                                    setModalState(() {
                                      if (checked == true) {
                                        tempSelected.add(item);
                                      } else {
                                        tempSelected.remove(item);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, tempSelected);
                                },
                                child: Text(LocaleKeys.done.tr()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );

            if (result != null) {
              onChanged(result);
            }
          },

          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.primaryBlue),
                  SizedBox(width: ResponsiveUI.spacing(context, 8)),
                ],
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? hint
                        : "${selectedItems.length} ${LocaleKeys.selected.tr()}",
                    style: TextStyle(
                      color: selectedItems.isEmpty
                          ? AppColors.darkGray.withOpacity(0.5)
                          : AppColors.darkGray,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),

        if (validator != null && validator(selectedItems) != null)
          Padding(
            padding: EdgeInsets.only(top: ResponsiveUI.spacing(context, 4)),
            child: Text(
              validator(selectedItems)!,
              style: TextStyle(
                color: AppColors.red,
                fontSize: ResponsiveUI.fontSize(context, 12),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _productsIdController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
