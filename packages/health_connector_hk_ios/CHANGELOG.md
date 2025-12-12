## 1.4.0

 - **FEAT**(health_connector_hk_ios): Add blood glucose data type. ([18803d0f](https://github.com/fam-tung-lam/health_connector/commit/18803d0f6b182595f1dc1d747cdb8760a7423f1f))

## 1.3.0

 - **CHORE**: Update a dependency to the latest release.
 - **FEAT**(health_connector_hk_ios): Add VO2Max data type. ([2a61940f](https://github.com/fam-tung-lam/health_connector/commit/2a61940f010c7f8e7bfca438c5f969ed178193ad))
 - **FEAT**(health_connector_hk_ios): Add respiratory rate data type. ([b6081fa6](https://github.com/fam-tung-lam/health_connector/commit/b6081fa6f99772e0b64b7ca272acf822854cc766))
 - **FEAT**(health_connector_hk_ios): Add oxygen saturation data type. ([51022aa1](https://github.com/fam-tung-lam/health_connector/commit/51022aa15d7d2d1c91b3512517f1edbbb0af9473))
 - **FEAT**(health_connector_hk_ios): Add resting heart rate data type. ([17bbf3b1](https://github.com/fam-tung-lam/health_connector/commit/17bbf3b142a15b17bf4ffb5a51ada4ca5b3fef0f))

## 1.2.2

- **REFACTOR**(health_connector_hk_ios): Replace nil returns with explicit error throwing and add
  `extractAggregateValue` to all
  handlers. ([4e175f1b](https://github.com/fam-tung-lam/health_connector/commit/4e175f1b0130a1e492a625d9e87b5e6581527777))
- **REFACTOR**(health_connector_hk_ios): Separate health record mapper files for each health record
  type. ([a5763c37](https://github.com/fam-tung-lam/health_connector/commit/a5763c3750648a8c76f4519de43821c311e615af))
- **FIX**(health_connector_hk_ios): Prevent infinite recursion in nutrient record
  mappers. ([4f09dd9c](https://github.com/fam-tung-lam/health_connector/commit/4f09dd9c80695ff0d092bccd614d6974f7295931))
- **FIX**(health_connector_hk_ios): Request auth for correlation component types not correlation
  itself. ([668afefa](https://github.com/fam-tung-lam/health_connector/commit/668afefaf435c764e02151f685bc9a99b7709d57))

## 1.2.1

- **FIX**(health_connector_hk_ios): Ensure Pigeon completion callbacks execute on main
  thread. ([bc8c1d98](https://github.com/fam-tung-lam/health_connector/commit/bc8c1d98e6520b3bb8d5f8cb1264eae49f21e64c))
- **FIX**(health_connector_hk_ios): Map blood pressure types to corresponding HealthKit
  types. ([ff057529](https://github.com/fam-tung-lam/health_connector/commit/ff057529d7397b80196b6063036526842973ff8d))

## 1.2.0

- **FEAT**(health_connector_hk_ios): Add support for blood pressure records and data
  types. ([7c3d9525](https://github.com/fam-tung-lam/health_connector/commit/7c3d9525f880e13e893b7831c35185997b1b46cf))

## 1.1.0

- **REFACTOR**: Simplify record extraction in clients and remove unused `ReadRecordResponseDto`
  extension. ([7303bfb0](https://github.com/fam-tung-lam/health_connector/commit/7303bfb0df6f7e87612e23e23732f2d2b694f961))
- **FEAT**(health_connector_hk_ios): Add support for nutrient and nutrition health data
  types. ([2c4d049a](https://github.com/fam-tung-lam/health_connector/commit/2c4d049af240da1f3841b1fa83e8351e51ab1fe2))
- **FEAT**(health_connector_hk_ios): Mark nutrient and nutrition records as
  unimplemented. ([8777868f](https://github.com/fam-tung-lam/health_connector/commit/8777868fc1d62e1dfbbf357877e9b24d7dbbb97e))

## 1.0.0

- **FEAT**: Implement iOS HealthKit platform client.
- **FEAT**: Add support for health data types:
    - Distance
    - Active calories burned
    - Floors climbed
    - Wheelchair pushes
    - Height
    - Body temperature
    - Lean body mass
    - Hydration
    - Heart rate
    - Sleep stage
