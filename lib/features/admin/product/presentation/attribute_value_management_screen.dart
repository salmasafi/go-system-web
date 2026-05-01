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
import '../cubit/attribute_value_cubit/attribute_value_cubit.dart';
import '../cubit/attribute_value_cubit/attribute_value_state.dart';
import '../models/attribute_value_model.dart';
import 'widgets/attribute_value_card_widget.dart';
import 'widgets/create_attribute_value_dialog.dart';
import 'widgets/delete_attribute_value_dialog.dart';

class AttributeValueManagementScreen extends StatefulWidget {
  final String attributeTypeId;
  final String attributeTypeName;

  const AttributeValueManagementScreen({
    super.key,
    required this.attributeTypeId,
    required this.attributeTypeName,
  });

  @override
  State<AttributeValueManagementScreen> createState() => _AttributeValueManagementScreenState();
}

class _AttributeValueManagementScreenState extends State<AttributeValueManagementScreen> {
  String _searchQuery = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    AttributeValueCubit.get(context).loadAttributeValues(widget.attributeTypeId);
  }

  Future<void> _refresh() async {
    setState(() {
      _searchQuery = '';
    });
    await AttributeValueCubit.get(context).loadAttributeValues(widget.attributeTypeId);
  }

  Widget _buildListContent(AttributeValueState state) {
    if (state is AttributeValueLoading) {
      return RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryBlue,
        child: const CustomLoadingShimmer(),
      );
    }

    if (state is AttributeValueError) {
      return CustomEmptyState(
        icon: Icons.list_alt,
        title: 'Error Occurred',
        message: state.message,
        onRefresh: _refresh,
        actionLabel: 'Retry',
        onAction: _refresh,
      );
    }

    final cubit = AttributeValueCubit.get(context);
    final attributeValues = cubit.attributeValues;

    List<AttributeValue> filteredValues = attributeValues
        .where(
          (value) => value.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              value.arName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filteredValues.isEmpty) {
      String title = attributeValues.isEmpty
          ? 'No Attribute Values Available'
          : 'No Matching Attribute Values';
      String message = attributeValues.isEmpty
          ? 'Add your first attribute value to get started'
          : 'Try adjusting your search criteria';
      return CustomEmptyState(
        icon: Icons.list_alt,
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
        itemCount: filteredValues.length,
        itemBuilder: (context, index) {
          return AnimatedElement(
            delay: Duration(milliseconds: index * 50),
            child: AttributeValueCard(
              attributeValue: filteredValues[index],
              onEdit: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => CreateAttributeValueDialog(
                    attributeValue: filteredValues[index],
                    attributeTypeId: widget.attributeTypeId,
                  ),
                ).then((result) {
                  if (result == true && mounted) {
                    AttributeValueCubit.get(context).loadAttributeValues(widget.attributeTypeId);
                  }
                });
              },
              onDelete: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => DeleteAttributeValueDialog(
                    attributeValueName: filteredValues[index].name,
                    onDelete: () {
                      Navigator.pop(dialogContext);
                      AttributeValueCubit.get(context).deleteAttributeValue(filteredValues[index].id);
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
        title: '${widget.attributeTypeName} Values',
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => CreateAttributeValueDialog(
              attributeTypeId: widget.attributeTypeId,
            ),
          ).then((result) {
            if (result == true && mounted) {
              AttributeValueCubit.get(context).loadAttributeValues(widget.attributeTypeId);
            }
          });
        },
        showActions: true,
      ),
      body: BlocConsumer<AttributeValueCubit, AttributeValueState>(
        listener: (context, state) {
          if (state is AttributeValueCreated) {
            _showSuccessSnackbar(context, state.message);
          } else if (state is AttributeValueUpdated) {
            _showSuccessSnackbar(context, state.message);
          } else if (state is AttributeValueDeleted) {
            _showSuccessSnackbar(context, state.message);
          } else if (state is AttributeValueError) {
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
                      text: 'Attribute Values',
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
