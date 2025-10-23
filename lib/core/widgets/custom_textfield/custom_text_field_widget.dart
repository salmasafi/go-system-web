import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<bool>? onObscureChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final void Function()? suffixOnPressed;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Color? prefixIconColor;
  final bool hasBoxDecoration;
  final bool hasBorder;
  final Color? borderColor;
  final double borderRadius;
  final Color? backgroundColor;
  final double verticalPadding;
  final double horizontalPadding;
  final double elevation;
  final bool autofocus;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onObscureChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixOnPressed,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.hasBoxDecoration = false,
    this.hasBorder = false,
    this.borderColor,
    this.borderRadius = 12,
    this.backgroundColor,
    this.verticalPadding = 18,
    this.horizontalPadding = 16,
    this.elevation = 0,
    this.prefixIconColor,
    this.autofocus = false,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: widget.hasBoxDecoration
          ? BoxDecoration(
              color: widget.backgroundColor ?? AppColors.lightBlueBackground,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.elevation > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: widget.elevation,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            )
          : null,

      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        autofocus: widget.autofocus,
        obscureText: widget.isPassword ? _obscure : false,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.done, // Treat Enter as submit
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),

          border: widget.hasBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? AppColors.lightGray,
                  ),
                )
              : InputBorder.none,

          enabledBorder: widget.hasBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.borderColor ?? AppColors.lightGray,
                  ),
                )
              : InputBorder.none,

          focusedBorder: widget.hasBorder
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: (widget.borderColor ?? AppColors.lightGray)
                        .withOpacity(0.8),
                    width: 1.5,
                  ),
                )
              : InputBorder.none,

          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: widget.prefixIconColor ?? AppColors.linkBlue,
                )
              : null,

          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.linkBlue,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                    widget.onObscureChanged?.call(_obscure);
                  },
                )
              : IconButton(
                  icon: Icon(widget.suffixIcon, color: AppColors.linkBlue),
                  onPressed: widget.suffixOnPressed,
                ),

          contentPadding: EdgeInsets.symmetric(
            vertical: widget.verticalPadding,
            horizontal: widget.horizontalPadding,
          ),
        ),
      ),
    );
  }
}
