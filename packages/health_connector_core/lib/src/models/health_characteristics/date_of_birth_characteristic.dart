part of 'health_characteristic.dart';

/// Represents the user's date of birth as stored in HealthKit.
///
/// This characteristic contains the [DateTime] value retrieved from
/// Apple HealthKit via `HKHealthStore.dateOfBirthComponents()`.
///
/// ## Platform Mapping
///
/// - **Android Health Connect**: Not supported
/// - **iOS HealthKit**: [`HKHealthStore.dateOfBirthComponents()`](https://developer.apple.com/documentation/healthkit/hkhealthstore/1614168-dateofbirthcomponents)
///
/// ## Example
///
/// ```dart
/// final characteristic = await connector.readCharacteristic(
///   HealthCharacteristicType.dateOfBirth,
/// );
///
/// if (characteristic case DateOfBirthCharacteristic(:final dateOfBirth)) {
///   if (dateOfBirth != null) {
///     final year = dateOfBirth.year;
///     final month = dateOfBirth.month;
///     final day = dateOfBirth.day;
///     print('Date of birth: $year-$month-$day');
///   } else {
///     print('Date of birth not set by user');
///   }
/// }
/// ```
///
/// {@category Health Characteristics}
@sinceV3_9_0
@supportedOnAppleHealth
@readOnly
@immutable
final class DateOfBirthCharacteristic extends HealthCharacteristic {
  /// Creates a [DateOfBirthCharacteristic] with the given [dateOfBirth].
  const DateOfBirthCharacteristic({this.dateOfBirth});

  /// The user's date of birth.
  ///
  /// This value is `null` when the user has not set their date of birth
  /// in the Health app, or when HealthKit returns incomplete date
  /// components that cannot be converted to a valid [DateTime].
  final DateTime? dateOfBirth;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateOfBirthCharacteristic &&
          runtimeType == other.runtimeType &&
          dateOfBirth == other.dateOfBirth;

  @override
  int get hashCode => dateOfBirth.hashCode;
}
