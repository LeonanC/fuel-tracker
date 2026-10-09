import 'package:flutter/material.dart';
import 'package:fuel_tracker/core/theme/app_colors.dart';

class AppNameWidget extends StatelessWidget {
  final Color? greenTileColor;
  final double textSize;
  final bool isBold;
  const AppNameWidget({super.key, this.greenTileColor, this.textSize = 30, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: textSize),
        children: [
          TextSpan(
            text: 'Fuel ',
            style: TextStyle(
              color: greenTileColor ?? AppColors.customSwatchColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          TextSpan(
            text: 'Tracker',
            style: TextStyle(
              color: theme.colorScheme.secondary,
            ),
          ),
        ]
      ),
    );
  }
}