import 'package:health_connector_core/health_connector_core_internal.dart'
    show
        BiologicalSex,
        BiologicalSexCharacteristic,
        DateOfBirthCharacteristic,
        HealthCharacteristic;
import 'package:health_connector_hk_ios/src/pigeon/health_connector_hk_ios_api.g.dart'
    show
        BiologicalSexCharacteristicDto,
        BiologicalSexDto,
        DateOfBirthCharacteristicDto,
        HealthCharacteristicDto;
import 'package:meta/meta.dart' show internal;

/// Converts [BiologicalSexDto] to [BiologicalSex].
@internal
extension BiologicalSexDtoToDomain on BiologicalSexDto {
  /// Converts this DTO to a [BiologicalSex] domain model.
  BiologicalSex toDomain() {
    return switch (this) {
      BiologicalSexDto.notSet => BiologicalSex.notSet,
      BiologicalSexDto.female => BiologicalSex.female,
      BiologicalSexDto.male => BiologicalSex.male,
      BiologicalSexDto.other => BiologicalSex.other,
    };
  }
}

/// Converts [HealthCharacteristicDto] to [HealthCharacteristic].
@internal
extension HealthCharacteristicDtoToDomain on HealthCharacteristicDto {
  /// Converts this DTO to the appropriate [HealthCharacteristic] subtype.
  HealthCharacteristic toDomain() {
    return switch (this) {
      final BiologicalSexCharacteristicDto dto =>
        BiologicalSexCharacteristic(
          biologicalSex: dto.biologicalSex.toDomain(),
        ),
      final DateOfBirthCharacteristicDto dto => DateOfBirthCharacteristic(
        dateOfBirth: dto.dateOfBirthMillisecondsSinceEpoch != null
            ? DateTime.fromMillisecondsSinceEpoch(
                dto.dateOfBirthMillisecondsSinceEpoch!,
                isUtc: true,
              )
            : null,
      ),
    };
  }
}
