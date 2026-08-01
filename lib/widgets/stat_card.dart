import 'package:flutter/material.dart';
import 'stitch_stat_card.dart';
import '../theme/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StitchStatCard(
      title: title,
      value: value,
      icon: icon,
      color: color ?? AppColors.primary,
      onTap: onTap,
    );
  }
}

