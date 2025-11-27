import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show
        DistanceRecord,
        FloorsClimbedRecord,
        HealthRecord,
        InstantHealthRecord,
        IntervalHealthRecord,
        SeriesHealthRecord,
        StepRecord,
        WeightRecord,
        ActiveCaloriesBurnedRecord,
        WheelchairPushesRecord;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart'
    as theme;
import 'package:health_connector_toolbox/src/common/utils/date_format_utils.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/health_record_detail_row.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/instant_health_record_tile.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/interval_health_record_tile.dart';

/// A widget that displays a health record in a list tile format.
///
/// Automatically selects the appropriate unified tile widget based on the
/// record type hierarchy (InstantHealthRecord, IntervalHealthRecord,
/// SeriesHealthRecord) and provides record-specific builders for customization.
@immutable
final class HealthRecordListTile extends StatelessWidget {
  const HealthRecordListTile({
    required this.record,
    required this.onDelete,
    super.key,
  });

  final HealthRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (record is InstantHealthRecord) {
      return _buildInstantRecord(context, record as InstantHealthRecord);
    } else if (record is SeriesHealthRecord) {
      return _buildSeriesRecord(context, record as SeriesHealthRecord);
    } else if (record is IntervalHealthRecord) {
      return _buildIntervalRecord(context, record as IntervalHealthRecord);
    } else {
      return ListTile(
        title: const Text(AppTexts.unknownRecordType),
        subtitle: Text('${AppTexts.id}: ${record.id.value}'),
      );
    }
  }

  Widget _buildInstantRecord(
    BuildContext context,
    InstantHealthRecord record,
  ) {
    return switch (record) {
      WeightRecord() => InstantHealthRecordTile<WeightRecord>(
        record: record,
        icon: AppIcons.monitorWeight,
        title:
            '${record.weight.inKilograms.toStringAsFixed(2)} kg '
            '(${record.weight.inPounds.toStringAsFixed(2)} lbs)',
        subtitleBuilder: (r, ctx) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${AppTexts.time}: ${DateFormatUtils.formatDateTime(r.time)}',
            ),
            Text(
              '${AppTexts.recording}: ${r.metadata.recordingMethod.name}',
              style: const TextStyle(
                fontSize: 12,
                color: theme.AppColors.grey600,
              ),
            ),
          ],
        ),
        detailRowsBuilder: (r, ctx) => [
          HealthRecordDetailRow(
            label: AppTexts.weightKg,
            value: r.weight.inKilograms.toStringAsFixed(2),
          ),
          HealthRecordDetailRow(
            label: AppTexts.weightLbs,
            value: r.weight.inPounds.toStringAsFixed(2),
          ),
          HealthRecordDetailRow(
            label: AppTexts.weightGrams,
            value: r.weight.inGrams.toStringAsFixed(2),
          ),
        ],
        onDelete: onDelete,
      ),
    };
  }

  Widget _buildIntervalRecord(
    BuildContext context,
    IntervalHealthRecord record,
  ) {
    return switch (record) {
      StepRecord() => IntervalHealthRecordTile<StepRecord>(
        record: record,
        icon: AppIcons.directionsWalk,
        title: '${record.count.value.toInt()} ${AppTexts.stepsLabel}',
        subtitleBuilder: (r, ctx) {
          final duration = r.duration;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${AppTexts.startLabel} '
                '${DateFormatUtils.formatDateTime(r.startTime)}',
              ),
              Text(
                '${AppTexts.endLabel} '
                '${DateFormatUtils.formatDateTime(r.endTime)}',
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
          );
        },
        detailRowsBuilder: (r, ctx) => [
          HealthRecordDetailRow(
            label: AppTexts.count,
            value: r.count.value,
          ),
        ],
        onDelete: onDelete,
      ),
      DistanceRecord() => IntervalHealthRecordTile<DistanceRecord>(
        record: record,
        icon: AppIcons.straighten,
        title:
            '${record.distance.inMeters.toStringAsFixed(2)} m '
            '(${record.distance.inKilometers.toStringAsFixed(2)} km)',
        subtitleBuilder: (r, ctx) {
          final duration = r.duration;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${AppTexts.startLabel} '
                '${DateFormatUtils.formatDateTime(r.startTime)}',
              ),
              Text(
                '${AppTexts.endLabel} '
                '${DateFormatUtils.formatDateTime(r.endTime)}',
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
          );
        },
        detailRowsBuilder: (r, ctx) => [
          HealthRecordDetailRow(
            label: AppTexts.distanceMeters,
            value: r.distance.inMeters.toStringAsFixed(2),
          ),
          HealthRecordDetailRow(
            label: AppTexts.distanceKm,
            value: r.distance.inKilometers.toStringAsFixed(2),
          ),
        ],
        onDelete: onDelete,
      ),
      ActiveCaloriesBurnedRecord() =>
        IntervalHealthRecordTile<ActiveCaloriesBurnedRecord>(
          record: record,
          icon: AppIcons.localFireDepartment,
          title:
              '${record.energy.inKilocalories.toStringAsFixed(2)} kcal '
              '(${record.energy.inCalories.toStringAsFixed(0)} cal)',
          subtitleBuilder: (r, ctx) {
            final duration = r.duration;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${AppTexts.startLabel} '
                  '${DateFormatUtils.formatDateTime(r.startTime)}',
                ),
                Text(
                  '${AppTexts.endLabel} '
                  '${DateFormatUtils.formatDateTime(r.endTime)}',
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
            );
          },
          detailRowsBuilder: (r, ctx) => [
            HealthRecordDetailRow(
              label: AppTexts.activeCaloriesBurnedKcal,
              value: r.energy.inKilocalories.toStringAsFixed(2),
            ),
            HealthRecordDetailRow(
              label: AppTexts.activeCaloriesBurnedCal,
              value: r.energy.inCalories.toStringAsFixed(0),
            ),
          ],
          onDelete: onDelete,
        ),
      FloorsClimbedRecord() => IntervalHealthRecordTile<FloorsClimbedRecord>(
        record: record,
        icon: AppIcons.stairs,
        title: '${record.floors.value.toInt()} ${AppTexts.floorsClimbedLabel}',
        subtitleBuilder: (r, ctx) {
          final duration = r.duration;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${AppTexts.startLabel} '
                '${DateFormatUtils.formatDateTime(r.startTime)}',
              ),
              Text(
                '${AppTexts.endLabel} '
                '${DateFormatUtils.formatDateTime(r.endTime)}',
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
          );
        },
        detailRowsBuilder: (r, ctx) => [
          HealthRecordDetailRow(
            label: AppTexts.count,
            value: r.floors.value.toString(),
          ),
        ],
        onDelete: onDelete,
      ),
      WheelchairPushesRecord() =>
        IntervalHealthRecordTile<WheelchairPushesRecord>(
          record: record,
          icon: AppIcons.accessible,
          title:
              '${record.pushes.value.toInt()} ${AppTexts.wheelchairPushesLabel}',
          subtitleBuilder: (r, ctx) {
            final duration = r.duration;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${AppTexts.startLabel} '
                  '${DateFormatUtils.formatDateTime(r.startTime)}',
                ),
                Text(
                  '${AppTexts.endLabel} '
                  '${DateFormatUtils.formatDateTime(r.endTime)}',
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
            );
          },
          detailRowsBuilder: (r, ctx) => [
            HealthRecordDetailRow(
              label: AppTexts.count,
              value: r.pushes.value.toString(),
            ),
          ],
          onDelete: onDelete,
        ),
    };
  }

  Widget _buildSeriesRecord(
    BuildContext context,
    SeriesHealthRecord record,
  ) {
    // Placeholder for future series record implementations
    return ListTile(
      title: const Text(AppTexts.unknownRecordType),
      subtitle: Text('${AppTexts.id}: ${record.id.value}'),
    );
  }
}
