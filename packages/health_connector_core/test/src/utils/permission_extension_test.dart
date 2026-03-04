import 'package:health_connector_core/health_connector_core_internal.dart';
import 'package:test/test.dart';

void main() {
  group(
    'PermissionListExtension',
    () {
      const permissions = <Permission>[
        HealthDataPermission(
          dataType: HealthDataType.steps,
          accessType: HealthDataPermissionAccessType.read,
        ),
        HealthPlatformFeaturePermission(
          HealthPlatformFeature.readHealthDataHistory,
        ),
        HealthDataPermission(
          dataType: HealthDataType.heartRateSeries,
          accessType: HealthDataPermissionAccessType.write,
        ),
        HealthPlatformFeaturePermission(
          HealthPlatformFeature
              .readHealthDataHistory, // Duplicate type for test
        ),
        HealthCharacteristicPermission(
          HealthCharacteristicType.biologicalSex,
        ),
        HealthCharacteristicPermission(
          HealthCharacteristicType.dateOfBirth,
        ),
      ];

      group(
        'healthDataPermissions',
        () {
          test(
            'returns only HealthDataPermission instances',
            () {
              final healthDataPermissions = permissions.healthDataPermissions;
              expect(healthDataPermissions.length, 2);
              expect(
                healthDataPermissions,
                everyElement(isA<HealthDataPermission>()),
              );
              expect(healthDataPermissions[0].dataType, HealthDataType.steps);
              expect(
                healthDataPermissions[1].dataType,
                HealthDataType.heartRateSeries,
              );
            },
          );

          test(
            'returns empty list if no HealthDataPermission instances',
            () {
              const onlyFeatures = <Permission>[
                HealthPlatformFeaturePermission(
                  HealthPlatformFeature.readHealthDataHistory,
                ),
              ];
              expect(onlyFeatures.healthDataPermissions, isEmpty);
            },
          );
        },
      );

      group(
        'featurePermissions',
        () {
          test(
            'returns only HealthPlatformFeaturePermission instances',
            () {
              final featurePermissions = permissions.featurePermissions;
              expect(featurePermissions.length, 2);
              expect(
                featurePermissions,
                everyElement(isA<HealthPlatformFeaturePermission>()),
              );
              expect(
                featurePermissions[0].feature,
                HealthPlatformFeature.readHealthDataHistory,
              );
            },
          );

          test(
            'returns empty list if no HealthPlatformFeaturePermission',
            () {
              const onlyData = <Permission>[
                HealthDataPermission(
                  dataType: HealthDataType.steps,
                  accessType: HealthDataPermissionAccessType.read,
                ),
              ];
              expect(onlyData.featurePermissions, isEmpty);
            },
          );
        },
      );

      group(
        'characteristicPermissions',
        () {
          test(
            'returns only HealthCharacteristicPermission instances',
            () {
              final characteristicPermissions =
                  permissions.characteristicPermissions;
              expect(characteristicPermissions.length, 2);
              expect(
                characteristicPermissions,
                everyElement(isA<HealthCharacteristicPermission>()),
              );
              expect(
                characteristicPermissions[0].characteristicType,
                HealthCharacteristicType.biologicalSex,
              );
              expect(
                characteristicPermissions[1].characteristicType,
                HealthCharacteristicType.dateOfBirth,
              );
            },
          );

          test(
            'returns empty list if no HealthCharacteristicPermission',
            () {
              const onlyData = <Permission>[
                HealthDataPermission(
                  dataType: HealthDataType.steps,
                  accessType: HealthDataPermissionAccessType.read,
                ),
              ];
              expect(
                onlyData.characteristicPermissions,
                isEmpty,
              );
            },
          );
        },
      );
    },
  );
}
