import 'package:health_connector_core/health_connector_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'HealthCharacteristicType',
    () {
      group(
        'biologicalSex',
        () {
          const type = HealthCharacteristicType.biologicalSex;

          test(
            'has correct id',
            () => expect(type.id, equals('biological_sex')),
          );

          test(
            'supports only Apple Health',
            () => expect(
              type.supportedHealthPlatforms,
              equals([HealthPlatform.appleHealth]),
            ),
          );

          test(
            'readPermission returns HealthCharacteristicPermission',
            () {
              expect(
                type.readPermission,
                isA<HealthCharacteristicPermission>(),
              );
              expect(
                type.readPermission.characteristicType,
                equals(type),
              );
            },
          );

          test(
            'toString returns id',
            () => expect(type.toString(), equals('biological_sex')),
          );

          test(
            'equality works correctly',
            () {
              expect(
                HealthCharacteristicType.biologicalSex,
                equals(HealthCharacteristicType.biologicalSex),
              );
              expect(
                HealthCharacteristicType.biologicalSex ==
                    HealthCharacteristicType.dateOfBirth,
                isFalse,
              );
            },
          );

          test(
            'hashCode is consistent with equality',
            () => expect(
              HealthCharacteristicType.biologicalSex.hashCode,
              equals(HealthCharacteristicType.biologicalSex.hashCode),
            ),
          );
        },
      );

      group(
        'dateOfBirth',
        () {
          const type = HealthCharacteristicType.dateOfBirth;

          test(
            'has correct id',
            () => expect(type.id, equals('date_of_birth')),
          );

          test(
            'supports only Apple Health',
            () => expect(
              type.supportedHealthPlatforms,
              equals([HealthPlatform.appleHealth]),
            ),
          );

          test(
            'readPermission returns HealthCharacteristicPermission',
            () {
              expect(
                type.readPermission,
                isA<HealthCharacteristicPermission>(),
              );
              expect(
                type.readPermission.characteristicType,
                equals(type),
              );
            },
          );

          test(
            'toString returns id',
            () => expect(type.toString(), equals('date_of_birth')),
          );

          test(
            'equality works correctly',
            () {
              expect(
                HealthCharacteristicType.dateOfBirth,
                equals(HealthCharacteristicType.dateOfBirth),
              );
              expect(
                HealthCharacteristicType.dateOfBirth ==
                    HealthCharacteristicType.biologicalSex,
                isFalse,
              );
            },
          );

          test(
            'hashCode is consistent with equality',
            () => expect(
              HealthCharacteristicType.dateOfBirth.hashCode,
              equals(HealthCharacteristicType.dateOfBirth.hashCode),
            ),
          );
        },
      );

      group(
        'values',
        () {
          test(
            'contains all characteristic types',
            () {
              expect(
                HealthCharacteristicType.values,
                hasLength(2),
              );
              expect(
                HealthCharacteristicType.values,
                contains(HealthCharacteristicType.biologicalSex),
              );
              expect(
                HealthCharacteristicType.values,
                contains(HealthCharacteristicType.dateOfBirth),
              );
            },
          );
        },
      );
    },
  );
}
