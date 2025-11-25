import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show StepRecord;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart'
    as theme;
import 'package:health_connector_toolbox/src/common/utils/date_format_utils.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/base_health_record_tile.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/health_record_detail_row.dart';

/// A specialized tile widget for displaying step records.
///
/// Shows step count, start/end times, duration, and record details in an
/// expandable format using the base health record tile.
@immutable
final class StepRecordTile extends StatelessWidget {
  const StepRecordTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final StepRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final duration = record.duration;

    return BaseHealthRecordTile(
      icon: AppIcons.directionsWalk,
      title: '${record.count.value.toInt()} ${AppTexts.stepsLabel}',
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${AppTexts.startLabel} '
            '${DateFormatUtils.formatDateTime(record.startTime)}',
          ),
          Text(
            '${AppTexts.endLabel} '
            '${DateFormatUtils.formatDateTime(record.endTime)}',
          ),
          Text(
            '${AppTexts.duration} ${duration.inHours}h '
            '${duration.inMinutes.remainder(60)}m',
            style: const TextStyle(
              fontSize: 12,
              color: theme.AppColors.grey600,
            ),
          ),
        ],
      ),
      detailRows: [
        HealthRecordDetailRow(label: AppTexts.id, value: record.id.value),
        HealthRecordDetailRow(label: AppTexts.count, value: record.count.value),
        HealthRecordDetailRow(
          label: AppTexts.startZoneOffsetSeconds,
          value: record.startZoneOffsetSeconds,
        ),
        HealthRecordDetailRow(
          label: AppTexts.endZoneOffsetSeconds,
          value: record.endZoneOffsetSeconds,
        ),
      ],
      metadata: record.metadata,
      onDelete: onDelete,
    );
  }
}
