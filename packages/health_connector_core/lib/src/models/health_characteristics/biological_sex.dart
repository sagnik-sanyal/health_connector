import 'package:health_connector_core/src/annotations/annotations.dart';

/// Represents the biological sex of a user as stored in HealthKit.
///
/// This enum maps directly to Apple HealthKit's
/// [`HKBiologicalSex`](https://developer.apple.com/documentation/healthkit/hkbiologicalsex)
/// values.
///
/// ## Platform Mapping
///
/// - **Android Health Connect**: Not supported
/// - **iOS HealthKit**: [`HKBiologicalSex`](https://developer.apple.com/documentation/healthkit/hkbiologicalsex)
///
/// ## Values
///
/// - [notSet]: The user has not set their biological sex in the Health app
/// - [female]: Female biological sex
/// - [male]: Male biological sex
/// - [other]: Other biological sex
///
/// {@category Health Characteristics}
@sinceV3_9_0
enum BiologicalSex {
  /// The user has not set their biological sex in the Health app.
  ///
  /// Maps to `HKBiologicalSex.notSet`.
  notSet,

  /// Female biological sex.
  ///
  /// Maps to `HKBiologicalSex.female`.
  female,

  /// Male biological sex.
  ///
  /// Maps to `HKBiologicalSex.male`.
  male,

  /// Other biological sex.
  ///
  /// Maps to `HKBiologicalSex.other`.
  other,
}
