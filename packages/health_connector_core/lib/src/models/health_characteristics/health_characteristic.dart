import 'package:health_connector_core/src/annotations/annotations.dart';
import 'package:health_connector_core/src/models/health_characteristics/biological_sex.dart';
import 'package:meta/meta.dart' show immutable;

part 'biological_sex_characteristic.dart';
part 'date_of_birth_characteristic.dart';

/// Base class for all health characteristics.
///
/// Health characteristics represent static user profile data that is set once
/// and does not change over time (unlike time-series health records). These
/// values have no timestamps, no record IDs, and no metadata.
///
/// Characteristics are read using `readCharacteristic()` and
/// require separate characteristic permissions.
///
/// ## Platform Support
///
/// Health characteristics are currently only supported on **iOS HealthKit**.
/// On Android, calling `readCharacteristic` will throw an
/// `UnsupportedOperationException`.
///
/// ## Subclasses
///
/// - [BiologicalSexCharacteristic] - The user's biological sex
/// - [DateOfBirthCharacteristic] - The user's date of birth
///
/// ## Example
///
/// ```dart
/// final characteristic = await connector.readCharacteristic(
///   HealthCharacteristicType.biologicalSex,
/// );
///
/// switch (characteristic) {
///   case BiologicalSexCharacteristic(:final biologicalSex):
///     print('Biological sex: $biologicalSex');
///   case DateOfBirthCharacteristic(:final dateOfBirth):
///     print('Date of birth: $dateOfBirth');
/// }
/// ```
///
/// {@category Health Characteristics}
@sinceV3_9_0
@immutable
sealed class HealthCharacteristic {
  /// Creates a health characteristic.
  const HealthCharacteristic();
}
