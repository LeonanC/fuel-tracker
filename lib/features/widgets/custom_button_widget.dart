import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCircleButton extends StatelessWidget {
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onPressed;
  const CustomCircleButton({super.key, required this.icon, required this.theme, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 22.r, color: theme.iconTheme.color),
        onPressed: onPressed,
        splashRadius: 24.r,
      ),
    );
  }
}