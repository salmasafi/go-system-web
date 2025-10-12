import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/widgets/custom_floating_action_button.dart';
import '../../../../../../core/widgets/custom_text_field_widget.dart';
import '../logic/cubit/categories_cubit.dart';
import 'create_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Toy', 'type': 'Electronic', 'count': 8, 'image': '🦁', 'color': Colors.yellow[100]},
    {'name': 'T-Shirt', 'type': 'Electronic', 'count': 12, 'image': '👕', 'color': Colors.grey[100]},
    {'name': 'Fruits', 'type': 'Electronic', 'count': 25, 'image': '🍎', 'color': Colors.red[100]},
    {'name': 'Computer', 'type': 'Electronic', 'count': 9, 'image': '💻', 'color': Colors.grey[200]},
  ];

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height =  MediaQuery.of(context).size.height;

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
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var cat = categories[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: height * 0.01),
                    padding: EdgeInsets.all(width * 0.01),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: width * 0.08,
                          height: width * 0.08,
                          decoration: BoxDecoration(color: cat['color'], borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Text(cat['image'], style: TextStyle(fontSize: 24))),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Text('${cat['type']}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text('${cat['count']} Products', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 20), onPressed: () {}),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () {}),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
        // Update categories_screen.dart floatingActionButton:
        floatingActionButton: CustomFloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: CategoriesCubit.get(context),
                  child: AddCategoryScreen(),
                ),
              ),
            );
          },
        )
    );
  }
}