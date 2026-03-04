import 'package:flutter_test/flutter_test.dart';
import 'package:health_connector_core/health_connector_core_internal.dart';
import 'package:health_connector_hk_ios/src/mappers/health_characteristic_type_mapper.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_hk_ios_api.g.dart';

void main() {
  group(
    'HealthCharacteristicTypeMapper',
    () {
      group(
        'HealthCharacteristicTypeToDto',
        () {
          test(
            'maps biologicalSex to HealthCharacteristicTypeDto.biologicalSex',
            () {
              const type = HealthCharacteristicType.biologicalSex;

              final dto = type.toDto();

              expect(
                dto,
                HealthCharacteristicTypeDto.biologicalSex,
              );
            },
          );

          test(
            'maps dateOfBirth to HealthCharacteristicTypeDto.dateOfBirth',
            () {
              const type = HealthCharacteristicType.dateOfBirth;

              final dto = type.toDto();

              expect(
                dto,
                HealthCharacteristicTypeDto.dateOfBirth,
              );
            },
          );
        },
      );

      group(
        'HealthCharacteristicTypeDtoToDomain',
        () {
          test(
            'maps HealthCharacteristicTypeDto.biologicalSex to '
            'HealthCharacteristicType.biologicalSex',
            () {
              const dto = HealthCharacteristicTypeDto.biologicalSex;

              final type = dto.toDomain();

              expect(
                type,
                HealthCharacteristicType.biologicalSex,
              );
            },
          );

          test(
            'maps HealthCharacteristicTypeDto.dateOfBirth to '
            'HealthCharacteristicType.dateOfBirth',
            () {
              const dto = HealthCharacteristicTypeDto.dateOfBirth;

              final type = dto.toDomain();

              expect(
                type,
                HealthCharacteristicType.dateOfBirth,
              );
            },
          );
        },
      );
    },
  );
}
