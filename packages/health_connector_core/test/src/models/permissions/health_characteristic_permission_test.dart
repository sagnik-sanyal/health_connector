import 'package:health_connector_core/health_connector_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'HealthCharacteristicPermission',
    () {
      test(
        'can be instantiated with biologicalSex type',
        () {
          const permission = HealthCharacteristicPermission(
            HealthCharacteristicType.biologicalSex,
          );

          expect(
            permission.characteristicType,
            equals(HealthCharacteristicType.biologicalSex),
          );
        },
      );

      test(
        'can be instantiated with dateOfBirth type',
        () {
          const permission = HealthCharacteristicPermission(
            HealthCharacteristicType.dateOfBirth,
          );

          expect(
            permission.characteristicType,
            equals(HealthCharacteristicType.dateOfBirth),
          );
        },
      );

      test(
        'supports only Apple Health',
        () {
          const permission = HealthCharacteristicPermission(
            HealthCharacteristicType.biologicalSex,
          );

          expect(
            permission.supportedHealthPlatforms,
            equals([HealthPlatform.appleHealth]),
          );
        },
      );

      test(
        'equality works correctly for same characteristic type',
        () {
          const perm1 = HealthCharacteristicPermission(
            HealthCharacteristicType.biologicalSex,
          );
          const perm2 = HealthCharacteristicPermission(
            HealthCharacteristicType.biologicalSex,
          );

          expect(perm1 == perm2, isTrue);
          expect(perm1.hashCode == perm2.hashCode, isTrue);
        },
      );

      test(
        'equality works correctly for different characteristic types',
        () {
          const perm1 = HealthCharacteristicPermission(
            HealthCharacteristicType.biologicalSex,
          );
          const perm2 = HealthCharacteristicPermission(
            HealthCharacteristicType.dateOfBirth,
          );

          expect(perm1 == perm2, isFalse);
        },
      );

      test(
        'readPermission getter returns matching permission',
        () {
          expect(
            HealthCharacteristicType.biologicalSex.readPermission,
            equals(
              const HealthCharacteristicPermission(
                HealthCharacteristicType.biologicalSex,
              ),
            ),
          );
          expect(
            HealthCharacteristicType.dateOfBirth.readPermission,
            equals(
              const HealthCharacteristicPermission(
                HealthCharacteristicType.dateOfBirth,
              ),
            ),
          );
        },
      );
    },
  );
}
