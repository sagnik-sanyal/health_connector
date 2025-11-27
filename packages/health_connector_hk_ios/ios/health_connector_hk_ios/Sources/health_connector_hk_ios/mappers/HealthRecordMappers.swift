import Foundation
import HealthKit

// ==================== ACTIVE CALORIES BURNED RECORD MAPPERS ====================

extension ActiveCaloriesBurnedRecordDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantitySample`.
     *
     * - Throws: An error if the quantity type cannot be created.
     */

    func toHealthKit() throws -> HKQuantitySample {
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw NSError(
                domain: "HealthConnectorError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create active energy burned quantity type"]
            )
        }

        let quantity = energy.toHealthKit()
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
     * Converts this HealthKit sample to an `ActiveCaloriesBurnedRecordDto`.
     *
     * Returns `nil` if this sample is not an active energy burned sample.
     */

    func toActiveCaloriesBurnedRecordDto() -> ActiveCaloriesBurnedRecordDto? {
        guard quantityType.identifier == HKQuantityTypeIdentifier.activeEnergyBurned.rawValue else {
            return nil
        }

        return ActiveCaloriesBurnedRecordDto(
            energy: quantity.toEnergyDto(),
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

// ==================== DISTANCE RECORD MAPPERS ====================

extension DistanceRecordDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantitySample`.
     *
     * - Throws: An error if the quantity type cannot be created.
     */

    func toHealthKit() throws -> HKQuantitySample {
        guard let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            throw NSError(
                domain: "HealthConnectorError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create distance quantity type"]
            )
        }

        let quantity = distance.toHealthKit()
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
     * Converts this HealthKit sample to a `DistanceRecordDto`.
     *
     * Returns `nil` if this sample is not a distance walking/running sample.
     */

    func toDistanceRecordDto() -> DistanceRecordDto? {
        guard quantityType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue else {
            return nil
        }

        return DistanceRecordDto(
            distance: quantity.toLengthDto(),
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

// ==================== FLOORS CLIMBED RECORD MAPPERS ====================

extension FloorsClimbedRecordDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantitySample`.
     *
     * - Throws: An error if the quantity type cannot be created.
     */

    func toHealthKit() throws -> HKQuantitySample {
        guard let type = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            throw NSError(
                domain: "HealthConnectorError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create flights climbed quantity type"]
            )
        }

        let quantity = HKQuantity(unit: .count(), doubleValue: floors.value)
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
     * Converts this HealthKit sample to a `FloorsClimbedRecordDto`.
     *
     * Returns `nil` if this sample is not a flights climbed sample.
     */

    func toFloorsClimbedRecordDto() -> FloorsClimbedRecordDto? {
        guard quantityType.identifier == HKQuantityTypeIdentifier.flightsClimbed.rawValue else {
            return nil
        }

        let unit = HKUnit.count()
        let value = quantity.doubleValue(for: unit)

        return FloorsClimbedRecordDto(
            floors: NumericDto(unit: NumericUnitDto.numeric, value: value),
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

// ==================== WHEELCHAIR PUSHES RECORD MAPPERS ====================

extension WheelchairPushesRecordDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantitySample`.
     *
     * - Throws: An error if the quantity type cannot be created.
     */

    func toHealthKit() throws -> HKQuantitySample {
        guard let type = HKQuantityType.quantityType(forIdentifier: .pushCount) else {
            throw NSError(
                domain: "HealthConnectorError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to create push count quantity type"]
            )
        }

        let quantity = HKQuantity(unit: .count(), doubleValue: pushes.value)
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
     * Converts this HealthKit sample to a `WheelchairPushesRecordDto`.
     *
     * Returns `nil` if this sample is not a push count sample.
     */

    func toWheelchairPushesRecordDto() -> WheelchairPushesRecordDto? {
        guard quantityType.identifier == HKQuantityTypeIdentifier.pushCount.rawValue else {
            return nil
        }

        let unit = HKUnit.count()
        let value = quantity.doubleValue(for: unit)

        return WheelchairPushesRecordDto(
            pushes: NumericDto(unit: NumericUnitDto.numeric, value: value),
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


