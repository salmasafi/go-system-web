import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import '../../../../../core/widgets/custom_snck_bar/custom_snackbar.dart';
import '../../../warehouses/view/widgets/custom_delete_dialog.dart';
import '../../cubit/city_cubit.dart';
import '../../model/city_model.dart';
import 'animated_city_card.dart';
import 'city_form_dialog.dart';

class CitiesList extends StatelessWidget {
  final List<CityModel> cities;
  const CitiesList({super.key, required this.cities});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        right: ResponsiveUI.padding(context, 16),
        left: ResponsiveUI.padding(context, 16),
        top: ResponsiveUI.padding(context, 16),
      ),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        return AnimatedCityCard(
          city: cities[index],
          index: index,
          onDelete: () => _showDeleteDialog(context, cities[index]),
          onEdit: () => _showEditDialog(context, cities[index]),
          //onTap: () => _showSelectDialog(context, cities[index]),
        );
      },
    );
  }

  void _showEditDialog(
    BuildContext context,
    CityModel city,
  ) {
    showDialog(
      context: context,
      builder: (context) => CityFormDialog(city: city),
    );
  }

  void _showDeleteDialog(BuildContext context, CityModel city) {
    if (city.id.isEmpty) {
      CustomSnackbar.showError(context, 'Invalid City ID');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete City',
        message: 'Are you sure you want to delete this city?\n"${city.name}"',
        onDelete: () {
          Navigator.pop(dialogContext);
          context.read<CityCubit>().deleteCity(city.id);
        },
      ),
    );
  }

  // void _showSelectDialog(BuildContext context, CityModel city) {
  //   if (city.id.isEmpty) {
  //     CustomSnackbar.showError(context, 'Invalid City ID');
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => CustomDeleteDialog(
  //       title: 'Select City',
  //       message:
  //           'Are you sure you want to select this City as the default?\n"${city.name}"',
  //       icon: Icons.check_circle_rounded,
  //       iconColor: AppColors.primaryBlue,
  //       deleteText: 'Select',
  //       onDelete: () {
  //         Navigator.pop(dialogContext);
  //         context.read<CityCubit>().selectCity(city.id, city.name);
  //       },
  //     ),
  //   );
  // }

}
