// categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_floating_action_button.dart';
import '../../../../../../core/widgets/custom_text_faild_widget.dart';
import '../logic/cubit/categories_cubit.dart';
import '../logic/cubit/categories_states.dart';
import 'create_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    CategoriesCubit.get(context).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.05 * height),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back)),
                Expanded(child: Text("Categories", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.03),
              child: CustomTextField(
                controller: _controller,
                labelText: 'Search',
                prefixIcon: Icons.search,
                hasBoxDecoration: false,
                hasBorder: true,
                prefixIconColor: AppColors.darkGray,
              ),
            ),
            Expanded(
              child: BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state is GetCategoriesLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final cubit = CategoriesCubit.get(context);
                  if (cubit.allCategories.isEmpty) {
                    return Center(child: Text('No categories found'));
                  }

                  return RefreshIndicator(
                    onRefresh: () => cubit.getCategories(),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                      itemCount: cubit.allCategories.length,
                      itemBuilder: (context, index) {
                        var cat = cubit.allCategories[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: height * 0.01),
                          padding: EdgeInsets.all(width * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: width * 0.15,
                                height: width * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    cat.image ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(Icons.category, color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cat.name ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                    if (cat.parentId != null)
                                      Text('Parent: ${cat.parentId!.name}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Text('${cat.productQuantity ?? 0} Products', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                                    onPressed: () {
                                      // يمكن تفتحي صفحة edit وتستخدمي getCategoryById
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () {
                                      // Delete functionality
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddCategoryScreen()));
        },
      ),
    );
  }
}