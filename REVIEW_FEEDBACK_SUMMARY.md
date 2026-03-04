# Review Feedback Summary — feat: Add Health Characteristics iOS

> Generated from automated pull-request review on commit `ea7490e`.

---

## 1. Version / CHANGELOG mismatches

All four packages have CHANGELOG entries for a version that does not match the `version:` field in the corresponding `pubspec.yaml`. This will cause publishing and dependency-resolution failures.

| Package | CHANGELOG version | `pubspec.yaml` version | Action required |
|---|---|---|---|
| `health_connector` | `3.9.0` | `3.8.0` | Bump pubspec to `3.9.0` **or** update CHANGELOG header to `3.8.0` |
| `health_connector_core` | `3.9.0` | `3.8.0` | Same as above |
| `health_connector_hk_ios` | `3.9.0` | `3.8.0` | Same as above |
| `health_connector_hc_android` | `3.6.0` | `3.5.0` | Bump pubspec to `3.6.0` **or** update CHANGELOG header to `3.5.0` |

**Files affected:**
- `packages/health_connector/CHANGELOG.md` + `packages/health_connector/pubspec.yaml`
- `packages/health_connector_core/CHANGELOG.md` + `packages/health_connector_core/pubspec.yaml`
- `packages/health_connector_hk_ios/CHANGELOG.md` + `packages/health_connector_hk_ios/pubspec.yaml`
- `packages/health_connector_hc_android/CHANGELOG.md` + `packages/health_connector_hc_android/pubspec.yaml`

---

## 2. Invalid HealthKit API usage in `HealthConnectorPermissionService.swift`

**File:** `packages/health_connector_hk_ios/ios/health_connector_hk_ios/Sources/health_connector_hk_ios/services/HealthConnectorPermissionService.swift` (lines 146–152)

`HKCharacteristicType(.biologicalSex)` / `HKCharacteristicType(.dateOfBirth)` are **not** valid HealthKit APIs and will cause a compile error. The correct approach is:

```swift
// Use HKObjectType.characteristicType(forIdentifier:) instead
guard let biologicalSexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex) else {
    throw HealthConnectorError.invalidArgument("Could not create biologicalSex characteristic type")
}
guard let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) else {
    throw HealthConnectorError.invalidArgument("Could not create dateOfBirth characteristic type")
}
```

Handle the `nil` case (optional result) by throwing a `HealthConnectorError.invalidArgument`.

---

## 3. Date-of-birth timezone issue in `HealthConnectorClient.swift`

**File:** `packages/health_connector_hk_ios/ios/health_connector_hk_ios/Sources/health_connector_hk_ios/HealthConnectorClient.swift` (lines 1095–1101)

`Calendar.current.date(from:)` interprets `DateComponents` in the device's current calendar and time zone. Because the Dart side decodes the resulting epoch milliseconds with `DateTime.fromMillisecondsSinceEpoch(..., isUtc: true)`, the decoded date can shift by a day for users in non-UTC time zones.

**Recommended fix — option A (fixed UTC calendar):**
```swift
var utcCalendar = Calendar(identifier: .gregorian)
utcCalendar.timeZone = TimeZone(identifier: "UTC")!
let date = utcCalendar.date(from: components)
```

**Recommended fix — option B (send components directly):**
Send `year`, `month`, and `day` as separate integer fields instead of an epoch timestamp, avoiding the time-zone conversion entirely.

---

## 4. Missing unit tests for `readCharacteristic()` in the iOS client

**File:** `packages/health_connector_hk_ios/lib/src/health_connector_hk_client.dart` (lines 795–845)

The new `readCharacteristic()` method has no unit tests in the existing iOS-client test suite (`health_connector_hk_client_test.dart`). The following scenarios should be covered:

1. **Correct DTO dispatch** — for each `HealthCharacteristicType` value, the correct DTO is passed to the platform client.
2. **DTO-to-domain mapping** — the returned DTO is correctly mapped to the expected domain model (e.g. `BiologicalSexCharacteristic`, `DateOfBirthCharacteristic`).
3. **Error translation** — a `PlatformException` thrown by the platform client is translated into the expected `HealthConnectorException`.

---

## Summary of actions

| # | Severity | Area | Status |
|---|---|---|---|
| 1 | 🔴 Blocking | Version/CHANGELOG mismatches (4 packages) | Open |
| 2 | 🔴 Blocking | Invalid HealthKit API → compile error | Open |
| 3 | 🟡 Important | Date-of-birth timezone bug | Open |
| 4 | 🟡 Important | Missing unit tests for `readCharacteristic()` | Open |
