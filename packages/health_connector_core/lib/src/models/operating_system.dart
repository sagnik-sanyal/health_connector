import 'package:health_connector_core/src/annotations/health_connector_annotations.dart'
    show Since;

/// Represents the operating system platforms supported by the health connector.
@Since('0.1.0')
enum OperatingSystem {
  /// Apple's iOS operating system.
  iOS,

  /// Google's Android operating system.
  android,
}
