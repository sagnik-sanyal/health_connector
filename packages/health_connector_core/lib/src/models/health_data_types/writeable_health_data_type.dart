import 'package:health_connector_core/src/models/permissions/permission.dart'
    show HealthDataPermission;
import 'package:meta/meta.dart' show internal;

/// Interface that adds write permission capability to a health data type.
@internal
abstract interface class WriteableHealthDataType {
  /// The write permission for this health data type.
  HealthDataPermission get writePermission;
}
