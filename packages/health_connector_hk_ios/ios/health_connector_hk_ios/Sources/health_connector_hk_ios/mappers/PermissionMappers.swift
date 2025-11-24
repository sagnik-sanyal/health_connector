import Foundation
import HealthKit

/**
 * Extension to convert `HealthDataPermissionDto` to HealthKit types.
 *
 * This extension provides utility methods to map Pigeon DTOs to their corresponding
 * HealthKit types for use with the HealthKit SDK.
 */
extension HealthDataPermissionDto {
    /**
     * Converts this permission DTO to a HealthKit `HKObjectType`.
     *
     * ## HealthKit Object Types
     * HealthKit uses different object types for different health data:
     * - Quantity types: For data that can be measured (e.g., steps, heart rate)
     * - Category types: For data that falls into categories (e.g., sleep analysis)
     * - Characteristic types: For unchanging data (e.g., blood type, biological sex)
     *
     * - Returns: The corresponding `HKObjectType` for this health data permission.
     *            Currently supports:
     *            - `.steps` → `HKQuantityType.quantityType(forIdentifier: .stepCount)`
     *            - `.weight` → `HKQuantityType.quantityType(forIdentifier: .bodyMass)`
     */
    func toHealthKitObjectType() -> HKObjectType {
        switch self.healthDataType {
        case .steps:
            return HKQuantityType.quantityType(forIdentifier: .stepCount)!
        case .weight:
            return HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        }
    }
}

