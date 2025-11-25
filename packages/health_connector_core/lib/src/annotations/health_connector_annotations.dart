import 'package:health_connector_core/health_connector_core.dart'
    show HealthPlatform;
import 'package:meta/meta.dart' show immutable;

/// Annotation class marking the version where an API was added.
///
/// A `Since` annotation can be applied to a library declaration,
/// any public declaration in a library, or in a class, or to
/// an optional parameter.
///
/// It signifies that the export, member or parameter was *added* in
/// that version.
///
/// When applied to:
/// - A library declaration, it also applies to all members declared or
///   exported by that library.
/// - A class, it also applies to all members and constructors of that class.
/// - A class method, or parameter of such, any method implementing that
///   interface method is also annotated.
///
/// **Note**: If multiple `Since` annotations apply to the same declaration or
/// parameter, the latest version takes precedence.
///
/// This plugin uses semantic versioning.
///
/// ## Example
///
/// ```dart
/// @Since('1.2.0')
/// Future<void> newMethod() { ... }
/// ```
@immutable
final class Since {
  /// Creates a `Since` annotation marking when an API was added.
  const Since(this.version);

  /// The version where this API was added.
  ///
  /// Must be a semantic version (e.g., `1.4.2`, `2.0.0-dev`)
  final String version;
}

/// Annotation used to mark APIs that are supported only on
/// specific health platforms.
///
/// Apply this annotation to methods, getters, classes, or other declarations
/// that  are only available on certain [HealthPlatform]s.
///
/// When the annotated API is called on an unsupported platform,
/// an error will be thrown at runtime.
///
/// ## Usage
///
/// ```
/// @SupportedHealthPlatforms([HealthPlatform.android, HealthPlatform.ios])
/// Future<List<HealthData>> readPermissions() async {
///   // Implementation works on Android and iOS
/// }
///
/// @SupportedHealthPlatforms([HealthPlatform.android])
/// Future<void> getFeatureStatus() async {
///   // Only available on Android
/// }
/// ```
///
/// ## Platform Validation
///
/// Before calling an annotated API, verify platform support to a
/// void runtime errors:
///
/// ```
/// if (currentPlatform == HealthPlatform.android) {
///   await writeSamsungHealthData();
/// }
/// ```
///
/// See [HealthPlatform], which defines the supported health platforms.
@Since('0.1.0')
@immutable
final class SupportedHealthPlatforms {
  /// Creates an annotation that restricts API usage to the specified platforms.
  ///
  /// The [platforms] list must contain at least one [HealthPlatform] value.
  const SupportedHealthPlatforms(this.platforms);

  /// The list of health platforms on which this API is supported.
  ///
  /// If the API is invoked on a platform not in this list, an error
  /// will be thrown.
  final List<HealthPlatform> platforms;
}


