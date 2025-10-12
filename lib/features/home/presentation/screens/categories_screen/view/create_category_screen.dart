import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_text_field_widget.dart';
import '../logic/cubit/categories_cubit.dart';
import '../logic/cubit/categories_states.dart';


class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  final _parentController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return BlocConsumer<CategoriesCubit, CategoriesState>(
      listener: (context, state) {
        if (state is CreateCategorySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else if (state is CreateCategoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 0.05 * height),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
                    Expanded(child: Text("New Category", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category Name*', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'T-Shirt',
                          hasBoxDecoration: false,
                          hasBorder: true,
                        ),
                        SizedBox(height: height * 0.02),
                        Text('Parent Category*', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: height * 0.01),
                        CustomTextField(
                          controller: _parentController,
                          labelText: 'Clothing',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.arrow_drop_down,
                        ),
                        SizedBox(height: height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Category Image*', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            if (_selectedImage != null)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => setState(() => _selectedImage = null),
                              ),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: width * 0.3,
                            height: width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                                : Icon(Icons.checkroom, size: 50, color: Colors.grey),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state is CreateCategoryLoading
                                ? null
                                : () {
                              if (_nameController.text.isEmpty || _selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill all required fields')),
                                );
                                return;
                              }
                              CategoriesCubit.get(context).createCategory(
                                name: _nameController.text,
                                imageFile: _selectedImage!,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: state is CreateCategoryLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _parentController.dispose();
    super.dispose();
  }
}