import 'package:health_connector_core/health_connector_core.dart'
    show
        HealthDataType,
        HealthRecord,
        Mass,
        MeasurementUnit,
        Metadata,
        Numeric,
        StepRecord,
        StepsHealthDataType,
        WeightHealthDataType,
        WeightRecord;

/// Configuration for a health record write form.
///
/// Each health data type has its own configuration that defines:
/// - Whether the form needs duration (interval records vs instant records)
/// - How to build the HealthRecord from form values
/// - What validation rules apply
sealed class HealthRecordFormConfig {
  const HealthRecordFormConfig();

  /// Whether the form needs duration (interval records vs instant records).
  bool get needsDuration;

  /// Builds a [HealthRecord] from the provided form values.
  ///
  /// ## Parameters
  ///
  /// - [startDateTime]: The start date/time for the record
  /// - [endDateTime]: The end date/time (required if [needsDuration] is true)
  /// - [value]: The measurement value (e.g., step count, weight)
  /// - [metadata]: The metadata for the record
  ///
  /// ## Returns
  ///
  /// A [HealthRecord] instance ready to be written.
  HealthRecord buildRecord({
    required DateTime startDateTime,
    DateTime? endDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
  });

  /// Factory to get config for a given [HealthDataType].
  factory HealthRecordFormConfig.fromDataType(HealthDataType type) {
    return switch (type) {
      StepsHealthDataType() => const StepsFormConfig(),
      WeightHealthDataType() => const WeightFormConfig(),
    };
  }
}

/// Configuration for step count records.
///
/// Steps are interval-based records that require:
/// - Start time
/// - End time (derived from start time + duration)
/// - Step count (integer)
final class StepsFormConfig extends HealthRecordFormConfig {
  const StepsFormConfig();

  @override
  bool get needsDuration => true;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    DateTime? endDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
  }) {
    if (endDateTime == null) {
      throw ArgumentError('endDateTime is required for step records');
    }
    final numericValue = value as Numeric;

    return StepRecord(
      startTime: startDateTime,
      endTime: endDateTime,
      count: numericValue,
      metadata: metadata,
    );
  }
}

/// Configuration for weight records.
///
/// Weight is an instant-based record that requires:
/// - Time (single timestamp)
/// - Weight value (mass in kilograms)
final class WeightFormConfig extends HealthRecordFormConfig {
  const WeightFormConfig();

  @override
  bool get needsDuration => false;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    DateTime? endDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
  }) {
    final massValue = value as Mass;

    return WeightRecord(
      time: startDateTime,
      weight: massValue,
      metadata: metadata,
    );
  }
}
