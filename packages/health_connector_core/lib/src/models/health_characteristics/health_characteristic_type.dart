import 'package:health_connector_core/src/annotations/annotations.dart';
import 'package:health_connector_core/src/models/health_platform.dart';
import 'package:health_connector_core/src/models/health_platform_data.dart'
    show HealthPlatformData;
import 'package:health_connector_core/src/models/permissions/permission.dart';
import 'package:meta/meta.dart' show immutable, internal;

part 'biological_sex_characteristic_type.dart';
part 'date_of_birth_characteristic_type.dart';

/// Base class for all health characteristic types.
///
/// Health characteristic types represent categories of static user profile data
/// that can be read from the health platform. Unlike health data types, which
/// represent time-series health records with timestamps, IDs, and metadata,
/// characteristic types represent data that is set once and does not change
/// over time (e.g., biological sex, date of birth).
///
/// ## Differences from HealthDataType
///
/// | Feature | HealthDataType | HealthCharacteristicType |
/// |---------|---------------|------------------------|
/// | Has timestamps | Yes | No |
/// | Has record ID | Yes | No |
/// | Has metadata | Yes | No |
/// | Read method | `readRecord`/`readRecords` | `readCharacteristic` |
/// | Write support | Some types | Never (read-only) |
/// | HealthKit API | `HKSampleQuery` | `HKHealthStore` direct |
///
/// ## Platform Support
///
/// Health characteristics are currently only supported on **iOS HealthKit**.
///
/// ## Available Types
///
/// - [biologicalSex] - The user's biological sex
/// - [dateOfBirth] - The user's date of birth
///
/// ## Example
///
/// ```dart
/// // Request permission
/// final permissions = [
///   HealthCharacteristicType.biologicalSex.readPermission,
///   HealthCharacteristicType.dateOfBirth.readPermission,
/// ];
/// await connector.requestPermissions(permissions);
///
/// // Read characteristic
/// final characteristic = await connector.readCharacteristic(
///   HealthCharacteristicType.biologicalSex,
/// );
/// ```
///
/// {@category Health Characteristics}
@sinceV3_9_0
@immutable
sealed class HealthCharacteristicType implements HealthPlatformData {
  /// Creates a health characteristic type.
  const HealthCharacteristicType();

  /// A unique string identifier for this health characteristic type.
  ///
  /// Used for stable identification and serialization.
  @internalUse
  String get id;

  /// The read permission required to access this characteristic.
  HealthCharacteristicPermission get readPermission;

  @override
  String toString() => id;

  /// The user's biological sex.
  ///
  /// Corresponds to
  /// [`HKCharacteristicTypeIdentifier.biologicalSex`](https://developer.apple.com/documentation/healthkit/hkcharacteristictypeidentifier/biologicalsex)
  /// on iOS.
  @sinceV3_9_0
  @supportedOnAppleHealth
  static const BiologicalSexCharacteristicType biologicalSex =
      BiologicalSexCharacteristicType();

  /// The user's date of birth.
  ///
  /// Corresponds to
  /// [`HKCharacteristicTypeIdentifier.dateOfBirth`](https://developer.apple.com/documentation/healthkit/hkcharacteristictypeidentifier/dateofbirth)
  /// on iOS.
  @sinceV3_9_0
  @supportedOnAppleHealth
  static const DateOfBirthCharacteristicType dateOfBirth =
      DateOfBirthCharacteristicType();

  /// All available health characteristic types.
  static const List<HealthCharacteristicType> values = [
    biologicalSex,
    dateOfBirth,
  ];
}
