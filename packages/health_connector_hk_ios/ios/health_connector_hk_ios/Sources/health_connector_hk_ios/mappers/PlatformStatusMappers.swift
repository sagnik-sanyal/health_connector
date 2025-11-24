import Foundation

/**
 * Extension to convert `HealthPlatformStatusDto` to HealthKit status representation.
 */
extension HealthPlatformStatusDto {
    /**
     * Converts a HealthKit availability boolean to a `HealthPlatformStatusDto`.
     *
     * HealthKit uses a simple boolean check (`HKHealthStore.isHealthDataAvailable()`)
     * to determine availability, which we map to the platform status DTO:
     * - `true` → `.available`
     * - `false` → `.notAvailable`
     *
     * Note: The `.installationOrUpdateRequired` status is specific to Android Health Connect
     * and is not applicable to iOS HealthKit.
     *
     * - Parameter isAvailable: Whether HealthKit is available on the device.
     * - Returns: The corresponding `HealthPlatformStatusDto`.
     */
    static func fromHealthKitAvailability(_ isAvailable: Bool) -> HealthPlatformStatusDto {
        return isAvailable ? .available : .notAvailable
    }
}

