import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart';

/// A reusable card widget for displaying health data types with an icon, title,
/// description, and a chevron indicator. Typically used in lists to navigate
/// to data type-specific pages.
@immutable
final class DataTypeCard extends StatelessWidget {
  const DataTypeCard({
    required this.icon,
    required this.onTap,
    required this.title,
    required this.description,
    super.key,
  });

  /// The title text displayed on the card.
  final String title;

  /// The description text displayed below the title.
  final String description;

  /// The icon displayed on the left side of the card.
  final IconData icon;

  /// Callback function called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(AppIcons.chevronRight, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}
