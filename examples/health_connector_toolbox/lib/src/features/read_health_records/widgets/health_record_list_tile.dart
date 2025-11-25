import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show HealthRecord, StepRecord, WeightRecord;
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/step_record_tile.dart';
import 'package:health_connector_toolbox/src/features/read_health_records/widgets/weight_record_tile.dart';

/// A widget that displays a health record in a list tile format.
///
/// Automatically selects the appropriate specialized tile widget based on the
/// record type (StepRecord, WeightRecord, etc.).
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
    if (record is StepRecord) {
      return StepRecordTile(record: record as StepRecord, onDelete: onDelete);
    } else if (record is WeightRecord) {
      return WeightRecordTile(
        record: record as WeightRecord,
        onDelete: onDelete,
      );
    } else {
      return ListTile(
        title: const Text(AppTexts.unknownRecordType),
        subtitle: Text('${AppTexts.id}: ${record.id.value}'),
      );
    }
  }
}
