part of 'health_record.dart';

/// Represents a body height measurement at a specific point in time.
///
/// [HeightRecord] captures the user's body height as an instant measurement.
/// This is a point-in-time record with a single timestamp.
///
/// ## Platform Mapping
///
/// - **Android**: Maps to Health Connect's `HeightRecord`
/// - **iOS**: Maps to HealthKit's `HKQuantityType(.height)`
@Since('0.1.0')
@immutable
final class HeightRecord extends InstantHealthRecord {
  /// Creates a body height record.
  ///
  /// ## Parameters
  ///
  /// - [id]: The unique identifier for this record.
  /// - [time]: The timestamp when the height was measured.
  /// - [zoneOffsetSeconds]: Optional timezone offset for the measurement time.
  /// - [metadata]: Metadata about the origin and recording method.
  /// - [height]: The body height measurement.
  ///
  /// ## Throws
  ///
  /// - [ArgumentError] if [height] is negative (via Length class validation).
  const HeightRecord({
    required super.time,
    required super.metadata,
    required this.height,
    super.id = HealthRecordId.none,
    super.zoneOffsetSeconds,
  });

  /// The body height measurement.
  ///
  /// This uses the [Length] unit class which supports multiple units
  /// (meters, kilometers, miles, feet, yards).
  final Length height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeightRecord &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          time == other.time &&
          zoneOffsetSeconds == other.zoneOffsetSeconds &&
          height == other.height &&
          metadata == other.metadata;

  @override
  int get hashCode =>
      id.hashCode ^
      time.hashCode ^
      (zoneOffsetSeconds?.hashCode ?? 0) ^
      height.hashCode ^
      metadata.hashCode;

  @override
  String toString() =>
      'HeightRecord('
      'id: $id, '
      'height: $height, '
      'time: $time'
      ')';

  @override
  String get name => 'height_record';

  @override
  List<HealthPlatform> get supportedHealthPlatforms => HealthPlatform.values;
}

