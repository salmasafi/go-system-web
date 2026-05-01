import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/features/pos/home/cubit/pos_home_cubit.dart';
import '../cubit/return_cubit.dart';
import '../screens/return_details_screen.dart';

class ReturnSearchDialog extends StatefulWidget {
  const ReturnSearchDialog({super.key});

  @override
  State<ReturnSearchDialog> createState() => _ReturnSearchDialogState();
}

class _ReturnSearchDialogState extends State<ReturnSearchDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReturnCubit, ReturnState>(
      listener: (context, state) {
        if (state is ReturnSaleLoaded) {
          final returnCubit = context.read<ReturnCubit>();
          final posCubit = context.read<PosCubit>();
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: returnCubit),
                  BlocProvider.value(value: posCubit),
                ],
                child: ReturnDetailsScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ReturnSearchLoading;

        return AlertDialog(
          title: Text('return_sale'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'reference_number'.tr(),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: isLoading ? null : (_) => _search(context),
              ),
              if (state is ReturnSearchError) ...[
                SizedBox(height: ResponsiveUI.value(context, 8)),
                Text(
                  state.message,
                  style: TextStyle(color: AppColors.red, fontSize: ResponsiveUI.fontSize(context, 13)),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.categoryPurple,
                foregroundColor: AppColors.white,
              ),
              onPressed: isLoading ? null : () => _search(context),
              child: isLoading
                  ? SizedBox(
                      width: ResponsiveUI.value(context, 18),
                      height: ResponsiveUI.value(context, 18),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Text('search_sale'.tr()),
            ),
          ],
        );
      },
    );
  }

  void _search(BuildContext context) {
    context.read<ReturnCubit>().searchSale(_controller.text);
  }
}
