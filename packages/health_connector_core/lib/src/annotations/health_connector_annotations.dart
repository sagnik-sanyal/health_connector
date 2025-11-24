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
