import 'package:health_connector_core/src/models/health_platform.dart'
    show HealthPlatform;
import 'package:meta/meta.dart' show immutable, mustBeOverridden;

/// Base class for all data that have platform-specific support.
///
/// This abstract class provides a contract for determining which
/// health platforms support a particular feature, data type, or permission.
@immutable
abstract interface class HealthPlatformData {
  /// The list of health platforms that support this data.
  List<HealthPlatform> get supportedHealthPlatforms;

  @override
  @mustBeOverridden
  bool operator ==(Object other);

  @override
  @mustBeOverridden
  int get hashCode;

  @override
  @mustBeOverridden
  String toString();
}
