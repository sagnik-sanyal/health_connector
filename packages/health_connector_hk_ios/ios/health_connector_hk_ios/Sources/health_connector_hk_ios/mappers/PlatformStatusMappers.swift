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
     * Note: iOS HealthKit only supports two states (available/not available), unlike
     * Android Health Connect which has additional installation/update states.
     *
     * - Parameter isAvailable: Whether HealthKit is available on the device.
     * - Returns: The corresponding `HealthPlatformStatusDto`.
     */

    static func fromHealthKitAvailability(_ isAvailable: Bool) -> HealthPlatformStatusDto {
        return isAvailable ? .available: .notAvailable
    }
}

