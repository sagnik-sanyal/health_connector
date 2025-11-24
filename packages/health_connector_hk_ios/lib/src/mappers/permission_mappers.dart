import 'package:health_connector_core/health_connector_core.dart'
    show
        Permission,
        HealthDataPermission,
        HealthDataPermissionAccessType,
        PermissionStatus,
        PermissionRequestResult;
import 'package:health_connector_hk_ios/src/mappers/health_data_mappers.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show
        PermissionsRequestDto,
        HealthDataPermissionDto,
        PermissionAccessTypeDto,
        PermissionsRequestResponseDto,
        PermissionStatusDto;
import 'package:meta/meta.dart' show internal;

/// Converts [HealthDataPermissionAccessType] to [PermissionAccessTypeDto].
@internal
extension HealthDataPermissionAccessTypeToDto
    on HealthDataPermissionAccessType {
  PermissionAccessTypeDto toDto() {
    switch (this) {
      case HealthDataPermissionAccessType.read:
        return PermissionAccessTypeDto.read;
      case HealthDataPermissionAccessType.write:
        return PermissionAccessTypeDto.write;
    }
  }
}

/// Converts [List<Permission>] to [PermissionsRequestDto].
@internal
extension PermissionsListToDto on List<HealthDataPermission> {
  /// Converts a list of [Permission] objects to a [PermissionsRequestDto].
  PermissionsRequestDto toDto() {
    final healthDataPermissions = map(
      (permission) => HealthDataPermissionDto(
        healthDataType: permission.dataType.toDto(),
        accessType: permission.accessType.toDto(),
      ),
    ).toList();

    return PermissionsRequestDto(
      healthDataPermissions: healthDataPermissions,
    );
  }
}

/// Converts [PermissionsRequestResponseDto] to [List<PermissionRequestResult>].
@internal
extension PermissionsRequestResponseDtoToDomain
    on PermissionsRequestResponseDto {
  List<PermissionRequestResult> toDomain() {
    return healthDataPermissionResults
        .map(
          (result) => PermissionRequestResult(
            permission: HealthDataPermission(
              dataType: result.permission.healthDataType.toDomain(),
              accessType:
                  result.permission.accessType == PermissionAccessTypeDto.read
                  ? HealthDataPermissionAccessType.read
                  : HealthDataPermissionAccessType.write,
            ),
            status: result.status.toDomain(),
          ),
        )
        .toList();
  }
}

/// Converts [PermissionStatusDto] to [PermissionStatus].
@internal
extension PermissionStatusDtoToDomain on PermissionStatusDto {
  PermissionStatus toDomain() {
    switch (this) {
      case PermissionStatusDto.granted:
        return PermissionStatus.granted;
      case PermissionStatusDto.denied:
        return PermissionStatus.denied;
      case PermissionStatusDto.unknown:
        return PermissionStatus.unknown;
    }
  }
}
