import 'package:health_connector_core/health_connector_core.dart'
    show
        ActiveCaloriesBurnedHealthDataType,
        ActiveCaloriesBurnedRecord,
        BodyFatPercentageHealthDataType,
        BodyFatPercentageRecord,
        BodyTemperatureHealthDataType,
        BodyTemperatureRecord,
        DistanceHealthDataType,
        DistanceRecord,
        Energy,
        FloorsClimbedHealthDataType,
        FloorsClimbedRecord,
        HealthDataType,
        HealthRecord,
        HeightHealthDataType,
        HeightRecord,
        HydrationHealthDataType,
        HydrationRecord,
        LeanBodyMassHealthDataType,
        LeanBodyMassRecord,
        Length,
        Mass,
        MeasurementUnit,
        Metadata,
        Numeric,
        StepRecord,
        StepsHealthDataType,
        Temperature,
        Volume,
        WeightHealthDataType,
        WeightRecord,
        WheelchairPushesHealthDataType,
        WheelchairPushesRecord;

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
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  });

  /// Factory to get config for a given [HealthDataType].
  factory HealthRecordFormConfig.fromDataType(HealthDataType type) {
    return switch (type) {
      StepsHealthDataType() => const StepsFormConfig(),
      WeightHealthDataType() => const WeightFormConfig(),
      HeightHealthDataType() => const HeightFormConfig(),
      BodyFatPercentageHealthDataType() => const BodyFatPercentageFormConfig(),
      LeanBodyMassHealthDataType() => const LeanBodyMassFormConfig(),
      BodyTemperatureHealthDataType() => const BodyTemperatureFormConfig(),
      DistanceHealthDataType() => const DistanceFormConfig(),
      ActiveCaloriesBurnedHealthDataType() =>
        const ActiveCaloriesBurnedFormConfig(),
      FloorsClimbedHealthDataType() => const FloorsClimbedFormConfig(),
      WheelchairPushesHealthDataType() => const WheelchairPushesFormConfig(),
      HydrationHealthDataType() => const HydrationFormConfig(),
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
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
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
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    final massValue = value as Mass;

    return WeightRecord(
      time: startDateTime,
      weight: massValue,
      metadata: metadata,
    );
  }
}

/// Configuration for height records.
///
/// Height is an instant-based record that requires:
/// - Time (single timestamp)
/// - Height value (length in meters)
final class HeightFormConfig extends HealthRecordFormConfig {
  const HeightFormConfig();

  @override
  bool get needsDuration => false;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    final lengthValue = value as Length;

    return HeightRecord(
      time: startDateTime,
      height: lengthValue,
      metadata: metadata,
    );
  }
}

/// Configuration for body fat percentage records.
///
/// Body fat percentage is an instant-based record that requires:
/// - Time (single timestamp)
/// - Body fat percentage value (as decimal 0-1, e.g., 0.25 = 25%)
final class BodyFatPercentageFormConfig extends HealthRecordFormConfig {
  const BodyFatPercentageFormConfig();

  @override
  bool get needsDuration => false;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    final numericValue = value as Numeric;

    return BodyFatPercentageRecord(
      time: startDateTime,
      percentage: numericValue,
      metadata: metadata,
    );
  }
}

/// Configuration for lean body mass records.
///
/// Lean body mass is an instant-based record that requires:
/// - Time (single timestamp)
/// - Lean body mass value (mass in kilograms)
final class LeanBodyMassFormConfig extends HealthRecordFormConfig {
  const LeanBodyMassFormConfig();

  @override
  bool get needsDuration => false;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    final massValue = value as Mass;

    return LeanBodyMassRecord(
      time: startDateTime,
      mass: massValue,
      metadata: metadata,
    );
  }
}

/// Configuration for body temperature records.
///
/// Body temperature is an instant-based record that requires:
/// - Time (single timestamp)
/// - Body temperature value (temperature in Celsius)
final class BodyTemperatureFormConfig extends HealthRecordFormConfig {
  const BodyTemperatureFormConfig();

  @override
  bool get needsDuration => false;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    final temperatureValue = value as Temperature;

    return BodyTemperatureRecord(
      time: startDateTime,
      temperature: temperatureValue,
      metadata: metadata,
    );
  }
}

/// Configuration for distance records.
///
/// Distance is an interval-based record that requires:
/// - Start time
/// - End time (derived from start time + duration)
/// - Distance value (length in meters)
final class DistanceFormConfig extends HealthRecordFormConfig {
  const DistanceFormConfig();

  @override
  bool get needsDuration => true;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    if (endDateTime == null) {
      throw ArgumentError('endDateTime is required for distance records');
    }
    final lengthValue = value as Length;

    return DistanceRecord(
      startTime: startDateTime,
      endTime: endDateTime,
      distance: lengthValue,
      metadata: metadata,
    );
  }
}

/// Configuration for active calories burned records.
///
/// Active calories burned is an interval-based record that requires:
/// - Start time
/// - End time (derived from start time + duration)
/// - Energy value (energy in kilocalories)
final class ActiveCaloriesBurnedFormConfig extends HealthRecordFormConfig {
  const ActiveCaloriesBurnedFormConfig();

  @override
  bool get needsDuration => true;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    if (endDateTime == null) {
      throw ArgumentError(
        'endDateTime is required for active calories burned records',
      );
    }
    final energyValue = value as Energy;

    return ActiveCaloriesBurnedRecord(
      startTime: startDateTime,
      endTime: endDateTime,
      energy: energyValue,
      metadata: metadata,
    );
  }
}

/// Configuration for floors climbed records.
///
/// Floors climbed is an interval-based record that requires:
/// - Start time
/// - End time (derived from start time + duration)
/// - Floors count (numeric/integer)
final class FloorsClimbedFormConfig extends HealthRecordFormConfig {
  const FloorsClimbedFormConfig();

  @override
  bool get needsDuration => true;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    if (endDateTime == null) {
      throw ArgumentError(
        'endDateTime is required for floors climbed records',
      );
    }
    final numericValue = value as Numeric;

    return FloorsClimbedRecord(
      startTime: startDateTime,
      endTime: endDateTime,
      floors: numericValue,
      metadata: metadata,
    );
  }
}

/// Configuration for wheelchair pushes records.
///
/// Wheelchair pushes is an interval-based record that requires:
/// - Start time
/// - End time (derived from start time + duration)
/// - Pushes count (numeric/integer)
final class WheelchairPushesFormConfig extends HealthRecordFormConfig {
  const WheelchairPushesFormConfig();

  @override
  bool get needsDuration => true;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    if (endDateTime == null) {
      throw ArgumentError(
        'endDateTime is required for wheelchair pushes records',
      );
    }
    final numericValue = value as Numeric;

    return WheelchairPushesRecord(
      startTime: startDateTime,
      endTime: endDateTime,
      pushes: numericValue,
      metadata: metadata,
    );
  }
}

/// Configuration for hydration records.
///
/// Hydration is an interval-based record that requires:
/// - Start time
/// - End time (derived from start time + duration)
/// - Volume value (volume in liters)
final class HydrationFormConfig extends HealthRecordFormConfig {
  const HydrationFormConfig();

  @override
  bool get needsDuration => true;

  @override
  HealthRecord buildRecord({
    required DateTime startDateTime,
    required MeasurementUnit value,
    required Metadata metadata,
    DateTime? endDateTime,
  }) {
    if (endDateTime == null) {
      throw ArgumentError('endDateTime is required for hydration records');
    }
    final volumeValue = value as Volume;

    return HydrationRecord(
      startTime: startDateTime,
      endTime: endDateTime,
      volume: volumeValue,
      metadata: metadata,
    );
  }
}
