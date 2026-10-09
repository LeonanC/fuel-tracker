import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      padding: EdgeInsets.only(bottom: 16),
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
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: theme.textTheme.bodyMedium!.color!.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color: theme.iconTheme.color?.withOpacity(0.7) ?? primaryColor,
          ),
          filled: true,
          suffixIcon: widget.isSecret
              ? IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                  icon: Icon(
                    isObscure ? RemixIcons.eye_line : RemixIcons.eye_off_line,
                    size: 20,
                    color: theme.iconTheme.color?.withOpacity(0.6),
                  ),
                )
              : null,
          fillColor: widget.readyOnly
              ? colorScheme.surfaceVariant.withOpacity(0.15)
              : colorScheme.surfaceVariant.withOpacity(0.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
          errorStyle: TextStyle(
            color: colorScheme.error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          )
        ),
      ),
    );
  }
}
