import Foundation
import HealthKit

/// Handler for lean body mass data (instant quantity type)
///
/// **Data Type:** Lean Body Mass
/// **Record Pattern:** Instant (single timestamp, no duration)
/// **Aggregation:** None (no aggregation supported)
/// **HealthKit Type:** HKQuantityTypeIdentifier.leanBodyMass
///
/// **Usage:**
/// - Reading: Retrieves lean body mass measurements at specific points
/// - Writing: Records lean body mass measurements
/// - Aggregating: NOT supported (individual measurements are tracked)
/// - Pagination: Uses time (not endTime) for cursor-based pagination
///
/// **Example:**
/// - Lean body mass: 65.5 kg
/// - time: measurement timestamp (single point)
///
/// **Note:** Lean body mass = total weight - body fat weight.
/// Usually calculated from body fat percentage and total weight.
/// Aggregations are not meaningful for this metric - tracking individual
/// measurements over time is more useful.

struct LeanBodyMassHandler: HealthKitQuantityHandler {
    static var supportedType: HealthDataTypeDto {
        .leanBodyMass
    }

    static var category: HealthKitDataCategory {
        .quantitySample
    }

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HKQuantitySample, got \(type(of: sample))")
        }
        guard let dto = quantitySample.toLeanBodyMassRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to LeanBodyMassRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        guard let leanMassDto = dto as? LeanBodyMassRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected LeanBodyMassRecordDto, got \(type(of: dto))"
            )
        }
        return try leanMassDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        return HKQuantityType.quantityType(forIdentifier: .leanBodyMass)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        guard let leanMassDto = dto as? LeanBodyMassRecordDto else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected LeanBodyMassRecordDto, got \(type(of: dto))")
        }
        return leanMassDto.time
    }

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        throw HealthConnectorErrors.invalidArgument(
            message: "Aggregation metric '\(metric)' not supported for lean body mass",
            details: "Individual measurements should be tracked over time instead"
        )
    }

    static func extractAggregateValue(
        from _: HKStatistics,
        metric: AggregationMetricDto
    ) throws -> MeasurementUnitDto {
        throw HealthConnectorErrors.invalidArgument(
            message: "Aggregation metric '\(metric)' not supported for lean body mass",
            details: "Individual measurements should be tracked over time instead"
        )
    }
}
