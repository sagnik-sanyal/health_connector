import 'package:flutter_test/flutter_test.dart';
import 'package:health_connector_core/health_connector_core_internal.dart';
import 'package:health_connector_hk_ios/src/mappers/health_characteristic_mapper.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_hk_ios_api.g.dart';

void main() {
  group(
    'HealthCharacteristicMapper',
    () {
      group(
        'BiologicalSexDtoToDomain',
        () {
          test(
            'maps BiologicalSexDto.notSet to BiologicalSex.notSet',
            () => expect(
              BiologicalSexDto.notSet.toDomain(),
              BiologicalSex.notSet,
            ),
          );

          test(
            'maps BiologicalSexDto.female to BiologicalSex.female',
            () => expect(
              BiologicalSexDto.female.toDomain(),
              BiologicalSex.female,
            ),
          );

          test(
            'maps BiologicalSexDto.male to BiologicalSex.male',
            () => expect(
              BiologicalSexDto.male.toDomain(),
              BiologicalSex.male,
            ),
          );

          test(
            'maps BiologicalSexDto.other to BiologicalSex.other',
            () {
              expect(
                BiologicalSexDto.other.toDomain(),
                BiologicalSex.other,
              );
            },
          );
        },
      );

      group(
        'HealthCharacteristicDtoToDomain',
        () {
          test(
            'converts BiologicalSexCharacteristicDto to '
            'BiologicalSexCharacteristic',
            () {
              final dto = BiologicalSexCharacteristicDto(
                biologicalSex: BiologicalSexDto.female,
              );

              final result = dto.toDomain();

              expect(result, isA<BiologicalSexCharacteristic>());
              final characteristic = result as BiologicalSexCharacteristic;
              expect(
                characteristic.biologicalSex,
                BiologicalSex.female,
              );
            },
          );

          test(
            'converts BiologicalSexCharacteristicDto with notSet',
            () {
              final dto = BiologicalSexCharacteristicDto(
                biologicalSex: BiologicalSexDto.notSet,
              );

              final result = dto.toDomain();

              expect(result, isA<BiologicalSexCharacteristic>());
              final characteristic = result as BiologicalSexCharacteristic;
              expect(
                characteristic.biologicalSex,
                BiologicalSex.notSet,
              );
            },
          );

          test(
            'converts DateOfBirthCharacteristicDto with date to '
            'DateOfBirthCharacteristic',
            () {
              final dateOfBirth = DateTime.utc(1990, 5, 15);
              final dto = DateOfBirthCharacteristicDto(
                dateOfBirthMillisecondsSinceEpoch:
                    dateOfBirth.millisecondsSinceEpoch,
              );

              final result = dto.toDomain();

              expect(result, isA<DateOfBirthCharacteristic>());
              final characteristic = result as DateOfBirthCharacteristic;
              expect(characteristic.dateOfBirth, dateOfBirth);
            },
          );

          test(
            'converts DateOfBirthCharacteristicDto with null date '
            'to DateOfBirthCharacteristic with null dateOfBirth',
            () {
              final dto = DateOfBirthCharacteristicDto();

              final result = dto.toDomain();

              expect(result, isA<DateOfBirthCharacteristic>());
              final characteristic = result as DateOfBirthCharacteristic;
              expect(characteristic.dateOfBirth, isNull);
            },
          );
        },
      );
    },
  );
}
