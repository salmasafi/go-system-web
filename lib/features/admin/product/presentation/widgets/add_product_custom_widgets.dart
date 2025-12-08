// lib/features/admin/product/presentation/widgets/add_product_widgets.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 1. Section Card Widget
// ═══════════════════════════════════════════════════════════════════════════
class ProductSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? iconColor;

  const ProductSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 20)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (iconColor ?? AppColors.primaryBlue).withOpacity(0.15),
                      (iconColor ?? AppColors.primaryBlue).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 12),
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.primaryBlue,
                  size: ResponsiveUI.iconSize(context, 24),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 20)),
          ...children,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. Animated Checkbox Tile Widget
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedCheckboxTile extends StatelessWidget {
  final bool value;
  final String title;
  final ValueChanged<bool?> onChanged;
  final Color activeColor;

  const AnimatedCheckboxTile({
    super.key,
    required this.value,
    required this.title,
    required this.onChanged,
    this.activeColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      decoration: BoxDecoration(
        gradient: value
            ? LinearGradient(
                colors: [
                  activeColor.withOpacity(0.08),
                  activeColor.withOpacity(0.03),
                ],
              )
            : null,
        color: value ? null : AppColors.lightBlueBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 14),
        ),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.4) : AppColors.lightGray,
          width: value ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value ? activeColor : AppColors.shadowGray,
                      width: 2,
                    ),
                  ),
                  child: value
                      ? Icon(Icons.check, size: 16, color: AppColors.white)
                      : null,
                ),
                // SizedBox(width: ResponsiveUI.spacing(context, 12)),
                // Icon(
                //   icon,
                //   size: ResponsiveUI.iconSize(context, 20),
                //   color: value ? activeColor : AppColors.shadowGray,
                // ),
                SizedBox(width: ResponsiveUI.spacing(context, 10)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                      color: value ? activeColor : AppColors.darkGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. Date Picker Card Widget
// ═══════════════════════════════════════════════════════════════════════════
class DatePickerCard extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String label;

  const DatePickerCard({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.label = 'Expiry Date',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 14),
          ),
          child: Container(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.08),
                  AppColors.linkBlue.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 14),
              ),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 10)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 10),
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryBlue,
                    size: ResponsiveUI.iconSize(context, 20),
                  ),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.shadowGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Tap to select date',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 15),
                          fontWeight: FontWeight.w600,
                          color: selectedDate != null
                              ? AppColors.primaryBlue
                              : AppColors.shadowGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. Main Image Picker Widget
// ═══════════════════════════════════════════════════════════════════════════
class MainImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  const MainImagePicker({
    super.key,
    required this.image,
    required this.onPick,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.image, size: 20, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'Main Image *',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            if (image != null && onRemove != null)
              TextButton.icon(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.red,
                  size: 18,
                ),
                label: Text(
                  'Remove',
                  style: TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ),
          ],
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: image == null
                  ? LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.05),
                        AppColors.linkBlue.withOpacity(0.02),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 16),
              ),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: image != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 14),
                        ),
                        child: Image.file(
                          image!,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tap to upload main image',
                        style: TextStyle(
                          color: AppColors.shadowGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Recommended: 1000x1000px',
                        style: TextStyle(
                          color: AppColors.shadowGray.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. Gallery Images Picker Widget
// ═══════════════════════════════════════════════════════════════════════════
class GalleryImagesPicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const GalleryImagesPicker({
    super.key,
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.collections, size: 20, color: AppColors.linkBlue),
                SizedBox(width: 8),
                Text(
                  'Gallery Images',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle, color: AppColors.linkBlue, size: 20),
              label: Text(
                'Add Images',
                style: TextStyle(color: AppColors.linkBlue, fontSize: 13),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (images.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.linkBlue.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.collections_outlined,
                  size: 40,
                  color: AppColors.linkBlue.withOpacity(0.5),
                ),
                SizedBox(height: 8),
                Text(
                  'No gallery images added',
                  style: TextStyle(color: AppColors.shadowGray, fontSize: 13),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(images.length, (index) {
              return ImageThumbnail(
                image: images[index],
                onRemove: () => onRemove(index),
              );
            }),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. Image Thumbnail Widget
// ═══════════════════════════════════════════════════════════════════════════
class ImageThumbnail extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;
  final double? size;

  const ImageThumbnail({
    super.key,
    required this.image,
    required this.onRemove,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailSize = size ?? 110.0;

    return Stack(
      children: [
        Container(
          width: thumbnailSize,
          height: thumbnailSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowGray.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(image, fit: BoxFit.fill),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.red.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. Variation Option Chip Widget
// ═══════════════════════════════════════════════════════════════════════════
class SingleVariationOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SingleVariationOptionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xFF2563EB)],
                )
              : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: // Row(
            //   mainAxisSize: MainAxisSize.min,
            //  children: [
            // if (isSelected)
            //   const Padding(
            //     padding: EdgeInsets.only(right: 6),
            //     child: Icon(Icons.check, size: 16, color: Colors.white),
            //   ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.darkGray,
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
        // ],
        // ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. Empty State Widget
// ═══════════════════════════════════════════════════════════════════════════
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final stateColor = color ?? AppColors.warningOrange;

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: stateColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 14),
        ),
        border: Border.all(color: stateColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: stateColor, size: 24),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                color: stateColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
