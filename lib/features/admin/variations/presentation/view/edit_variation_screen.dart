import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_gradient_divider.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/variations/cubit/variation_cubit.dart';
import 'package:systego/features/admin/variations/model/variation_model.dart';

class EditVariationBottomSheet extends StatefulWidget {
  final VariationModel variation;

  const EditVariationBottomSheet({super.key, required this.variation});

  @override
  State<EditVariationBottomSheet> createState() =>
      _EditVariationBottomSheetState();
}

class _EditVariationBottomSheetState extends State<EditVariationBottomSheet> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;

  List<VariationOption> _options = [];
  List<String> _optionsToDelete = [];

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.variation.name);
    _nameArController = TextEditingController(text: widget.variation.arName);
    _options = List.from(widget.variation.options);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  void _addOption() {
    setState(() {
      _options.add(
        VariationOption(
          id: '',
          variationId: widget.variation.id,
          name: '',
          status: true,
          createdAt: '',
          updatedAt: '',
          version: 0,
        ),
      );
    });
  }

  void _removeOption(int index, String optionId) {
    setState(() {
      if (optionId.isNotEmpty) {
        _optionsToDelete.add(optionId);
      }

      _options.removeAt(index);
    });
  }

  void _updateOptionName(int index, String value) {
    _options[index] = VariationOption(
      id: _options[index].id,
      variationId: _options[index].variationId,
      name: value,
      status: _options[index].status,
      createdAt: _options[index].createdAt,
      updatedAt: _options[index].updatedAt,
      version: _options[index].version,
    );
  }

  void _toggleOptionStatus(int index, bool value) {
    setState(() {
      _options[index] = VariationOption(
        id: _options[index].id,
        variationId: _options[index].variationId,
        name: _options[index].name,
        status: value,
        createdAt: _options[index].createdAt,
        updatedAt: _options[index].updatedAt,
        version: _options[index].version,
      );
    });
  }

  void _submitUpdate() async {
    if (_nameEnController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter Variation name (EN)');
      return;
    }
    if (_nameArController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter Variation name (AR)');
      return;
    }

    final optionsData = _options.map((o) {
      final map = {'name': o.name, 'status': o.status};
      if (o.id.isNotEmpty) map['_id'] = o.id;
      return map;
    }).toList();

    for (final id in _optionsToDelete) {
      await context.read<VariationCubit>().deleteOption(id);
    }

    await context.read<VariationCubit>().updateVariation(
      variationId: widget.variation.id,
      name: _nameEnController.text.trim(),
      arName: _nameArController.text.trim(),
      options: optionsData,
    );

    
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hint,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    final isDesktop = maxWidth > 600;

    return BlocConsumer<VariationCubit, VariationState>(
      listener: (context, state) {
        if (state is UpdateVariationSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdateVariationError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdateVariationLoading || state is DeleteOptionLoading;

        return Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(
            horizontal: isDesktop ? ResponsiveUI.padding(context, 20) : 0,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 243, 249, 254),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(
                    context,
                  ).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: ResponsiveUI.value(context, 40),
                            height: ResponsiveUI.value(context, 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 2),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        Text(
                          'Edit Variation',
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 20),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        _buildTextField(
                          controller: _nameEnController,
                          title: 'Variation Name (EN)',
                          hint: 'Enter Variation name in english',
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        _buildTextField(
                          controller: _nameArController,
                          title: 'Variation Name (Ar)',
                          hint: 'Enter Variation name in arabic',
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Options',
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _addOption,
                              child: const Text(
                                'Add Option',
                                style: TextStyle(color: AppColors.primaryBlue),
                              ),
                            ),
                          ],
                        ),
                        const CustomGradientDivider(),
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
                        ..._options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveUI.spacing(context, 8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    onChanged: (v) =>
                                        _updateOptionName(index, v),
                                    controller: TextEditingController(
                                      text: option.name,
                                    ),
                                    hintText: 'Option name',
                                    hasBoxDecoration: false,
                                    hasBorder: true,
                                  ),
                                ),

                                const SizedBox(width: 8),
                                Checkbox(
                                  activeColor: AppColors.primaryBlue,
                                  value: option.status,
                                  onChanged: (v) =>
                                      _toggleOptionStatus(index, v ?? true),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Option'),
                                        content: const Text(
                                          'Are you sure you want to delete this option?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmed == true) {
                                      _removeOption(index, option.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        SizedBox(height: ResponsiveUI.spacing(context, 24)),
                        SizedBox(
                          width: double.infinity,
                          height: ResponsiveUI.value(context, 48),
                          child: CustomElevatedButton(
                            onPressed: isLoading ? null : _submitUpdate,
                            text: isLoading
                                ? 'Updating...'
                                : 'Update Variation',
                            isLoading: isLoading,
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
