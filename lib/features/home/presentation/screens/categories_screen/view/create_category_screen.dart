import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import '../../../../../../core/widgets/custom_text_faild_widget.dart';
import '../logic/cubit/categories_cubit.dart';
import '../logic/cubit/categories_states.dart';
import '../logic/model/get_categories_model.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  File? _selectedImage;
  CategoryItem? _selectedParentCategory;
  bool _makeParentCategory = true;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  @override
  void initState() {
    super.initState();
    CategoriesCubit.get(context).getCategories();
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
        final cubit = CategoriesCubit.get(context);

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(width * 0.04),
                  child: Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
                      Expanded(child: Text("New Category", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Category Name*', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Enter category name',
                          hasBoxDecoration: false,
                          hasBorder: true,
                        ),
                        SizedBox(height: 20),

                        CheckboxListTile(
                          value: _makeParentCategory,
                          onChanged: (value) {
                            setState(() {
                              _makeParentCategory = value ?? true;
                              if (_makeParentCategory) _selectedParentCategory = null;
                            });
                          },
                          title: Text('Set as an independent (or parent) category', style: TextStyle(fontSize: 14)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primaryBlue,
                        ),

                        if (!_makeParentCategory) ...[
                          SizedBox(height: 15),
                          Text('Parent Category*', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          SizedBox(height: 8),

                          if (state is GetCategoriesLoading)
                            Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                          else if (cubit.parentCategories.isEmpty)
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('No parent categories available. Create a parent category first.', style: TextStyle(fontSize: 12, color: Colors.orange[900]))),
                                ],
                              ),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CategoryItem>(
                                  isExpanded: true,
                                  value: _selectedParentCategory,
                                  hint: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Select parent category')),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  icon: Icon(Icons.arrow_drop_down, color: AppColors.darkGray),
                                  items: cubit.parentCategories.map((category) {
                                    return DropdownMenuItem<CategoryItem>(
                                      value: category,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: Colors.grey[200]),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: Image.network(category.image ?? '', fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.category, size: 16)),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(category.name ?? ''),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedParentCategory = value),
                                ),
                              ),
                            ),
                        ],

                        SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Category Image*', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                            if (_selectedImage != null)
                              TextButton.icon(
                                icon: Icon(Icons.delete, color: Colors.red, size: 18),
                                label: Text('Remove', style: TextStyle(color: Colors.red, fontSize: 12)),
                                onPressed: () => setState(() => _selectedImage = null),
                              ),
                          ],
                        ),
                        SizedBox(height: 10),

                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: width * 0.35,
                            height: width * 0.35,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover, key: ValueKey(_selectedImage!.path)),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 45, color: Colors.grey[400]),
                                SizedBox(height: 8),
                                Text('Tap to upload', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: state is CreateCategoryLoading
                                ? null
                                : () {
                              if (_nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter category name')));
                                return;
                              }
                              if (_selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an image')));
                                return;
                              }
                              if (!_makeParentCategory && _selectedParentCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a parent category')));
                                return;
                              }

                              cubit.createCategory(
                                name: _nameController.text.trim(),
                                imageFile: _selectedImage!,
                                parentId: _makeParentCategory ? null : _selectedParentCategory?.id,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: state is CreateCategoryLoading
                                ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text('Save Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ),
                        SizedBox(height: 20),
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
    super.dispose();
  }
}