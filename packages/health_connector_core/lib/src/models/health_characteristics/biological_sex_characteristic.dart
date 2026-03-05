part of 'health_characteristic.dart';

/// Represents the user's biological sex as stored in HealthKit.
///
/// This characteristic contains the [BiologicalSex] value retrieved from
/// Apple HealthKit via `HKHealthStore.biologicalSex()`.
///
/// ## Platform Mapping
///
/// - **Android Health Connect**: Not supported
/// - **iOS HealthKit**: [`HKHealthStore.biologicalSex()`](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614171-biologicalsex)
///
/// ## Example
///
/// ```dart
/// final characteristic = await connector.readCharacteristic(
///   HealthCharacteristicType.biologicalSex,
/// );
///
/// if (characteristic case BiologicalSexCharacteristic(:final biologicalSex)) {
///   switch (biologicalSex) {
///     case BiologicalSex.female:
///       print('Female');
///     case BiologicalSex.male:
///       print('Male');
///     case BiologicalSex.other:
///       print('Other');
///     case BiologicalSex.notSet:
///       print('Not set by user');
///   }
/// }
/// ```
///
/// {@category Health Characteristics}
@sinceV3_9_0
@supportedOnAppleHealth
@readOnly
@immutable
final class BiologicalSexCharacteristic extends HealthCharacteristic {
  /// Creates a [BiologicalSexCharacteristic] with the given [biologicalSex].
  const BiologicalSexCharacteristic({required this.biologicalSex});

  /// The user's biological sex.
  ///
  /// If the user has not set their biological sex in the Health app,
  /// this will be [BiologicalSex.notSet].
  final BiologicalSex biologicalSex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiologicalSexCharacteristic &&
          runtimeType == other.runtimeType &&
          biologicalSex == other.biologicalSex;

  @override
  int get hashCode => biologicalSex.hashCode;
}
