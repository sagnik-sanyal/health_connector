import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show WeightRecord;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart'
    as theme;
import 'package:health_connector_toolbox/src/common/utils/date_format_utils.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/base_health_record_tile.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/health_record_detail_row.dart';

/// A specialized tile widget for displaying weight records.
///
/// Shows weight in kilograms and pounds, timestamp, recording method, and
/// record details in an expandable format using the base health record tile.
@immutable
final class WeightRecordTile extends StatelessWidget {
  const WeightRecordTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final WeightRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BaseHealthRecordTile(
      icon: AppIcons.monitorWeight,
      title:
          '${record.weight.inKilograms.toStringAsFixed(2)} kg '
          '(${record.weight.inPounds.toStringAsFixed(2)} lbs)',
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${AppTexts.time}: ${DateFormatUtils.formatDateTime(record.time)}',
          ),
          Text(
            '${AppTexts.recording}: ${record.metadata.recordingMethod.name}',
            style: const TextStyle(
              fontSize: 12,
              color: theme.AppColors.grey600,
            ),
          ),
        ],
      ),
      detailRows: [
        HealthRecordDetailRow(label: AppTexts.id, value: record.id.value),
        HealthRecordDetailRow(
          label: AppTexts.weightKg,
          value: record.weight.inKilograms.toStringAsFixed(2),
        ),
        HealthRecordDetailRow(
          label: AppTexts.weightLbs,
          value: record.weight.inPounds.toStringAsFixed(2),
        ),
        HealthRecordDetailRow(
          label: AppTexts.weightGrams,
          value: record.weight.inGrams.toStringAsFixed(2),
        ),
        HealthRecordDetailRow(
          label: AppTexts.time,
          value: DateFormatUtils.formatDateTime(record.time),
        ),
        HealthRecordDetailRow(
          label: AppTexts.zoneOffsetSeconds,
          value: record.zoneOffsetSeconds,
        ),
      ],
      metadata: record.metadata,
      onDelete: onDelete,
    );
  }
}
