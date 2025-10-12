import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import '../../../../../../core/utils/responsive_ui.dart';
import '../../../../../../core/widgets/custom_floating_action_button.dart';
import '../../../../../../core/widgets/custom_text_faild_widget.dart';

class BrandsScreen extends StatefulWidget {
  const BrandsScreen({super.key});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  final _controller = TextEditingController();

  final List<Map<String, dynamic>> brands = [
    {'name': 'Apple', 'count': 6, 'image': '🍎', 'color': Colors.grey[100]},
    {'name': 'Google', 'count': 12, 'image': '🔍', 'color': Colors.blue[50]},
    {'name': 'Microsoft', 'count': 25, 'image': '🪟', 'color': Colors.blue[100]},
    {'name': 'Amazon', 'count': 9, 'image': '📦', 'color': Colors.orange[50]},
    {'name': 'Xiaomi', 'count': 12, 'image': '📱', 'color': Colors.orange[100]},
    {'name': 'Oppo', 'count': 25, 'image': '💚', 'color': Colors.green[50]},
    {'name': 'Samsung', 'count': 25, 'image': '📺', 'color': Colors.blue[50]},
    {'name': 'Vivo', 'count': 25, 'image': '💙', 'color': Colors.blue[100]},
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
                Expanded(child: Text("Brands", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
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
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  var brand = brands[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: height * 0.01),
                    padding: EdgeInsets.all(width * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: width * 0.075,
                          height: width * 0.075,
                          decoration: BoxDecoration(color: brand['color'], borderRadius: BorderRadius.circular(8)),
                          child: Center(child: Text(brand['image'], style: TextStyle(fontSize: 22))),
                        ),
                        SizedBox(width: width * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(brand['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              Text('${brand['count']} Products', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        IconButton(icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 20), onPressed: () {}),
                        IconButton(icon: Icon(Icons.delete, color: AppColors.red, size: 20), onPressed: () {}),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
        floatingActionButton: CustomFloatingActionButton(onPressed: (){})

    );
  }
}