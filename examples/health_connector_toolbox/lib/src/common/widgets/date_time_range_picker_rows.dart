import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/widgets/date_picker_field.dart';
import 'package:health_connector_toolbox/src/common/widgets/time_picker_field.dart';

/// A reusable widget that displays start and end date/time picker fields
/// in rows with built-in validation for date/time range selection.
///
/// This widget provides validation to ensure:
/// - Both start and end date/time are selected
/// - End date/time is after start date/time
@immutable
final class DateTimeRangePickerRows extends StatelessWidget {
  const DateTimeRangePickerRows({
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.onStartDateChanged,
    required this.onStartTimeChanged,
    required this.onEndDateChanged,
    required this.onEndTimeChanged,
    super.key,
    this.startDateLabel,
    this.startTimeLabel,
    this.endDateLabel,
    this.endTimeLabel,
    this.fieldSpacing = 8.0,
    this.rowSpacing = 16.0,
  });

  /// The selected start date (without time).
  final DateTime? startDate;

  /// The selected start time (without date).
  final TimeOfDay? startTime;

  /// The selected end date (without time).
  final DateTime? endDate;

  /// The selected end time (without date).
  final TimeOfDay? endTime;

  /// Callback when the start date is changed.
  final ValueChanged<DateTime> onStartDateChanged;

  /// Callback when the start time is changed.
  final ValueChanged<TimeOfDay> onStartTimeChanged;

  /// Callback when the end date is changed.
  final ValueChanged<DateTime> onEndDateChanged;

  /// Callback when the end time is changed.
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  /// Optional label for the start date field. Defaults to [AppTexts.startDate].
  final String? startDateLabel;

  /// Optional label for the start time field. Defaults to [AppTexts.startTime].
  final String? startTimeLabel;

  /// Optional label for the end date field. Defaults to [AppTexts.endDate].
  final String? endDateLabel;

  /// Optional label for the end time field. Defaults to [AppTexts.endTime].
  final String? endTimeLabel;

  /// Spacing between date and time fields within a row. Defaults to 8.0.
  final double fieldSpacing;

  /// Spacing between the start and end rows. Defaults to 16.0.
  final double rowSpacing;

  /// Computes the combined start date and time as a DateTime object.
  DateTime? get _startDateTime {
    if (startDate == null || startTime == null) {
      return null;
    }
    return DateTime(
      startDate!.year,
      startDate!.month,
      startDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
  }

  /// Computes the combined end date and time as a DateTime object.
  DateTime? get _endDateTime {
    if (endDate == null || endTime == null) {
      return null;
    }
    return DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
  }

  String? _validateStartDateTime() {
    if (startDate == null) {
      return '${AppTexts.pleaseSelect} ${startDateLabel ?? AppTexts.startDate}';
    }
    if (startTime == null) {
      return '${AppTexts.pleaseSelect} ${startTimeLabel ?? AppTexts.startTime}';
    }
    if (endDate == null || endTime == null) {
      return AppTexts.pleaseSelectBothStartAndEndDateTime;
    }
    final start = _startDateTime;
    final end = _endDateTime;
    if (start != null &&
        end != null &&
        (end.isBefore(start) || end.isAtSameMomentAs(start))) {
      return AppTexts.endTimeMustBeAfterStartTime;
    }
    return null;
  }

  String? _validateEndDateTime() {
    if (endDate == null) {
      return '${AppTexts.pleaseSelect} ${endDateLabel ?? AppTexts.endDate}';
    }
    if (endTime == null) {
      return '${AppTexts.pleaseSelect} ${endTimeLabel ?? AppTexts.endTime}';
    }
    if (startDate == null || startTime == null) {
      return AppTexts.pleaseSelectBothStartAndEndDateTime;
    }
    final start = _startDateTime;
    final end = _endDateTime;
    if (start != null &&
        end != null &&
        (end.isBefore(start) || end.isAtSameMomentAs(start))) {
      return AppTexts.endTimeMustBeAfterStartTime;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Start Date and Time in a single row
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: startDateLabel ?? AppTexts.startDate,
                initialValue: startDate,
                onChanged: onStartDateChanged,
                validator: (dateTime) => _validateStartDateTime(),
              ),
            ),
            SizedBox(width: fieldSpacing),
            Expanded(
              child: TimePickerField(
                label: startTimeLabel ?? AppTexts.startTime,
                initialValue: startTime,
                onChanged: onStartTimeChanged,
                validator: (timeOfDay) => _validateStartDateTime(),
              ),
            ),
          ],
        ),
        SizedBox(height: rowSpacing),
        // End Date and Time in a single row
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: endDateLabel ?? AppTexts.endDate,
                initialValue: endDate,
                onChanged: onEndDateChanged,
                validator: (dateTime) => _validateEndDateTime(),
              ),
            ),
            SizedBox(width: fieldSpacing),
            Expanded(
              child: TimePickerField(
                label: endTimeLabel ?? AppTexts.endTime,
                initialValue: endTime,
                onChanged: onEndTimeChanged,
                validator: (timeOfDay) => _validateEndDateTime(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
