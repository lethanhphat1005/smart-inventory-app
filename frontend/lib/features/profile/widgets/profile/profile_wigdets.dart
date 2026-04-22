import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
    required this.icon,
    required this.text,
    required this.title,
  });

  final IconData icon;
  final String text;

  final dynamic title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p16, vertical: AppSizes.p4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.p14),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.gradientOrangeStart),
          title: Text(text),
          trailing: const Icon(Icons.arrow_forward_ios, size: AppSizes.p16),
          onTap: () {},
        ),
      ),
    );
  }
}
