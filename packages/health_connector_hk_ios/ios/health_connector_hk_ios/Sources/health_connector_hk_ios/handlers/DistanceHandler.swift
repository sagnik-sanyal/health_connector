import Foundation
import HealthKit

/// Handler for distance data (interval quantity type)
///
/// **Data Type:** Distance (Walking + Running)
/// **Record Pattern:** Interval (has startTime and endTime)
/// **Aggregation:** Sum only (cumulative distance)
/// **HealthKit Type:** HKQuantityTypeIdentifier.distanceWalkingRunning
///
/// **Usage:**
/// - Reading: Retrieves distance traveled over time intervals
/// - Writing: Records distance traveled during activities
/// - Aggregating: Supports sum (total distance)
/// - Pagination: Uses endTime for cursor-based pagination
///
/// **Example:**
/// - Walking 2.5 km from 9:00 AM to 9:30 AM
/// - startTime: 9:00 AM, endTime: 9:30 AM, distance: 2500 meters
///
/// **Note:** This tracks walking and running distance. Cycling and other activities
/// have separate distance types in HealthKit.

struct DistanceHandler: HealthKitQuantityHandler {
    static var supportedType: HealthDataTypeDto {
        .distance
    }
    static var category: HealthKitDataCategory {
        .quantitySample
    }

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HKQuantitySample, got \(type(of: sample))")
        }
        guard let dto = quantitySample.toDistanceRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to DistanceRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        guard let distanceDto = dto as? DistanceRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected DistanceRecordDto, got \(type(of: dto))"
            )
        }
        return try distanceDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        guard let distanceDto = dto as? DistanceRecordDto else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected DistanceRecordDto, got \(type(of: dto))")
        }
        return distanceDto.endTime
    }

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .sum:
            return .cumulativeSum
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for distance (cumulative data)",
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
                message: "Aggregation metric '\(metric)' not supported for distance",
                details: "Only 'sum' is supported"
            )
        }
        
        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for distanceWalkingRunning"
            )
        }
        
        let meters = quantity.doubleValue(for: .meter())
        return LengthDto(unit: .meters, value: meters)
    }
}
