import 'package:health_connector_core/health_connector_core.dart'
    show
        HealthPlatformFeature,
        HealthPlatformFeatureReadHealthDataHistory,
        HealthPlatformFeatureReadHealthDataInBackground,
        HealthPlatformFeatureStatus;
import 'package:health_connector_hc_android/src/pigeon/health_connector_platform_api.g.dart'
    show HealthPlatformFeatureDto, HealthPlatformFeatureStatusDto;
import 'package:meta/meta.dart' show internal;

/// Converts [HealthPlatformFeature] to [HealthPlatformFeatureDto].
@internal
extension HealthPlatformFeatureToDto on HealthPlatformFeature {
  HealthPlatformFeatureDto toDto() {
    switch (this) {
      case HealthPlatformFeatureReadHealthDataHistory _:
        return HealthPlatformFeatureDto.readHealthDataHistory;
      case HealthPlatformFeatureReadHealthDataInBackground _:
        return HealthPlatformFeatureDto.readHealthDataInBackground;
    }
  }
}

/// Converts [HealthPlatformFeatureDto] to [HealthPlatformFeature].
@internal
extension HealthPlatformFeatureDtoToDomain on HealthPlatformFeatureDto {
  HealthPlatformFeature toDomain() {
    switch (this) {
      case HealthPlatformFeatureDto.readHealthDataHistory:
        return HealthPlatformFeature.readHealthDataHistory;
      case HealthPlatformFeatureDto.readHealthDataInBackground:
        return HealthPlatformFeature.readHealthDataInBackground;
    }
  }
}

/// Converts [HealthPlatformFeatureStatusDto] to [HealthPlatformFeatureStatus].
@internal
extension HealthPlatformFeatureStatusDtoToDomain
    on HealthPlatformFeatureStatusDto {
  HealthPlatformFeatureStatus toDomain() {
    switch (this) {
      case HealthPlatformFeatureStatusDto.available:
        return HealthPlatformFeatureStatus.available;
      case HealthPlatformFeatureStatusDto.unavailable:
        return HealthPlatformFeatureStatus.unavailable;
    }
  }
}

/// Converts [HealthPlatformFeatureStatus] to [HealthPlatformFeatureStatusDto].
@internal
extension HealthPlatformFeatureStatusToDto on HealthPlatformFeatureStatus {
  HealthPlatformFeatureStatusDto toDto() {
    switch (this) {
      case HealthPlatformFeatureStatus.available:
        return HealthPlatformFeatureStatusDto.available;
      case HealthPlatformFeatureStatus.unavailable:
        return HealthPlatformFeatureStatusDto.unavailable;
    }
  }
}
