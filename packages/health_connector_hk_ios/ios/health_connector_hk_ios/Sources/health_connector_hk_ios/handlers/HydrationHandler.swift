import Foundation
import HealthKit

/// Handler for hydration data (interval quantity type)
///
/// **Data Type:** Hydration (Water/Fluid Intake)
/// **Record Pattern:** Interval (has startTime and endTime)
/// **Aggregation:** Sum only (cumulative volume)
/// **HealthKit Type:** HKQuantityTypeIdentifier.dietaryWater
///
/// **Usage:**
/// - Reading: Retrieves water/fluid intake over time intervals
/// - Writing: Records water consumption
/// - Aggregating: Supports sum (total fluid intake)
/// - Pagination: Uses endTime for cursor-based pagination
///
/// **Example:**
/// - Drinking 500 mL of water at 11:30 AM
/// - startTime: 11:30 AM, endTime: 11:30 AM, volume: 0.5 liters
///
/// **Note:** Typically recorded as instant events (same start/end time),
/// but HealthKit treats it as an interval type for consistency with dietary tracking.

struct HydrationHandler: HealthKitQuantityHandler {
    static var supportedType: HealthDataTypeDto {
        .hydration
    }

    static var category: HealthKitDataCategory {
        .quantitySample
    }

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HKQuantitySample, got \(type(of: sample))")
        }
        guard let dto = quantitySample.toHydrationRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to HydrationRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        guard let hydrationDto = dto as? HydrationRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected HydrationRecordDto, got \(type(of: dto))"
            )
        }
        return try hydrationDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        return HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        guard let hydrationDto = dto as? HydrationRecordDto else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HydrationRecordDto, got \(type(of: dto))")
        }
        return hydrationDto.endTime
    }

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .sum:
            return .cumulativeSum
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for hydration (cumulative data)",
                details: "Only 'sum' is supported"
            )
        }
    }

    static func extractAggregateValue(
        from statistics: HKStatistics,
        metric: AggregationMetricDto
    ) throws -> MeasurementUnitDto {
        let quantity: HKQuantity? = switch metric {
        case .sum:
            statistics.sumQuantity()
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for hydration",
                details: "Only 'sum' is supported"
            )
        }

        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for dietaryWater"
            )
        }

        let liters = quantity.doubleValue(for: .liter())
        return VolumeDto(unit: .liters, value: liters)
    }
}
