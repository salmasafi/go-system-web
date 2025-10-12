// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
//
// class CustomTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final String hintText;
//   final TextInputType keyboardType;
//   final bool obscureText;
//   final ValueChanged<bool>? onObscureChanged;
//   final IconData prefixIcon;
//   final bool isPassword;
//   final String? Function(String?)? validator;
//   final bool hasBoxDecoration;
//   final bool hasBorder;
//   final Color? prefixIconColor;
//
//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.labelText,
//     this.hintText = '',
//     this.keyboardType = TextInputType.text,
//     this.obscureText = false,
//     this.onObscureChanged,
//     required this.prefixIcon,
//     this.isPassword = false,
//     this.validator,
//     this.hasBoxDecoration = true,
//     this.hasBorder = false,
//     this.prefixIconColor,
//   });
//
//   @override
//   State<CustomTextField> createState() => _CustomTextFieldState();
// }
//
// class _CustomTextFieldState extends State<CustomTextField> {
//   bool _obscure = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _obscure = widget.obscureText;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       decoration: widget.hasBoxDecoration
//           ? BoxDecoration(
//         color: AppColors.lightBlueBackground,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       )
//           : null,
//       child: TextFormField(
//         controller: widget.controller,
//         keyboardType: widget.keyboardType,
//         obscureText: widget.isPassword ? _obscure : false,
//         validator: widget.validator,
//         decoration: InputDecoration(
//           labelText: widget.labelText,
//           hintText: widget.hintText,
//           labelStyle: const TextStyle(
//             fontWeight: FontWeight.w600,
//             color: AppColors.darkGray,
//           ),
//           border: widget.hasBorder
//               ? OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//           )
//               : InputBorder.none,
//           enabledBorder: widget.hasBorder
//               ? OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
//           )
//               : InputBorder.none,
//           focusedBorder: widget.hasBorder
//               ? OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
//           )
//               : InputBorder.none,
//           prefixIcon: Icon(
//             widget.prefixIcon,
//             color: widget.prefixIconColor ?? AppColors.linkBlue,
//           ),
//           suffixIcon: widget.isPassword
//               ? IconButton(
//             icon: Icon(
//               _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//               color: AppColors.linkBlue,
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscure = !_obscure;
//               });
//               widget.onObscureChanged?.call(_obscure);
//             },
//           )
//               : null,
//           contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//         ),
//       ),
//     );
//   }
// }