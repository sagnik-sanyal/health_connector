import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart'
    as theme;

/// A reusable widget for displaying a single health record detail field row.
///
/// Shows a label on the left and value on the right with appropriate styling.
/// Null values are displayed in gray italic text as "null".
@immutable
final class HealthRecordDetailRow extends StatelessWidget {
  const HealthRecordDetailRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: theme.AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? AppTexts.notAvailable,
              style: TextStyle(
                fontSize: 12,
                color: value == null
                    ? theme.AppColors.grey400
                    : theme.AppColors.grey600,
                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
