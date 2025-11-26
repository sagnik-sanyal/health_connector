import 'package:health_connector_core/health_connector_core.dart'
    show
        ActiveCaloriesBurnedHealthDataType,
        DistanceHealthDataType,
        HealthDataType,
        HealthRecord,
        MeasurementUnit,
        StepsHealthDataType,
        WeightHealthDataType;
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show HealthDataTypeDto;
import 'package:meta/meta.dart' show internal;

/// Converts [HealthDataTypeDto] to [HealthDataType].
@internal
extension HealthDataTypeDtoToDomain on HealthDataTypeDto {
  HealthDataType<HealthRecord, MeasurementUnit> toDomain() {
    switch (this) {
      case HealthDataTypeDto.activeCaloriesBurned:
        return HealthDataType.activeCaloriesBurned;
      case HealthDataTypeDto.distance:
        return HealthDataType.distance;
      case HealthDataTypeDto.steps:
        return HealthDataType.steps;
      case HealthDataTypeDto.weight:
        return HealthDataType.weight;
    }
  }
}

/// Converts [HealthDataType] to [HealthDataTypeDto].
@internal
extension HealthDataTypeToDto on HealthDataType<HealthRecord, MeasurementUnit> {
  HealthDataTypeDto toDto() {
    switch (this) {
      case ActiveCaloriesBurnedHealthDataType _:
        return HealthDataTypeDto.activeCaloriesBurned;
      case DistanceHealthDataType _:
        return HealthDataTypeDto.distance;
      case StepsHealthDataType _:
        return HealthDataTypeDto.steps;
      case WeightHealthDataType _:
        return HealthDataTypeDto.weight;
    }
  }
}
