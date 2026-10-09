import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final void Function(T?)? onSaved;
  final bool readyOnly;

  const CustomDropdownField({
    super.key,
    required this.icon,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.readyOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        value: value,
        items: items,
        onChanged: readyOnly ? null : onChanged,
        validator: validator,
        onSaved: onSaved,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
        ),
        decoration: InputDecoration(
          labelText: label,
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
            icon,
            size: 20,
            color: theme.iconTheme.color?.withOpacity(0.7) ?? primaryColor,
          ),
          filled: true,
          fillColor: readyOnly
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
