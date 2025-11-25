import Foundation
import HealthKit

// ==================== STEP RECORD MAPPERS ====================

extension StepRecordDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantitySample`.
     *
     * - Throws: An error if the quantity type cannot be created.
     */
    func toHealthKit() throws -> HKQuantitySample {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw NSError(
                domain: "HealthConnectorError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create step count quantity type"]
            )
        }

        let quantity = HKQuantity(unit: .count(), doubleValue: count.value)
        let startDate = Date(timeIntervalSince1970: TimeInterval(startTime) / 1000.0)
        let endDate = Date(timeIntervalSince1970: TimeInterval(endTime) / 1000.0)

        return HKQuantitySample(
            type: type,
            quantity: quantity,
            start: startDate,
            end: endDate,
            device: metadata.toHealthKitDevice(),
            metadata: metadata.toHealthKitMetadata()
        )
    }
}

extension HKQuantitySample {
    /**
     * Converts this HealthKit sample to a `StepRecordDto`.
     *
     * Returns `nil` if this sample is not a step count sample.
     */
    func toStepRecordDto() -> StepRecordDto? {
        guard quantityType.identifier == HKQuantityTypeIdentifier.stepCount.rawValue else {
            return nil
        }

        let count = Int64(quantity.doubleValue(for: .count()))

        return StepRecordDto(
            count: count.toNumericDto(),
            endTime: Int64(endDate.timeIntervalSince1970 * 1000),
            id: uuid.uuidString,
            metadata: (metadata ?? [:]).toMetadataDto(
                source: sourceRevision.source,
                device: device
            ),
            startTime: Int64(startDate.timeIntervalSince1970 * 1000),
            endZoneOffsetSeconds: nil, // HealthKit doesn't store zone offsets
            startZoneOffsetSeconds: nil
        )
    }
}

// ==================== WEIGHT RECORD MAPPERS ====================

extension WeightRecordDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantitySample`.
     *
     * - Throws: An error if the quantity type cannot be created.
     */
    func toHealthKit() throws -> HKQuantitySample {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
            throw NSError(
                domain: "HealthConnectorError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create body mass quantity type"]
            )
        }

        let quantity = weight.toHealthKit()
        let date = Date(timeIntervalSince1970: TimeInterval(time) / 1000.0)

        return HKQuantitySample(
            type: type,
            quantity: quantity,
            start: date,
            end: date, // Instant records have same start and end
            device: metadata.toHealthKitDevice(),
            metadata: metadata.toHealthKitMetadata()
        )
    }
}

extension HKQuantitySample {
    /**
     * Converts this HealthKit sample to a `WeightRecordDto`.
     *
     * Returns `nil` if this sample is not a body mass sample.
     */
    func toWeightRecordDto() -> WeightRecordDto? {
        guard quantityType.identifier == HKQuantityTypeIdentifier.bodyMass.rawValue else {
            return nil
        }

        return WeightRecordDto(
            id: uuid.uuidString,
            metadata: (metadata ?? [:]).toMetadataDto(
                source: sourceRevision.source,
                device: device
            ),
            time: Int64(startDate.timeIntervalSince1970 * 1000),
            weight: quantity.toMassDto(),
            zoneOffsetSeconds: nil // HealthKit doesn't store zone offsets
        )
    }
}


