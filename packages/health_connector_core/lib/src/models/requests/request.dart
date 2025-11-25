import 'package:health_connector_core/src/annotations/health_connector_annotations.dart'
    show Since;
import 'package:meta/meta.dart' show immutable, internal, mustBeOverridden;

/// Base abstract class for all request types.
///
/// This class provides a common interface for all request objects in the
/// health connector API. All request classes should extend this base class.
///
/// ## Example
///
/// ```dart
/// final class MyRequest extends Request {
///   // Implementation
/// }
/// ```
@Since('0.1.0')
@internal
@immutable
abstract class Request {
  /// Creates a base request.
  const Request();

  @override
  @mustBeOverridden
  String toString();
}
