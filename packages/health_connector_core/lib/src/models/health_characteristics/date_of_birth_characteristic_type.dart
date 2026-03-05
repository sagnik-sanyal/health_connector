part of 'health_characteristic_type.dart';

/// Date of birth characteristic type.
///
/// Represents the user's date of birth as set in the Health app. This
/// characteristic is read-only and uses the HealthKit
/// `HKCharacteristicTypeIdentifier.dateOfBirth` API.
///
/// ## Platform Mapping
///
/// - **Android Health Connect**: Not supported
/// - **iOS HealthKit**: [`HKCharacteristicTypeIdentifier.dateOfBirth`](https://developer.apple.com/documentation/healthkit/hkcharacteristictypeidentifier/dateofbirth)
///
/// ## Example
///
/// ```dart
/// // Request read permission
/// final permissions = [
///   HealthCharacteristicType.dateOfBirth.readPermission,
/// ];
/// await connector.requestPermissions(permissions);
///
/// // Read date of birth
/// final characteristic = await connector.readCharacteristic(
///   HealthCharacteristicType.dateOfBirth,
/// );
///
/// if (characteristic case DateOfBirthCharacteristic(:final dateOfBirth)) {
///   if (dateOfBirth != null) {
///     print('Date of birth: $dateOfBirth');
///   } else {
///     print('Date of birth not set');
///   }
/// }
/// ```
///
/// {@category Health Characteristics}
@sinceV3_9_0
@supportedOnAppleHealth
@readOnly
@immutable
final class DateOfBirthCharacteristicType extends HealthCharacteristicType {
  /// Creates a date of birth characteristic type.
  ///
  /// This is a constant constructor used internally. To reference this
  /// characteristic type, use [HealthCharacteristicType.dateOfBirth].
  @internal
  const DateOfBirthCharacteristicType();

  @override
  List<HealthPlatform> get supportedHealthPlatforms => [
    HealthPlatform.appleHealth,
  ];

  @override
  String get id => 'date_of_birth';

  @override
  HealthCharacteristicPermission get readPermission =>
      HealthCharacteristicPermission(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateOfBirthCharacteristicType &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
