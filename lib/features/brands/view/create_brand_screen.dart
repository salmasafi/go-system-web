import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import '../../../core/widgets/custom_error/custom_error_state.dart';
import '../cubit/brand_cubit.dart';
import '../cubit/brand_states.dart';

class AddBrandScreen extends StatefulWidget {
  const AddBrandScreen({super.key});

  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = ResponsiveUI.screenWidth(context);
    //final height = ResponsiveUI.screenHeight(context);

    return BlocConsumer<BrandsCubit, BrandsState>(
      listener: (context, state) {
        if (state is CreateBrandSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is CreateBrandError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CreateBrandError) {
          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: appBarWithActions(
              context,
              "New Brand",
              () {},
              showActions: false,
            ),
            body: CustomErrorState(
              message: state.error,
              onRetry: () {
                if (_nameController.text.trim().isEmpty ||
                    _selectedImage == null) {
                  return;
                }
                BrandsCubit.get(context).createBrand(
                  name: _nameController.text.trim(),
                  logoFile: _selectedImage!,
                );
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: appBarWithActions(
            context,
            "New Brand",
            () {},
            showActions: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  Text(
                    'Brand Name',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  CustomTextField(
                    controller: _nameController,
                    labelText: '',
                    hintText: 'Enter brand name',
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.branding_watermark,
                    prefixIconColor: AppColors.darkGray.withOpacity(0.7),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Brand Logo ',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_selectedImage != null)
                        TextButton.icon(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.red,
                            size: ResponsiveUI.iconSize(context, 18),
                          ),
                          label: Text(
                            'Remove',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: ResponsiveUI.fontSize(context, 12),
                            ),
                          ),
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                        ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: width * 0.35,
                      height: width * 0.35,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 12),
                              ),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                key: ValueKey(_selectedImage!.path),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: ResponsiveUI.iconSize(context, 45),
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 8),
                                ),
                                Text(
                                  'Tap to upload',
                                  style: TextStyle(
                                    color: AppColors.darkGray.withOpacity(0.7),
                                    fontSize: ResponsiveUI.fontSize(
                                      context,
                                      13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 48),
                    child: CustomElevatedButton(
                      onPressed: state is CreateBrandLoading
                          ? null
                          : () {
                              if (_nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Please enter brand name',
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: EdgeInsets.all(
                                      ResponsiveUI.padding(context, 12),
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (_selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Please select a logo'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin: EdgeInsets.all(
                                      ResponsiveUI.padding(context, 12),
                                    ),
                                  ),
                                );
                                return;
                              }
                              BrandsCubit.get(context).createBrand(
                                name: _nameController.text.trim(),
                                logoFile: _selectedImage!,
                              );
                            },
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: AppColors.primaryBlue,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                      //   ),
                      //   elevation: 2,
                      // ),
                      text: state is CreateBrandLoading
                          ? 'Saving Brand'
                          : 'Save Brand',
                      // child: state is CreateBrandLoading
                      //     ? SizedBox(
                      //   height: ResponsiveUI.iconSize(context, 24),
                      //   width: ResponsiveUI.iconSize(context, 24),
                      //   child: CircularProgressIndicator(
                      //     color: AppColors.white,
                      //     strokeWidth: 2.5,
                      //   ),
                      // )
                      //     : Text(
                      //   'Save Brand',
                      //   style: TextStyle(
                      //     fontSize: ResponsiveUI.fontSize(context, 16),
                      //     fontWeight: FontWeight.w600,
                      //     color: AppColors.white,
                      //   ),
                      // ),
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
    _nameController.dispose();
    super.dispose();
  }
}
