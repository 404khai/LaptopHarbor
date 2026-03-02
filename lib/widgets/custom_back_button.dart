import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200], // Grey circle
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          color: AppColors.text, // Black icon
          size: 28,
        ),
      ),
    );
  }
}
