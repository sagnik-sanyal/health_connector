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
