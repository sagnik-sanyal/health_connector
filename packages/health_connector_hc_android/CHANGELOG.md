## 1.4.0

 - **FEAT**(health_connector_hc_android): Add blood glucose data type. ([c018d008](https://github.com/fam-tung-lam/health_connector/commit/c018d008bbf012bfa1c609025bd41d920dd4b53a))

## 1.3.0

 - **CHORE**: Update a dependency to the latest release.
 - **FEAT**(health_connector_hc_android): Add VO2Max data type. ([3e51085a](https://github.com/fam-tung-lam/health_connector/commit/3e51085a1602e50febddde9f501002ec6867d649))
 - **FEAT**(health_connector_hc_android): Add respiratory rate data type. ([a67dabba](https://github.com/fam-tung-lam/health_connector/commit/a67dabba093393d4064f60f99769edb71d584236))
 - **FEAT**(health_connector_hc_android): Add oxygen saturation data type. ([b8928fc7](https://github.com/fam-tung-lam/health_connector/commit/b8928fc785128757bd57d9b07c7ce6c0d436912f))
 - **FEAT**(health_connector_hc_android): Add resting heart rate data type. ([4972b907](https://github.com/fam-tung-lam/health_connector/commit/4972b9078563225fee0aa7b8506102d9955867e4))

## 1.2.2

- **REFACTOR**(health_connector_hc_android): Simplify `TAG` initialization with null-coalescing
  operator to avoid redundant null
  checks. ([7ee0217f](https://github.com/fam-tung-lam/health_connector/commit/7ee0217fb0b87ee3ca3ab6e75f104b7070b81678))
- **REFACTOR**(health_connector_hc_android): Replace null/0 returns with explicit error throwing for
  type guard failures for all
  handlers. ([ae151cf5](https://github.com/fam-tung-lam/health_connector/commit/ae151cf5eb03e55321783029eecf3f9983b4e33a))
- **REFACTOR**(health_connector_hc_android): Improve permission mapping and error
  handling. ([29d29b17](https://github.com/fam-tung-lam/health_connector/commit/29d29b17910c9fd100397a1aaf2d39209548b947))
- **REFACTOR**(health_connector_hc_android): Separate health record mapper files for each health
  record
  type. ([e72390d2](https://github.com/fam-tung-lam/health_connector/commit/e72390d255423fb4a59af2d11c7921a43ef02daf))
- **FIX**(health_connector_hc_android): Prevent infinite recursion in nutrient record
  mappers. ([4f09dd9c](https://github.com/fam-tung-lam/health_connector/commit/4f09dd9c80695ff0d092bccd614d6974f7295931))
- **FIX**(health_connector_hc_android): Add missing blood pressure permission
  mapping. ([9728770f](https://github.com/fam-tung-lam/health_connector/commit/9728770f9e1b2dea78142deb6ae74cff78a859cb))

## 1.2.1

- **REFACTOR**(health_connector_hc_android): Add `complete()` helper for Pigeon
  callbacks. ([d72e1bfc](https://github.com/fam-tung-lam/health_connector/commit/d72e1bfcd661b4df9c3540ea4f5c38e87638d5b1))

## 1.2.0

- **FEAT**(health_connector_hc_android): Introduce specialized aggregation
  requests. ([55f00e29](https://github.com/fam-tung-lam/health_connector/commit/55f00e294d41f91c95d034768d99315baebd7208))
- **FEAT**(health_connector_hc_android): Add support for blood pressure records and data
  types. ([c5dc5fc9](https://github.com/fam-tung-lam/health_connector/commit/c5dc5fc90afd2c010e77a799bb2a5a04709ecbcf))

## 1.1.0

- **REFACTOR**: Simplify record extraction in clients and remove unused `ReadRecordResponseDto`
  extension. ([7303bfb0](https://github.com/fam-tung-lam/health_connector/commit/7303bfb0df6f7e87612e23e23732f2d2b694f961))
- **FEAT**(health_connector_hc_android): Implement nutrient health data permissions based on
  nutrition permission
  status. ([a39ab697](https://github.com/fam-tung-lam/health_connector/commit/a39ab6970f70fe2078a60ce141edc466ac3f6dfd))
- **FEAT**(health_connector_hc_android): Add support for nutrient and nutrition health data
  types. ([be34f9ed](https://github.com/fam-tung-lam/health_connector/commit/be34f9eda6adb25341b1f4c4b6f0513fad97d237))
- **FEAT**: Add nutrient and nutrition records and data
  types. ([77e3a8d0](https://github.com/fam-tung-lam/health_connector/commit/77e3a8d00e6afaf43f56a24eb7c55621d82f63ad))

## 1.0.0

* **FEAT**: Implement Android Health Connect platform client.
* **FEAT**: Add support for various health data types:
    - Distance
    - Active calories burned
    - Floors climbed
    - Wheelchair pushes
    - Height
    - Body temperature
    - Lean body mass
    - Hydration
    - Heart rate
    - Sleep session
