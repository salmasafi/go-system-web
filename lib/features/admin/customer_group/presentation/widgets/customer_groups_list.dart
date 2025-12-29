import 'package:flutter/material.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/features/admin/customer_group/model/customer_group.dart';
import 'package:systego/features/admin/customer_group/presentation/widgets/customer_group_animated_card.dart';
import 'package:systego/features/admin/customer_group/presentation/widgets/customer_group_form_dialog.dart';

class CustomerGroupList extends StatelessWidget {
  final List<CustomerGroup> customerGroups;
  const CustomerGroupList({super.key, required this.customerGroups});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: customerGroups.length,
      itemBuilder: (context, index) {
        return AnimatedCustomerGroupCard(
          customerGroup: customerGroups[index],
          index: index,
        );
      },
    );
  }

}