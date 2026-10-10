import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSecret;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final bool readyOnly;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final GlobalKey<FormFieldState>? formFieldKey;

  const CustomTextField({
    super.key,
    required this.icon,
    required this.label,
    this.isSecret = false,
    this.inputFormatters,
    this.initialValue,
    this.readyOnly = false,
    this.validator,
    this.onSaved,
    this.controller,
    this.textInputType,
    this.formFieldKey,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isObscure = false;

  @override
  void initState() {
    super.initState();
    isObscure = widget.isSecret;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        key: widget.formFieldKey,
        controller: widget.controller,
        validator: widget.validator,
        readOnly: widget.readyOnly,
        initialValue: widget.initialValue,
        inputFormatters: widget.inputFormatters,
        obscureText: isObscure,
        keyboardType: widget.textInputType,
        onSaved: widget.onSaved,
        style: GoogleFonts.lexend(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: GoogleFonts.lexend(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: GoogleFonts.lexend(
            color: primaryColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            vertical: 16.h,
            horizontal: 16.w,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              widget.icon,
              size: 20.sp,
              color: primaryColor,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40.w, minHeight: 20.h),
          filled: true,
          suffixIcon: widget.isSecret
              ? IconButton(
                  splashRadius: 20.r,
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                  icon: Icon(
                    isObscure ? RemixIcons.eye_line : RemixIcons.eye_off_line,
                    size: 18.sp,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                )
              : null,
          fillColor: widget.readyOnly
              ? colorScheme.surfaceContainerHighest.withOpacity(0.2)
              : colorScheme.surfaceContainerHighest.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.06),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.6), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: colorScheme.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          errorStyle: GoogleFonts.lexend(
            color: colorScheme.error,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          )
        ),
      ),
    );
  }
}
