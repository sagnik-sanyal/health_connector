import 'package:pigeon/pigeon.dart';

/// Pigeon API definition for Health Connector Flutter plugin.
///
/// This file defines the complete API contract between Dart and Android
/// for health data operations. Pigeon generates platform-specific
/// code from these definitions.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeon/health_connector_platform_api.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/phamtunglam/health_connector_hc_android/pigeon/HealthConnectorPlatformApi.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.phamtunglam.health_connector_hc_android.pigeon',
      errorClassName: 'HealthConnectorError',
    ),
    copyrightHeader: 'pigeons/copyright_header.txt',
  ),
)
/// Error codes that native platforms can use when throwing error.
enum HealthConnectorErrorCodeDto {
  /// Health Connect installation or update is required.
  installationOrUpdateRequired,

  /// Health platform is unavailable on this device.
  healthPlatformUnavailable,

  /// Invalid platform configuration detected.
  invalidPlatformConfiguration,

  /// Invalid argument or input validation error.
  invalidArgument,

  /// Attempted to use platform APIs or features that are not supported
  /// on the current health platform.
  unsupportedHealthPlatformApi,

  /// Unknown or unspecified error.
  unknown,

  /// Security/permission error occurred.
  securityError,
}

/// Represents the status of the health platform on the device.
enum HealthPlatformStatusDto {
  /// The health platform is available and ready to use.
  available,

  /// The health platform is not installed or not supported.
  ///
  /// Note: Health Connect only.
  installationOrUpdateRequired,

  /// The health platform is not available on this device.
  notAvailable,
}

// region Measurement Unit
/// Blood glucose unit types supported by the plugin.
enum BloodGlucoseUnitDto { milligramsPerDeciliter, millimolesPerLiter }

/// Energy unit types supported by the plugin.
enum EnergyUnitDto { calories, joules, kilocalories, kilojoules }

/// Length unit types supported by the plugin.
enum LengthUnitDto { feet, inches, kilometers, meters, miles }

/// Mass unit types supported by the plugin.
enum MassUnitDto { grams, kilograms, ounces, pounds }

/// Numeric unit types supported by the plugin.
///
/// Numeric values don't have unit conversions, but this enum is provided
/// for consistency with other unit types.
enum NumericUnitDto { numeric }

/// Percentage unit types supported by the plugin.
enum PercentageUnitDto {
  /// Percentage as a decimal value (0.0 to 1.0).
  decimal,

  /// Percentage as a whole number (0 to 100).
  whole,
}

/// Represents the type of access requested for health data.
enum PermissionAccessTypeDto {
  /// Read access to health data.
  read,

  /// Write access to health data.
  write,
}

/// Represents the status of a permission.
enum PermissionStatusDto {
  /// Permission has been explicitly denied by the user.
  denied,

  /// Permission has been explicitly granted by the user.
  granted,

  /// The permission status cannot be determined.
  unknown,
}

/// Pressure unit types supported by the plugin.
enum PressureUnitDto { millimetersOfMercury }

/// Power unit types supported by the plugin.
enum PowerUnitDto { kilowatts, watts }

/// Temperature unit types supported by the plugin.
enum TemperatureUnitDto { celsius, fahrenheit, kelvin }

/// Velocity unit types supported by the plugin.
enum VelocityUnitDto { kilometersPerHour, metersPerSecond, milesPerHour }

/// Volume unit types supported by the plugin.
enum VolumeUnitDto { fluidOuncesUs, liters, milliliters }

/// Represents a blood glucose measurement for platform transfer.
class BloodGlucoseDto {
  BloodGlucoseDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final BloodGlucoseUnitDto unit;

  /// The numeric value of the blood glucose.
  final double value;
}

/// Represents an energy measurement for platform transfer.
class EnergyDto {
  EnergyDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final EnergyUnitDto unit;

  /// The numeric value of the energy.
  final double value;
}

/// Represents a length measurement for platform transfer.
class LengthDto {
  LengthDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final LengthUnitDto unit;

  /// The numeric value of the length.
  final double value;
}

/// Represents a mass measurement for platform transfer.
class MassDto {
  MassDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final MassUnitDto unit;

  /// The numeric value of the mass.
  final double value;
}

/// Represents a numeric measurement for platform transfer.
class NumericDto {
  NumericDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final NumericUnitDto unit;

  /// The numeric value.
  final double value;
}

/// Represents a percentage measurement for platform transfer.
class PercentageDto {
  PercentageDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final PercentageUnitDto unit;

  /// The numeric value of the percentage.
  final double value;
}

/// Represents a power measurement for platform transfer.
class PowerDto {
  PowerDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final PowerUnitDto unit;

  /// The numeric value of the power.
  final double value;
}

/// Represents a pressure measurement for platform transfer.
class PressureDto {
  PressureDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final PressureUnitDto unit;

  /// The numeric value of the pressure.
  final double value;
}

/// Represents a temperature measurement for platform transfer.
class TemperatureDto {
  TemperatureDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final TemperatureUnitDto unit;

  /// The numeric value of the temperature.
  final double value;
}

/// Represents a velocity measurement for platform transfer.
class VelocityDto {
  VelocityDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final VelocityUnitDto unit;

  /// The numeric value of the velocity.
  final double value;
}

/// Represents a volume measurement for platform transfer.
class VolumeDto {
  VolumeDto({required this.value, required this.unit});

  /// The unit in which the value is expressed.
  final VolumeUnitDto unit;

  /// The numeric value of the volume.
  final double value;
}

// endregion

// region Metadata

/// Device type for health data recording.
enum DeviceTypeDto {
  /// Chest strap heart rate monitor.
  chestStrap,

  /// Fitness band or activity tracker.
  fitnessBand,

  /// Head-mounted device (e.g., AR/VR headset).
  headMounted,

  /// Mobile phone or smartphone.
  phone,

  /// Smart ring wearable.
  ring,

  /// Weight scale or body composition scale.
  scale,

  /// Smart display device.
  smartDisplay,

  /// Unknown or unspecified device type.
  unknown,

  /// Smartwatch or wearable watch.
  watch,
}

/// Recording method for health data.
enum RecordingMethodDto {
  /// Data was recorded during an active user-initiated session.
  activelyRecorded,

  /// Data was automatically recorded by a device in the background.
  automaticallyRecorded,

  /// Data was manually entered by the user.
  manualEntry,

  /// The recording method is unknown or unspecified.
  unknown,
}

/// Represents data origin (source application) for health records.
class DataOriginDto {
  DataOriginDto(this.packageName);

  /// The package name of the source app.
  final String packageName;
}

/// Represents device information for health data recording.
class DeviceDto {
  DeviceDto({
    required this.type,
    this.manufacturer,
    this.model,
  });

  /// The device manufacturer.
  final String? manufacturer;

  /// The device model.
  final String? model;

  /// The type of device.
  final DeviceTypeDto type;
}

/// Represents metadata for a health record.
class MetadataDto {
  MetadataDto({
    required this.dataOrigin,
    required this.recordingMethod,
    this.lastModifiedTime,
    this.clientRecordId,
    this.clientRecordVersion,
    this.device,
  });

  /// A custom identifier assigned by your application.
  ///
  /// Use this for client-side record tracking, deduplication, or correlation.
  final String? clientRecordId;

  /// A version number assigned by your application.
  ///
  /// Use this to implement your own versioning or tracking logic.
  final int? clientRecordVersion;

  /// The application that wrote this health record.
  final DataOriginDto dataOrigin;

  /// The device that recorded the data (optional).
  final DeviceDto? device;

  /// The timestamp when this record was last modified on the platform.
  ///
  /// Unix timestamp in milliseconds since epoch (UTC).
  /// Automatically maintained by Health Connect.
  final int? lastModifiedTime;

  /// The method used to record this data.
  final RecordingMethodDto recordingMethod;
}

// endregion

// region Health Records

/// Represents a health data type.
enum HealthDataTypeDto {
  /// Active calories burned data.
  activeCaloriesBurned,

  /// Distance traveled data.
  distance,

  /// Floors climbed data.
  floorsClimbed,

  /// Step count data.
  steps,

  /// Body weight data.
  weight,

  /// Body height data.
  height,

  /// Body fat percentage data.
  bodyFatPercentage,

  /// Body temperature data.
  bodyTemperature,

  /// Lean body mass data.
  leanBodyMass,

  /// Wheelchair pushes data.
  wheelchairPushes,

  /// Hydration (water intake) data.
  hydration,

  /// Heart rate series record data.
  heartRateSeriesRecord,

  /// Sleep session data.
  sleepSession,
}

/// Represents an active calories burned record for platform transfer.
class ActiveCaloriesBurnedRecordDto {
  ActiveCaloriesBurnedRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.energy,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Energy (calories) burned during the interval.
  final EnergyDto energy;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;
}

/// Represents a distance record for platform transfer.
class DistanceRecordDto {
  DistanceRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.distance,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Distance traveled during the interval.
  final LengthDto distance;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;
}

/// Represents a floors climbed record for platform transfer.
class FloorsClimbedRecordDto {
  FloorsClimbedRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.floors,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Number of floors (flights of stairs) climbed during the interval.
  final NumericDto floors;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;
}

/// Represents a wheelchair pushes record for platform transfer.
class WheelchairPushesRecordDto {
  WheelchairPushesRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.pushes,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Number of wheelchair pushes performed during the interval.
  final NumericDto pushes;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;
}

/// Represents a step count record for platform transfer.
class StepRecordDto {
  StepRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.count,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Number of steps taken during the interval (must be >= 0).
  final NumericDto count;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;
}

/// Represents a weight record for platform transfer.
class WeightRecordDto {
  WeightRecordDto({
    required this.id,
    required this.time,
    required this.metadata,
    required this.weight,
    this.zoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Measurement time in milliseconds since epoch (UTC).
  final int time;

  /// Weight measurement.
  final MassDto weight;

  /// Timezone offset in seconds for measurement time (optional).
  final int? zoneOffsetSeconds;
}

/// DTO for lean body mass health data.
class LeanBodyMassRecordDto {
  LeanBodyMassRecordDto({
    required this.id,
    required this.time,
    required this.metadata,
    required this.mass,
    this.zoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Measurement time in milliseconds since epoch (UTC).
  final int time;

  /// Lean body mass measurement.
  final MassDto mass;

  /// Timezone offset in seconds for measurement time (optional).
  final int? zoneOffsetSeconds;
}

/// DTO for body height health data.
class HeightRecordDto {
  HeightRecordDto({
    required this.id,
    required this.time,
    required this.metadata,
    required this.height,
    this.zoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Measurement time in milliseconds since epoch (UTC).
  final int time;

  /// Height measurement.
  final LengthDto height;

  /// Timezone offset in seconds for measurement time (optional).
  final int? zoneOffsetSeconds;
}

/// DTO for body fat percentage health data.
class BodyFatPercentageRecordDto {
  BodyFatPercentageRecordDto({
    required this.id,
    required this.time,
    required this.metadata,
    required this.percentage,
    this.zoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Measurement time in milliseconds since epoch (UTC).
  final int time;

  /// Body fat percentage measurement.
  final PercentageDto percentage;

  /// Timezone offset in seconds for measurement time (optional).
  final int? zoneOffsetSeconds;
}

/// DTO for body temperature health data.
class BodyTemperatureRecordDto {
  BodyTemperatureRecordDto({
    required this.id,
    required this.time,
    required this.metadata,
    required this.temperature,
    this.zoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Measurement time in milliseconds since epoch (UTC).
  final int time;

  /// Body temperature measurement.
  final TemperatureDto temperature;

  /// Timezone offset in seconds for measurement time (optional).
  final int? zoneOffsetSeconds;
}

/// Represents a hydration (water intake) record for platform transfer.
class HydrationRecordDto {
  HydrationRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.volume,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// Volume of water consumed during the interval.
  final VolumeDto volume;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;
}

/// Represents a single heart rate measurement for platform transfer.
///
/// This is a platform-agnostic value class used within heart rate records.
/// It contains a timestamp and BPM value without ID or metadata.
class HeartRateMeasurementDto {
  HeartRateMeasurementDto({
    required this.time,
    required this.beatsPerMinute,
  });

  /// Timestamp in milliseconds since epoch (UTC).
  final int time;

  /// Heart rate value in beats per minute (BPM).
  final NumericDto beatsPerMinute;
}

/// Represents a heart rate series record for platform transfer.
class HeartRateSeriesRecordDto {
  HeartRateSeriesRecordDto({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.metadata,
    required this.samples,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
  });

  /// Platform-assigned unique identifier.
  final String? id;

  /// Start time in milliseconds since epoch (UTC).
  final int startTime;

  /// End time in milliseconds since epoch (UTC).
  final int endTime;

  /// Metadata about this record.
  final MetadataDto metadata;

  /// List of heart rate measurements within this time interval.
  final List<HeartRateMeasurementDto> samples;

  /// Timezone offset in seconds for start time (optional).
  final int? startZoneOffsetSeconds;

  /// Timezone offset in seconds for end time (optional).
  final int? endZoneOffsetSeconds;
}

/// Sleep stage type enum.
enum SleepStageTypeDto {
  unknown,
  awake,
  sleeping,
  outOfBed,
  light,
  deep,
  rem,
  inBed,
}

/// DTO for a sleep stage value.
class SleepStageDto {
  SleepStageDto({
    required this.startTime,
    required this.endTime,
    required this.stage,
  });

  /// Start time (milliseconds since epoch).
  final int startTime;

  /// End time (milliseconds since epoch).
  final int endTime;

  /// The sleep stage type.
  final SleepStageTypeDto stage;
}

/// DTO for sleep session.
class SleepSessionRecordDto {
  SleepSessionRecordDto({
    required this.id,
    required this.metadata,
    required this.startTime,
    required this.endTime,
    required this.stages,
    this.startZoneOffsetSeconds,
    this.endZoneOffsetSeconds,
    this.title,
    this.notes,
  });

  /// Platform-assigned unique identifier.
  final String? id;
  final MetadataDto metadata;
  final int startTime;
  final int endTime;
  final int? startZoneOffsetSeconds;
  final int? endZoneOffsetSeconds;
  final String? title;
  final String? notes;
  final List<SleepStageDto> stages;
}

// endregion

// region Requests/Responses

/// Represents a health platform feature.
enum HealthPlatformFeatureDto {
  /// Read health data in the background.
  readHealthDataInBackground,

  /// Read historical health data from the past.
  readHealthDataHistory,
}

/// Represents the availability status of a feature.
enum HealthPlatformFeatureStatusDto {
  /// The feature is available on this platform.
  available,

  /// The feature is not available on this platform.
  unavailable,
}

/// Represents the result of a feature permission request.
class HealthPlatformFeaturePermissionRequestResultDto {
  HealthPlatformFeaturePermissionRequestResultDto({
    required this.feature,
    required this.status,
  });

  /// The feature for which permission was requested.
  final HealthPlatformFeatureDto feature;

  /// The status of the permission after the request.
  final PermissionStatusDto status;
}

/// Represents a permission request for accessing specific health data.
class HealthDataPermissionDto {
  HealthDataPermissionDto({
    required this.healthDataType,
    required this.accessType,
  });

  /// The type of access being requested (read or write).
  final PermissionAccessTypeDto accessType;

  /// The type of health data for which permission is requested.
  final HealthDataTypeDto healthDataType;
}

/// Represents the result of a health data permission request.
class HealthDataPermissionRequestResultDto {
  HealthDataPermissionRequestResultDto({
    required this.permission,
    required this.status,
  });

  /// The health data permission that was requested.
  final HealthDataPermissionDto permission;

  /// The status of the permission after the request.
  final PermissionStatusDto status;
}

/// Represents a permissions request.
class PermissionsRequestDto {
  PermissionsRequestDto({
    required this.healthDataPermissions,
    required this.featurePermissions,
  });

  /// List of features for which to request permissions.
  final List<HealthPlatformFeatureDto> featurePermissions;

  /// List of health data permissions to request.
  final List<HealthDataPermissionDto> healthDataPermissions;
}

/// Represents the response from a permissions request.
class PermissionsRequestResponseDto {
  PermissionsRequestResponseDto({
    required this.healthDataPermissionResults,
    required this.featurePermissionResults,
  });

  /// Results for each feature permission that was requested.
  final List<HealthPlatformFeaturePermissionRequestResultDto>
  featurePermissionResults;

  /// Results for each health data permission that was requested.
  final List<HealthDataPermissionRequestResultDto> healthDataPermissionResults;
}

/// Aggregation metric types for health data queries.
enum AggregationMetricDto {
  /// Average (mean) value across all data points.
  avg,

  /// Count of data points (records) in the dataset.
  count,

  /// Maximum value in the dataset.
  max,

  /// Minimum value in the dataset.
  min,

  /// Sum of all values in the time range.
  sum,
}

/// Request to perform aggregation on health records.
class AggregateRequestDto {
  AggregateRequestDto({
    required this.dataType,
    required this.aggregationMetric,
    required this.startTime,
    required this.endTime,
  });

  /// The type of aggregation to perform.
  final AggregationMetricDto aggregationMetric;

  /// The type of health data to aggregate.
  final HealthDataTypeDto dataType;

  /// End of time range in milliseconds since epoch (UTC), exclusive.
  final int endTime;

  /// Start of time range in milliseconds since epoch (UTC), inclusive.
  final int startTime;
}

/// Response containing aggregated value.
class AggregateResponseDto {
  AggregateResponseDto({
    required this.dataType,
    required this.aggregationMetric,
    this.activeCaloriesBurnedValue,
    this.bodyTemperatureValue,
    this.doubleValue,
    this.hydrationValue,
    this.lengthValue,
    this.leanBodyMassValue,
    this.massValue,
    this.wheelchairPushesValue,
    this.heartRateBeatsPerMinuteValue,
    this.sleepSessionValue,
  });

  /// The type of aggregation that was performed.
  final AggregationMetricDto aggregationMetric;

  /// The type of health data that was aggregated.
  final HealthDataTypeDto dataType;

  /// Active calories burned aggregated value.
  final EnergyDto? activeCaloriesBurnedValue;

  /// Body temperature aggregated value.
  final TemperatureDto? bodyTemperatureValue;

  /// Numeric aggregated value.
  ///
  /// Used for primitive numeric types like steps and count operations.
  final double? doubleValue;

  /// Hydration aggregated value.
  final VolumeDto? hydrationValue;

  /// Length aggregated value.
  final LengthDto? lengthValue;

  /// Mass aggregated value.
  final MassDto? massValue;

  /// Lean body mass aggregated value.
  final MassDto? leanBodyMassValue;

  /// Wheelchair pushes aggregated value.
  final NumericDto? wheelchairPushesValue;

  /// Heart rate series record aggregated value.
  final NumericDto? heartRateBeatsPerMinuteValue;

  /// Sleep session aggregated value.
  final NumericDto? sleepSessionValue;
}

/// Request to delete specific records by their IDs.
class DeleteRecordsByIdsRequestDto {
  DeleteRecordsByIdsRequestDto({
    required this.dataType,
    required this.recordIds,
  });

  /// The type of health data to delete.
  final HealthDataTypeDto dataType;

  /// List of unique identifiers for records to delete.
  final List<String> recordIds;
}

/// Request to delete records by time range.
class DeleteRecordsByTimeRangeRequestDto {
  DeleteRecordsByTimeRangeRequestDto({
    required this.dataType,
    required this.startTime,
    required this.endTime,
  });

  /// The type of health data to delete.
  final HealthDataTypeDto dataType;

  /// End of time range in milliseconds since epoch (UTC), exclusive.
  final int endTime;

  /// Start of time range in milliseconds since epoch (UTC), inclusive.
  final int startTime;
}

/// Request to read a single health record by ID.
class ReadRecordRequestDto {
  ReadRecordRequestDto({required this.dataType, required this.recordId});

  /// The type of health data to read.
  final HealthDataTypeDto dataType;

  /// The unique identifier of the record to read.
  final String recordId;
}

/// Response containing a single health record.
class ReadRecordResponseDto {
  ReadRecordResponseDto({
    required this.dataType,
    this.activeCaloriesBurnedRecord,
    this.bodyFatPercentageRecord,
    this.bodyTemperatureRecord,
    this.distanceRecord,
    this.floorsClimbedRecord,
    this.heightRecord,
    this.hydrationRecord,
    this.leanBodyMassRecord,
    this.stepsRecord,
    this.weightRecord,
    this.wheelchairPushesRecord,
    this.heartRateSeriesRecord,
    this.sleepSessionRecord,
  });

  /// The type of health data that was read.
  final HealthDataTypeDto dataType;

  /// Active calories burned record.
  final ActiveCaloriesBurnedRecordDto? activeCaloriesBurnedRecord;

  /// Distance record.
  final DistanceRecordDto? distanceRecord;

  /// Floors climbed record.
  final FloorsClimbedRecordDto? floorsClimbedRecord;

  /// Height record.
  final HeightRecordDto? heightRecord;

  /// Hydration record.
  final HydrationRecordDto? hydrationRecord;

  /// Lean body mass record.
  final LeanBodyMassRecordDto? leanBodyMassRecord;

  /// Step count record.
  final StepRecordDto? stepsRecord;

  /// Weight record.
  final WeightRecordDto? weightRecord;

  /// Body fat percentage record.
  final BodyFatPercentageRecordDto? bodyFatPercentageRecord;

  /// Body temperature record.
  final BodyTemperatureRecordDto? bodyTemperatureRecord;

  /// Wheelchair pushes record.
  final WheelchairPushesRecordDto? wheelchairPushesRecord;

  /// Heart rate series record.
  final HeartRateSeriesRecordDto? heartRateSeriesRecord;

  /// Sleep session record.
  final SleepSessionRecordDto? sleepSessionRecord;
}

/// Request to read multiple health records within a time range.
class ReadRecordsRequestDto {
  ReadRecordsRequestDto({
    required this.dataType,
    required this.startTime,
    required this.endTime,
    required this.pageSize,
    this.pageToken,
    this.dataOriginPackageNames = const [],
  });

  /// List of package names to filter by.
  final List<String> dataOriginPackageNames;

  /// The type of health data to read.
  final HealthDataTypeDto dataType;

  /// End of time range in milliseconds since epoch (UTC), exclusive.
  final int endTime;

  /// Maximum number of records to return per page (1-10,000).
  final int pageSize;

  /// Opaque pagination token for fetching next page (optional).
  ///
  /// Provided by previous response's nextPageToken.
  final String? pageToken;

  /// Start of time range in milliseconds since epoch (UTC), inclusive.
  final int startTime;
}

/// Response containing paginated health records.
class ReadRecordsResponseDto {
  ReadRecordsResponseDto({
    required this.dataType,
    this.nextPageToken,
    this.activeCaloriesBurnedRecords,
    this.bodyFatPercentageRecords,
    this.bodyTemperatureRecords,
    this.distanceRecords,
    this.floorsClimbedRecords,
    this.heightRecords,
    this.hydrationRecords,
    this.leanBodyMassRecords,
    this.stepsRecords,
    this.weightRecords,
    this.wheelchairPushesRecords,
    this.heartRateSeriesRecords,
    this.sleepSessionRecords,
  });

  /// The type of health data that was read.
  final HealthDataTypeDto dataType;

  /// Token for fetching next page, null if no more pages exist.
  final String? nextPageToken;

  /// List of active calories burned records.
  final List<ActiveCaloriesBurnedRecordDto>? activeCaloriesBurnedRecords;

  /// List of distance records.
  final List<DistanceRecordDto>? distanceRecords;

  /// List of floors climbed records.
  final List<FloorsClimbedRecordDto>? floorsClimbedRecords;

  /// List of height records.
  final List<HeightRecordDto>? heightRecords;

  /// List of hydration records.
  final List<HydrationRecordDto>? hydrationRecords;

  /// List of lean body mass records.
  final List<LeanBodyMassRecordDto>? leanBodyMassRecords;

  /// List of step records.
  final List<StepRecordDto>? stepsRecords;

  /// List of weight records.
  final List<WeightRecordDto>? weightRecords;

  /// List of body fat percentage records.
  final List<BodyFatPercentageRecordDto>? bodyFatPercentageRecords;

  /// List of body temperature records.
  final List<BodyTemperatureRecordDto>? bodyTemperatureRecords;

  /// List of wheelchair pushes records.
  final List<WheelchairPushesRecordDto>? wheelchairPushesRecords;

  /// List of heart rate series records.
  final List<HeartRateSeriesRecordDto>? heartRateSeriesRecords;

  /// List of sleep session records.
  final List<SleepSessionRecordDto>? sleepSessionRecords;
}

/// Request to write a single health record.
///
/// Uses explicit typed fields for compile-time safety.
/// Only ONE field should be non-null per request.
class WriteRecordRequestDto {
  WriteRecordRequestDto({
    required this.dataType,
    this.activeCaloriesBurnedRecord,
    this.bodyFatPercentageRecord,
    this.bodyTemperatureRecord,
    this.distanceRecord,
    this.floorsClimbedRecord,
    this.heightRecord,
    this.hydrationRecord,
    this.leanBodyMassRecord,
    this.stepsRecord,
    this.weightRecord,
    this.wheelchairPushesRecord,
    this.heartRateSeriesRecord,
    this.sleepSessionRecord,
  });

  /// The type of health data being written.
  final HealthDataTypeDto dataType;

  /// Active calories burned record.
  final ActiveCaloriesBurnedRecordDto? activeCaloriesBurnedRecord;

  /// Distance record.
  final DistanceRecordDto? distanceRecord;

  /// Floors climbed record.
  final FloorsClimbedRecordDto? floorsClimbedRecord;

  /// Height record.
  final HeightRecordDto? heightRecord;

  /// Hydration record.
  final HydrationRecordDto? hydrationRecord;

  /// Lean body mass record.
  final LeanBodyMassRecordDto? leanBodyMassRecord;

  /// Step count record.
  final StepRecordDto? stepsRecord;

  /// Weight record.
  final WeightRecordDto? weightRecord;

  /// Body fat percentage record.
  final BodyFatPercentageRecordDto? bodyFatPercentageRecord;

  /// Body temperature record.
  final BodyTemperatureRecordDto? bodyTemperatureRecord;

  /// Wheelchair pushes record.
  final WheelchairPushesRecordDto? wheelchairPushesRecord;

  /// Heart rate series record.
  final HeartRateSeriesRecordDto? heartRateSeriesRecord;

  /// Sleep session record.
  final SleepSessionRecordDto? sleepSessionRecord;
}

/// Response after writing a single record.
class WriteRecordResponseDto {
  WriteRecordResponseDto({required this.recordId});

  /// Platform-assigned unique identifier for the written record.
  final String recordId;
}

/// Request to write multiple health records atomically.
class WriteRecordsRequestDto {
  WriteRecordsRequestDto({
    required this.dataTypes,
    this.activeCaloriesBurnedRecords,
    this.bodyFatPercentageRecords,
    this.bodyTemperatureRecords,
    this.distanceRecords,
    this.floorsClimbedRecords,
    this.heightRecords,
    this.hydrationRecords,
    this.leanBodyMassRecords,
    this.stepsRecords,
    this.weightRecords,
    this.wheelchairPushesRecords,
    this.heartRateSeriesRecords,
    this.sleepSessionRecords,
  });

  /// The types of health data being written.
  final List<HealthDataTypeDto> dataTypes;

  /// List of active calories burned records.
  final List<ActiveCaloriesBurnedRecordDto>? activeCaloriesBurnedRecords;

  /// List of distance records.
  final List<DistanceRecordDto>? distanceRecords;

  /// List of floors climbed records.
  final List<FloorsClimbedRecordDto>? floorsClimbedRecords;

  /// List of height records.
  final List<HeightRecordDto>? heightRecords;

  /// List of hydration records.
  final List<HydrationRecordDto>? hydrationRecords;

  /// List of lean body mass records.
  final List<LeanBodyMassRecordDto>? leanBodyMassRecords;

  /// List of step records.
  final List<StepRecordDto>? stepsRecords;

  /// List of weight records.
  final List<WeightRecordDto>? weightRecords;

  /// List of body fat percentage records.
  final List<BodyFatPercentageRecordDto>? bodyFatPercentageRecords;

  /// List of body temperature records.
  final List<BodyTemperatureRecordDto>? bodyTemperatureRecords;

  /// List of wheelchair pushes records.
  final List<WheelchairPushesRecordDto>? wheelchairPushesRecords;

  /// List of heart rate series records.
  final List<HeartRateSeriesRecordDto>? heartRateSeriesRecords;

  /// List of sleep session records.
  final List<SleepSessionRecordDto>? sleepSessionRecords;
}

/// Response after writing multiple records.
class WriteRecordsResponseDto {
  WriteRecordsResponseDto({required this.recordIds});

  /// Platform-assigned unique identifiers for written records.
  final List<String> recordIds;
}

/// Request to update a single health record.
class UpdateRecordRequestDto {
  UpdateRecordRequestDto({
    required this.dataType,
    this.activeCaloriesBurnedRecord,
    this.bodyFatPercentageRecord,
    this.bodyTemperatureRecord,
    this.distanceRecord,
    this.floorsClimbedRecord,
    this.heightRecord,
    this.hydrationRecord,
    this.leanBodyMassRecord,
    this.stepsRecord,
    this.weightRecord,
    this.wheelchairPushesRecord,
    this.heartRateSeriesRecord,
    this.sleepSessionRecord,
  });

  /// The type of health data being updated.
  final HealthDataTypeDto dataType;

  /// Active calories burned record.
  final ActiveCaloriesBurnedRecordDto? activeCaloriesBurnedRecord;

  /// Distance record.
  final DistanceRecordDto? distanceRecord;

  /// Floors climbed record.
  final FloorsClimbedRecordDto? floorsClimbedRecord;

  /// Height record.
  final HeightRecordDto? heightRecord;

  /// Hydration record.
  final HydrationRecordDto? hydrationRecord;

  /// Lean body mass record.
  final LeanBodyMassRecordDto? leanBodyMassRecord;

  /// Step count record.
  final StepRecordDto? stepsRecord;

  /// Weight record.
  final WeightRecordDto? weightRecord;

  /// Body fat percentage record.
  final BodyFatPercentageRecordDto? bodyFatPercentageRecord;

  /// Body temperature record.
  final BodyTemperatureRecordDto? bodyTemperatureRecord;

  /// Wheelchair pushes record.
  final WheelchairPushesRecordDto? wheelchairPushesRecord;

  /// Heart rate series record.
  final HeartRateSeriesRecordDto? heartRateSeriesRecord;

  /// Sleep session record.
  final SleepSessionRecordDto? sleepSessionRecord;
}

/// Response after updating a single record.
class UpdateRecordResponseDto {
  UpdateRecordResponseDto({required this.recordId});

  /// Platform-assigned unique identifier for the updated record.
  final String recordId;
}

// endregion

/// The main API for communicating with the health platform.
@HostApi()
abstract class HealthConnectorPlatformApi {
  @async
  AggregateResponseDto aggregate(AggregateRequestDto request);

  @async
  void deleteRecordsByIds(DeleteRecordsByIdsRequestDto request);

  @async
  void deleteRecordsByTimeRange(DeleteRecordsByTimeRangeRequestDto request);

  @async
  HealthPlatformFeatureStatusDto getFeatureStatus(
    HealthPlatformFeatureDto feature,
  );

  @async
  HealthPlatformStatusDto getHealthPlatformStatus();

  @async
  PermissionsRequestResponseDto requestPermissions(
    PermissionsRequestDto request,
  );

  @async
  PermissionsRequestResponseDto getGrantedPermissions();

  @async
  void revokeAllPermissions();

  @async
  ReadRecordResponseDto? readRecord(ReadRecordRequestDto request);

  @async
  ReadRecordsResponseDto readRecords(ReadRecordsRequestDto request);

  @async
  WriteRecordResponseDto writeRecord(WriteRecordRequestDto request);

  @async
  WriteRecordsResponseDto writeRecords(WriteRecordsRequestDto request);

  @async
  UpdateRecordResponseDto updateRecord(UpdateRecordRequestDto request);
}
