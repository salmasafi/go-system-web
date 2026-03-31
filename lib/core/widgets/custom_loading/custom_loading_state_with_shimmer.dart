import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:systego/core/utils/responsive_ui.dart';

import '../../constants/app_colors.dart';

class CustomLoadingShimmer extends StatelessWidget {
  final int? itemCount;
  final EdgeInsets? padding;

  const CustomLoadingShimmer({super.key, this.itemCount, this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding:
          padding ??
          EdgeInsets.only(
            bottom: ResponsiveUI.padding(context, 16),
            left: ResponsiveUI.padding(context, 16),
            right: ResponsiveUI.padding(context, 16),
          ),
      itemCount: itemCount ?? 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.lightGray.withValues(alpha: 0.3),
          highlightColor: AppColors.white,
          child: Container(
            margin: EdgeInsets.only(bottom: ResponsiveUI.padding(context, 16)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
            ),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: ResponsiveUI.value(context, 58),
                        height: ResponsiveUI.value(context, 58),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 14)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: ResponsiveUI.value(context, 20),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                              ),
                            ),
                            SizedBox(height: ResponsiveUI.value(context, 8)),
                            Container(
                              width: ResponsiveUI.value(context, 150),
                              height: ResponsiveUI.value(context, 16),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: ResponsiveUI.value(context, 40),
                        height: ResponsiveUI.value(context, 40),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),
                  Container(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 1),
                    color: AppColors.lightGray,
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: ResponsiveUI.value(context, 40),
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.value(context, 10)),
                      Expanded(
                        child: Container(
                          height: ResponsiveUI.value(context, 40),
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 12)),
                  Row(
                    children: [
                      Container(
                        width: ResponsiveUI.value(context, 120),
                        height: ResponsiveUI.value(context, 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: ResponsiveUI.value(context, 150),
                        height: ResponsiveUI.value(context, 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

