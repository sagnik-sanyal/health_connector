## 2.0.0

> **Note**: This release has breaking changes.

- **BREAKING** **FEAT**: Introduce `TimeDuration` unit and replace `Number` with it for sleep data types. ([459798dd](https://github.com/fam-tung-lam/health_connector/commit/459798dd25d3ff014b824f4d9d7f79aa27ac0f53))
- **BREAKING** **FEAT**: Unify deletion API with polymorphic request pattern. ([f67cf5ae](https://github.com/fam-tung-lam/health_connector/commit/f67cf5ae0cda0a513c37b844aa44e8815fde0996))
- **BREAKING** **REFACTOR**: Remove support for "delete-then-create" logic for iOS HealthKit. ([e79b1772](https://github.com/fam-tung-lam/health_connector/commit/e79b177270ebe925b20b0309a5a31e9d44e648b5))
- **BREAKING** **REFACTOR**: Standardize and synchronize error codes across platforms. ([121df395](https://github.com/fam-tung-lam/health_connector/commit/121df395899bf3ba919a4d51a3c29527c01ace0d))
- **FEAT**: Implement atomic batch writes on iOS HealthKit. ([9dbbd181](https://github.com/fam-tung-lam/health_connector/commit/9dbbd181792039140a704ebe404a4d03d6191f95))
- **FEAT**: Add support for exercise session data type and record. ([d36b528c](https://github.com/fam-tung-lam/health_connector/commit/d36b528c7f6ec5b7ae3a33e0e8137c557c870e46))
- **FEAT**: Add `updateRecords` API for batch record updates. ([04e5463e](https://github.com/fam-tung-lam/health_connector/commit/04e5463e96552c04c331b8025d6e5d831e28953e))
- **FEAT**: Implement `HealthConnectorInfiPListService` for validating the application's Info.plist configuration. ([7846492f](https://github.com/fam-tung-lam/health_connector/commit/7846492fd7ad77c1da66ed3f9a08d1bf6361a59d))
- **FEAT**: Add full support for distance records and data types. ([84e27c08](https://github.com/fam-tung-lam/health_connector/commit/84e27c0821bad311aaf7bf6f1d2b577b50365700))
- **FEAT**: Add full support for speed records and data types. ([f07714db](https://github.com/fam-tung-lam/health_connector/commit/f07714db7b9302eea65e19aabab9e036bafbcab6))
- **PERF**: Use HealthKit batch delete API instead of for-loop deletion. ([b4159af1](https://github.com/fam-tung-lam/health_connector/commit/b4159af1ff015cf9890feab2418a22bc1e034b99))
- **FIX**: Implement missing health record objects deletion for correlation sample types. ([655d865e](https://github.com/fam-tung-lam/health_connector/commit/655d865e8dce71c69280fefce476335164b04b4f))

## 1.4.0

 - **FEAT**: Add blood glucose data type. ([18803d0f](https://github.com/fam-tung-lam/health_connector/commit/18803d0f6b182595f1dc1d747cdb8760a7423f1f))

## 1.3.0

 - **DEPS**: Update a dependency to the latest release.
 - **FEAT**: Add VO2Max data type. ([2a61940f](https://github.com/fam-tung-lam/health_connector/commit/2a61940f010c7f8e7bfca438c5f969ed178193ad))
 - **FEAT**: Add respiratory rate data type. ([b6081fa6](https://github.com/fam-tung-lam/health_connector/commit/b6081fa6f99772e0b64b7ca272acf822854cc766))
 - **FEAT**: Add oxygen saturation data type. ([51022aa1](https://github.com/fam-tung-lam/health_connector/commit/51022aa15d7d2d1c91b3512517f1edbbb0af9473))
 - **FEAT**: Add resting heart rate data type. ([17bbf3b1](https://github.com/fam-tung-lam/health_connector/commit/17bbf3b142a15b17bf4ffb5a51ada4ca5b3fef0f))

## 1.2.2

- **FIX**: Prevent infinite recursion in nutrient record mappers. ([4f09dd9c](https://github.com/fam-tung-lam/health_connector/commit/4f09dd9c80695ff0d092bccd614d6974f7295931))
- **FIX**: Request auth for correlation component types not correlation itself. ([668afefa](https://github.com/fam-tung-lam/health_connector/commit/668afefaf435c764e02151f685bc9a99b7709d57))

## 1.2.1

- **FIX**: Ensure Pigeon completion callbacks execute on main thread. ([bc8c1d98](https://github.com/fam-tung-lam/health_connector/commit/bc8c1d98e6520b3bb8d5f8cb1264eae49f21e64c))
- **FIX**: Map blood pressure types to corresponding HealthKit types. ([ff057529](https://github.com/fam-tung-lam/health_connector/commit/ff057529d7397b80196b6063036526842973ff8d))

## 1.2.0

- **FEAT**: Add support for blood pressure records and data types. ([7c3d9525](https://github.com/fam-tung-lam/health_connector/commit/7c3d9525f880e13e893b7831c35185997b1b46cf))

## 1.1.0

- **FEAT**: Add support for nutrient and nutrition health data types. ([2c4d049a](https://github.com/fam-tung-lam/health_connector/commit/2c4d049af240da1f3841b1fa83e8351e51ab1fe2))

## 1.0.0

- **FEAT**: Implement iOS HealthKit platform client.
- **FEAT**: Add support for common health data types
