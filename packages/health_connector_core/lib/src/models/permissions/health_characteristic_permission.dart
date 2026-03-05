part of 'permission.dart';

/// Represents a permission request for accessing health characteristics.
///
/// Health characteristics are static user profile data such as biological sex
/// and date of birth. These are inherently read-only — characteristics cannot
/// be written or modified by third-party apps.
///
/// ## Platform Mapping
///
/// - **Android Health Connect**: Not supported (characteristics are iOS-only)
/// - **iOS HealthKit**: `HKCharacteristicType` authorization via
///   `requestAuthorization(toRead:)`
///
/// ## Usage
///
/// ```dart
/// final permissions = await connector.requestPermissions([
///   HealthCharacteristicType.biologicalSex.readPermission,
///   HealthCharacteristicType.dateOfBirth.readPermission,
/// ]);
/// ```
///
/// ## Privacy
///
/// On iOS, HealthKit does not expose whether read permissions for
/// characteristics have been granted or denied. The permission status will
/// always be [PermissionStatus.unknown], consistent with all HealthKit read
/// permissions.
///
/// {@category Permissions}
@sinceV3_9_0
@immutable
final class HealthCharacteristicPermission extends Permission {
  /// Creates a health characteristic permission for the given
  /// [characteristicType].
  const HealthCharacteristicPermission(this.characteristicType);

  /// The characteristic type this permission grants read access to.
  final HealthCharacteristicType characteristicType;

  @override
  List<HealthPlatform> get supportedHealthPlatforms => [
    HealthPlatform.appleHealth,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthCharacteristicPermission &&
          runtimeType == other.runtimeType &&
          characteristicType == other.characteristicType;

  @override
  int get hashCode => characteristicType.hashCode;
}
