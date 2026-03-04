import 'package:health_connector_core/health_connector_core_internal.dart'
    show HealthCharacteristicType;
import 'package:health_connector_hk_ios/src/pigeon/health_connector_hk_ios_api.g.dart'
    show HealthCharacteristicTypeDto;
import 'package:meta/meta.dart' show internal;

/// Converts [HealthCharacteristicType] to [HealthCharacteristicTypeDto].
@internal
extension HealthCharacteristicTypeToDto on HealthCharacteristicType {
  /// Converts this characteristic type to the corresponding DTO.
  HealthCharacteristicTypeDto toDto() {
    return switch (this) {
      HealthCharacteristicType.biologicalSex =>
        HealthCharacteristicTypeDto.biologicalSex,
      HealthCharacteristicType.dateOfBirth =>
        HealthCharacteristicTypeDto.dateOfBirth,
      _ => throw ArgumentError('Unknown HealthCharacteristicType: $this'),
    };
  }
}

/// Converts [HealthCharacteristicTypeDto] to [HealthCharacteristicType].
@internal
extension HealthCharacteristicTypeDtoToDomain on HealthCharacteristicTypeDto {
  /// Converts this DTO to the corresponding [HealthCharacteristicType].
  HealthCharacteristicType toDomain() {
    return switch (this) {
      HealthCharacteristicTypeDto.biologicalSex =>
        HealthCharacteristicType.biologicalSex,
      HealthCharacteristicTypeDto.dateOfBirth =>
        HealthCharacteristicType.dateOfBirth,
    };
  }
}
