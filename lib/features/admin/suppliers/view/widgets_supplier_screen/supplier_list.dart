import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/simple_fadein_animation_widget.dart';
import '../../model/supplier_model.dart';
import 'supplier_card.dart';

class SupplierList extends StatelessWidget {
  final List<Suppliers> suppliers;

  const SupplierList({
    super.key,
    required this.suppliers,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return FadeInAnimation(
          delay: Duration(milliseconds: index * 200),
          child: SupplierCard(supplier: supplier),
        );
      },
    );
  }
}
