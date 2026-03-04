import 'package:health_connector_core/health_connector_core.dart';
import 'package:test/test.dart';

void main() {
  group(
    'BiologicalSex',
    () {
      test(
        'has all expected values',
        () {
          expect(BiologicalSex.values, hasLength(4));
          expect(
            BiologicalSex.values,
            containsAll([
              BiologicalSex.notSet,
              BiologicalSex.female,
              BiologicalSex.male,
              BiologicalSex.other,
            ]),
          );
        },
      );
    },
  );

  group(
    'BiologicalSexCharacteristic',
    () {
      test(
        'can be instantiated with biologicalSex',
        () {
          const characteristic = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.female,
          );

          expect(
            characteristic.biologicalSex,
            equals(BiologicalSex.female),
          );
        },
      );

      test(
        'equality works correctly for same value',
        () {
          const char1 = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.male,
          );
          const char2 = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.male,
          );

          expect(char1 == char2, isTrue);
          expect(char1.hashCode == char2.hashCode, isTrue);
        },
      );

      test(
        'equality works correctly for different values',
        () {
          const char1 = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.male,
          );
          const char2 = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.female,
          );

          expect(char1 == char2, isFalse);
        },
      );

      test(
        'notSet is a valid biological sex value',
        () {
          const characteristic = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.notSet,
          );

          expect(
            characteristic.biologicalSex,
            equals(BiologicalSex.notSet),
          );
        },
      );

      test(
        'is a HealthCharacteristic',
        () {
          const characteristic = BiologicalSexCharacteristic(
            biologicalSex: BiologicalSex.female,
          );

          expect(characteristic, isA<HealthCharacteristic>());
        },
      );
    },
  );

  group(
    'DateOfBirthCharacteristic',
    () {
      test(
        'can be instantiated with dateOfBirth',
        () {
          final dateOfBirth = DateTime.utc(1990, 5, 15);
          final characteristic = DateOfBirthCharacteristic(
            dateOfBirth: dateOfBirth,
          );

          expect(characteristic.dateOfBirth, equals(dateOfBirth));
        },
      );

      test(
        'can be instantiated with null dateOfBirth',
        () {
          const characteristic = DateOfBirthCharacteristic();

          expect(characteristic.dateOfBirth, isNull);
        },
      );

      test(
        'equality works correctly for same value',
        () {
          final dateOfBirth = DateTime.utc(1990, 5, 15);
          final char1 = DateOfBirthCharacteristic(
            dateOfBirth: dateOfBirth,
          );
          final char2 = DateOfBirthCharacteristic(
            dateOfBirth: dateOfBirth,
          );

          expect(char1 == char2, isTrue);
          expect(char1.hashCode == char2.hashCode, isTrue);
        },
      );

      test(
        'equality works correctly for different values',
        () {
          final char1 = DateOfBirthCharacteristic(
            dateOfBirth: DateTime.utc(1990, 5, 15),
          );
          final char2 = DateOfBirthCharacteristic(
            dateOfBirth: DateTime.utc(1985, 3, 10),
          );

          expect(char1 == char2, isFalse);
        },
      );

      test(
        'equality works correctly for null vs non-null',
        () {
          const charNull = DateOfBirthCharacteristic();
          final charNonNull = DateOfBirthCharacteristic(
            dateOfBirth: DateTime.utc(1990, 5, 15),
          );

          expect(charNull == charNonNull, isFalse);
        },
      );

      test(
        'equality works correctly for both null',
        () {
          const char1 = DateOfBirthCharacteristic();
          const char2 = DateOfBirthCharacteristic();

          expect(char1 == char2, isTrue);
          expect(char1.hashCode == char2.hashCode, isTrue);
        },
      );

      test(
        'is a HealthCharacteristic',
        () {
          const characteristic = DateOfBirthCharacteristic();

          expect(characteristic, isA<HealthCharacteristic>());
        },
      );
    },
  );
}
