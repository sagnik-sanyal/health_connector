part of 'health_characteristic_type.dart';

/// Biological sex characteristic type.
///
/// Represents the user's biological sex as set in the Health app. This
/// characteristic is read-only and uses the HealthKit
/// `HKCharacteristicTypeIdentifier.biologicalSex` API.
///
/// ## Platform Mapping
///
/// - **Android Health Connect**: Not supported
/// - **iOS HealthKit**: [`HKCharacteristicTypeIdentifier.biologicalSex`](https://developer.apple.com/documentation/healthkit/hkcharacteristictypeidentifier/biologicalsex)
///
/// ## Example
///
/// ```dart
/// // Request read permission
/// final permissions = [
///   HealthCharacteristicType.biologicalSex.readPermission,
/// ];
/// await connector.requestPermissions(permissions);
///
/// // Read biological sex
/// final characteristic = await connector.readCharacteristic(
///   HealthCharacteristicType.biologicalSex,
/// );
///
/// if (characteristic case BiologicalSexCharacteristic(:final biologicalSex)) {
///   print('Biological sex: $biologicalSex');
/// }
/// ```
///
/// {@category Health Characteristics}
@sinceV3_9_0
@supportedOnAppleHealth
@readOnly
@immutable
final class BiologicalSexCharacteristicType extends HealthCharacteristicType {
  /// Creates a biological sex characteristic type.
  ///
  /// This is a constant constructor used internally. To reference this
  /// characteristic type, use [HealthCharacteristicType.biologicalSex].
  @internal
  const BiologicalSexCharacteristicType();

  @override
  List<HealthPlatform> get supportedHealthPlatforms => [
    HealthPlatform.appleHealth,
  ];

  @override
  String get id => 'biological_sex';

  @override
  HealthCharacteristicPermission get readPermission =>
      HealthCharacteristicPermission(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiologicalSexCharacteristicType &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
