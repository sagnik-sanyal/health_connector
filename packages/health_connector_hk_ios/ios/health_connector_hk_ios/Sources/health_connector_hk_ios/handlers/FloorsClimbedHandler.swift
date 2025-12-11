import Foundation
import HealthKit

/// Handler for floors climbed data (interval quantity type)
///
/// **Data Type:** Floors Climbed
/// **Record Pattern:** Interval (has startTime and endTime)
/// **Aggregation:** Sum only (cumulative floors)
/// **HealthKit Type:** HKQuantityTypeIdentifier.flightsClimbed
///
/// **Usage:**
/// - Reading: Retrieves floors climbed over time intervals
/// - Writing: Records floors climbed during activities
/// - Aggregating: Supports sum (total floors climbed)
/// - Pagination: Uses endTime for cursor-based pagination
///
/// **Example:**
/// - Climbing 5 floors from 10:00 AM to 10:05 AM
/// - startTime: 10:00 AM, endTime: 10:05 AM, floors: 5
///
/// **Note:** One floor is approximately 10 feet (3 meters) of elevation gain.
/// Measured by barometric pressure changes.

struct FloorsClimbedHandler: HealthKitQuantityHandler {
    static var supportedType: HealthDataTypeDto {
        .floorsClimbed
    }

    static var category: HealthKitDataCategory {
        .quantitySample
    }

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HKQuantitySample, got \(type(of: sample))")
        }
        guard let dto = quantitySample.toFloorsClimbedRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to FloorsClimbedRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        guard let floorsDto = dto as? FloorsClimbedRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected FloorsClimbedRecordDto, got \(type(of: dto))"
            )
        }
        return try floorsDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        return HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        guard let floorsDto = dto as? FloorsClimbedRecordDto else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected FloorsClimbedRecordDto, got \(type(of: dto))")
        }
        return floorsDto.endTime
    }

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .sum:
            return .cumulativeSum
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for floors climbed (cumulative data)",
                details: "Only 'sum' is supported"
            )
        }
    }

    static func extractAggregateValue(
        from statistics: HKStatistics,
        metric: AggregationMetricDto
    ) throws -> MeasurementUnitDto {
        // Use immutable switch expression (Swift 5.9+)
        let quantity: HKQuantity? = switch metric {
        case .sum:
            statistics.sumQuantity()
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for floors climbed",
                details: "Only 'sum' is supported"
            )
        }

        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for flightsClimbed"
            )
        }

        let count = quantity.doubleValue(for: .count())
        return NumericDto(unit: .numeric, value: count)
    }
}
