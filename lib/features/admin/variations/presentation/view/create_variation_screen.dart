import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/variations/cubit/variation_cubit.dart';

class CreateVariationScreen extends StatefulWidget {
  const CreateVariationScreen({super.key});

  @override
  State<CreateVariationScreen> createState() => _CreateVariationScreenState();
}

class _CreateVariationScreenState extends State<CreateVariationScreen> {
  final _nameEnController = TextEditingController();
  final _nameArController = TextEditingController();

  List<Map<String, dynamic>> _options = [];

  void _addOption() {
    setState(() {
      _options.add({"name": "", "status": true});
    });
  }

  // Remove option at index
  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  // Update option
  void _updateOptionName(int index, String name) {
    setState(() {
      _options[index]["name"] = name;
    });
  }

  void _toggleOptionStatus(int index) {
    setState(() {
      _options[index]["status"] = !_options[index]["status"];
    });
  }

  void _validateAndSubmit() {
    if (_nameEnController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter Variation name in English');
      return;
    }
    if (_nameArController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, 'Please enter Variation name in Arabic');
      return;
    }
    if (_options.isEmpty) {
      CustomSnackbar.showWarning(context, 'Please add at least one option');
      return;
    }
    for (var option in _options) {
      if ((option["name"] as String).trim().isEmpty) {
        CustomSnackbar.showWarning(context, 'All options must have a name');
        return;
      }
    }

    context.read<VariationCubit>().addVariation(
          name: _nameEnController.text.trim(),
          arName: _nameArController.text.trim(),
          options: _options,
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

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          'Options',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        ..._options.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> option = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: TextEditingController(text: option["name"])
                      ..selection = TextSelection.fromPosition(
                          TextPosition(offset: option["name"].length)),
                    hintText: 'Option name',
                    hasBoxDecoration: false,
                    hasBorder: true,
                    onChanged: (value) => _updateOptionName(index, value),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    option["status"] ? Icons.check_box : Icons.check_box_outline_blank,
                    color: option["status"] ? AppColors.primaryBlue : AppColors.lightGray,
                  ),
                  onPressed: () => _toggleOptionStatus(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.red),
                  onPressed: () => _removeOption(index),
                ),
              ],
            ),
          );
        }).toList(),
        SizedBox(height: 8),
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add, color: AppColors.primaryBlue,),
          label: const Text('Add Option', style: TextStyle(
            color: AppColors.primaryBlue
          ),),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VariationCubit, VariationState>(
      listener: (context, state) {
        if (state is CreateVariationSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreateVariationError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreateVariationLoading;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: "New Variation"),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _nameEnController,
                    title: 'Variation Name (En)',
                    hint: 'Enter variation name in English',
                  ),
                  _buildTextField(
                    controller: _nameArController,
                    title: 'Variation Name (Ar)',
                    hint: 'Enter variation name in Arabic',
                  ),
                  _buildOptions(),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 48),
                    child: CustomElevatedButton(
                      onPressed: isLoading ? null : _validateAndSubmit,
                      text: isLoading ? 'Saving Variation' : 'Save Variation',
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

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }
}
