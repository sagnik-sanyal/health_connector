import 'package:health_connector_core/src/annotations/annotations.dart';
import 'package:health_connector_core/src/models/permissions/permission.dart';

/// Extension methods for filtering [List<Permission>] by permission type.
@sinceV1_0_0
@internalUse
extension PermissionListExtension on List<Permission> {
  /// Returns a list containing only [HealthDataPermission] instances.
  ///
  /// Filters the list to include only permissions that are instances of
  /// [HealthDataPermission], excluding any [HealthPlatformFeaturePermission]
  /// instances.
  List<HealthDataPermission> get healthDataPermissions =>
      whereType<HealthDataPermission>().toList();

  /// Returns a list containing only
  /// [HealthPlatformFeaturePermission] instances.
  ///
  /// Filters the list to include only permissions that are instances of
  /// [HealthPlatformFeaturePermission], excluding any [HealthDataPermission]
  /// instances.
  List<HealthPlatformFeaturePermission> get featurePermissions =>
      whereType<HealthPlatformFeaturePermission>().toList();

  /// Returns a list containing only [ExerciseRoutePermission] instances.
  ///
  /// Filters the list to include only permissions that are instances of
  /// [ExerciseRoutePermission].
  @sinceV3_8_0
  List<ExerciseRoutePermission> get exerciseRoutePermissions =>
      whereType<ExerciseRoutePermission>().toList();

  /// Returns a list containing only
  /// [HealthCharacteristicPermission] instances.
  ///
  /// Filters the list to include only permissions that are instances of
  /// [HealthCharacteristicPermission], which represent read-only access to
  /// health characteristics such as biological sex and date of birth.
  @sinceV3_9_0
  List<HealthCharacteristicPermission> get characteristicPermissions =>
      whereType<HealthCharacteristicPermission>().toList();
}
