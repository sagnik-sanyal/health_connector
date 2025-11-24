part of 'permission.dart';

/// Represents a permission request for accessing specific health data.
@Since('0.1.0')
@immutable
final class HealthDataPermission extends Permission {
  /// Creates a health data permission request.
  const HealthDataPermission({
    required this.dataType,
    required this.accessType,
  });

  /// The specific type of health data (e.g., steps, heart rate, etc.) for
  /// which permission is requested.
  final HealthDataType<HealthRecord, MeasurementUnit> dataType;

  /// The type of access being requested for the specified [dataType]
  final HealthDataPermissionAccessType accessType;

  @override
  List<HealthPlatform> get supportedHealthPlatforms =>
      dataType.supportedHealthPlatforms;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthDataPermission &&
          runtimeType == other.runtimeType &&
          dataType == other.dataType &&
          accessType == other.accessType;

  @override
  int get hashCode => dataType.hashCode ^ accessType.hashCode;

  @override
  String toString() =>
      'HealthDataPermission(dataType: $dataType, accessType: $accessType)';
}

/// Defines the type of access being requested for a permission.
@Since('0.1.0')
enum HealthDataPermissionAccessType {
  /// Permission to read data from a health platform.
  read,

  /// Permission to write new data to a health platform.
  write,
}
