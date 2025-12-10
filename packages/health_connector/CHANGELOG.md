## 1.2.1

 - **FIX**(health_connector_hk_ios): Ensure Pigeon completion callbacks execute on main thread. ([bc8c1d98](https://github.com/fam-tung-lam/health_connector/commit/bc8c1d98e6520b3bb8d5f8cb1264eae49f21e64c))
 - **FIX**(health_connector_hk_ios): Map blood pressure types to corresponding HealthKit types. ([ff057529](https://github.com/fam-tung-lam/health_connector/commit/ff057529d7397b80196b6063036526842973ff8d))
 - **REFACTOR**(health_connector_hc_android): Add `complete()` helper for Pigeon callbacks. ([d72e1bfc](https://github.com/fam-tung-lam/health_connector/commit/d72e1bfcd661b4df9c3540ea4f5c38e87638d5b1))

## 1.2.0

 - **FEAT**: Add support for blood pressure data types.

## 1.1.0

 - **FEAT**: Add nutrient and nutrition records and data types. ([77e3a8d0](https://github.com/fam-tung-lam/health_connector/commit/77e3a8d00e6afaf43f56a24eb7c55621d82f63ad))

## 1.0.0

* **FEAT**: Implement `HealthConnector` facade providing unified API across platforms.
* **FEAT**: Add support for health data types:
    - Distance
    - Active calories burned
    - Floors climbed
    - Wheelchair pushes
    - Height
    - Body temperature
    - Lean body mass
    - Hydration
    - Heart rate
    - Sleep stage (iOS) and session (Android)
