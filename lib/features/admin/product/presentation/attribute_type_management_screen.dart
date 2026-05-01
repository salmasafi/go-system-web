import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animation/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/features/admin/product/presentation/widgets/search_bar_widget.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_error/custom_empty_state.dart';
import '../../../../core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import '../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../cubit/attribute_type_cubit/attribute_type_cubit.dart';
import '../cubit/attribute_type_cubit/attribute_type_state.dart';
import '../models/attribute_type_model.dart';
import 'widgets/attribute_type_card_widget.dart';
import 'widgets/create_attribute_type_dialog.dart';
import 'widgets/delete_attribute_type_dialog.dart';

class AttributeTypeManagementScreen extends StatefulWidget {
  const AttributeTypeManagementScreen({super.key});

  @override
  State<AttributeTypeManagementScreen> createState() => _AttributeTypeManagementScreenState();
}

class _AttributeTypeManagementScreenState extends State<AttributeTypeManagementScreen> {
  String _searchQuery = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    AttributeTypeCubit.get(context).loadAttributeTypes();
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
    });
    await AttributeTypeCubit.get(context).loadAttributeTypes();
  }

  Widget _buildListContent(AttributeTypeState state) {
    if (state is AttributeTypeLoading) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: const CustomLoadingShimmer(),
      );
    }

    if (state is AttributeTypeError) {
      return CustomEmptyState(
        icon: Icons.category,
        title: 'Error Occurred',
        message: state.message,
        onRefresh: _refresh,
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    }

    final cubit = AttributeTypeCubit.get(context);
    final attributeTypes = cubit.attributeTypes;

    List<AttributeType> filteredTypes = attributeTypes
        .where(
          (type) => type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              type.arName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredTypes.isEmpty) {
      String title = attributeTypes.isEmpty
          ? 'No Attribute Types Available'
          : 'No Matching Attribute Types';
      String message = attributeTypes.isEmpty
          ? 'Add your first attribute type to get started'
          : 'Try adjusting your search criteria';
      return CustomEmptyState(
        icon: Icons.category,
        title: title,
        message: message,
        onRefresh: _refresh,
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUI.padding(context, 16),
        ),
        itemCount: filteredTypes.length,
        itemBuilder: (context, index) {
          return AnimatedElement(
            delay: Duration(milliseconds: index * 50),
            child: AttributeTypeCard(
              attributeType: filteredTypes[index],
              onEdit: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => CreateAttributeTypeDialog(
                    attributeType: filteredTypes[index],
                  ),
                ).then((result) {
                  if (result == true && mounted) {
                    AttributeTypeCubit.get(context).loadAttributeTypes();
                  }
                });
              },
              onDelete: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => DeleteAttributeTypeDialog(
                    attributeTypeName: filteredTypes[index].name,
                    onDelete: () {
                      Navigator.pop(dialogContext);
                      AttributeTypeCubit.get(context).deleteAttributeType(filteredTypes[index].id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: 'Attribute Types',
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => const CreateAttributeTypeDialog(),
          ).then((result) {
            if (result == true && mounted) {
              AttributeTypeCubit.get(context).loadAttributeTypes();
            }
          });
        },
        showActions: true,
      ),
      body: BlocConsumer<AttributeTypeCubit, AttributeTypeState>(
        listener: (context, state) {
          if (state is AttributeTypeCreated) {
            _showSuccessSnackbar(context, state.message);
          } else if (state is AttributeTypeUpdated) {
            _showSuccessSnackbar(context, state.message);
          } else if (state is AttributeTypeDeleted) {
            _showSuccessSnackbar(context, state.message);
          } else if (state is AttributeTypeError) {
            CustomSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUI.contentMaxWidth(context),
              ),
              child: Column(
                children: [
                  AnimatedElement(
                    delay: Duration.zero,
                    child: SearchBarWidget(
                      onChanged: (String query) {
                        setState(() {
                          _searchQuery = query.toLowerCase().trim();
                        });
                      },
                      controller: controller,
                      text: 'Attribute Types',
                    ),
                  ),
                  Expanded(
                    child: AnimatedElement(
                      delay: const Duration(milliseconds: 200),
                      child: _buildListContent(state),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success',
        message: message,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
