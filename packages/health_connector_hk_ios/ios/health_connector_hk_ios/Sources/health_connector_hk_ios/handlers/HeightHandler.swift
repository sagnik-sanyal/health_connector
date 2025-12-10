import Foundation
import HealthKit

/// Handler for height data (instant quantity type)
///
/// **Data Type:** Height
/// **Record Pattern:** Instant (single timestamp, no duration)
/// **Aggregation:** Average, Min, Max (discrete values)
/// **HealthKit Type:** HKQuantityTypeIdentifier.height
///
/// **Usage:**
/// - Reading: Retrieves height measurements at specific points in time
/// - Writing: Records height measurements
/// - Aggregating: Supports avg (average height), min (shortest), max (tallest)
/// - Pagination: Uses time (not endTime) for cursor-based pagination
///
/// **Example:**
/// - Height measurement at doctor's office: 175 cm
/// - time: appointment timestamp (single point)
///
/// **Note:** Height changes slowly over lifetime (growth in children, shrinkage in elderly).
/// Multiple measurements allow tracking growth or posture changes.

struct HeightHandler: HealthKitQuantityHandler {
    static var supportedType: HealthDataTypeDto {
        .height
    }
    static var category: HealthKitDataCategory {
        .quantitySample
    }

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HKQuantitySample, got \(type(of: sample))")
        }
        guard let dto = quantitySample.toHeightRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to HeightRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        guard let heightDto = dto as? HeightRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected HeightRecordDto, got \(type(of: dto))"
            )
        }
        return try heightDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        return HKQuantityType.quantityType(forIdentifier: .height)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        guard let heightDto = dto as? HeightRecordDto else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HeightRecordDto, got \(type(of: dto))")
        }
        return heightDto.time
    }

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .avg:
            return .discreteAverage
        case .min:
            return .discreteMin
        case .max:
            return .discreteMax
        case .sum, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for height (discrete data)",
                details: "Supported metrics: avg, min, max"
            )
        }
    }
    
    static func extractAggregateValue(
        from statistics: HKStatistics,
        metric: AggregationMetricDto
    ) throws -> MeasurementUnitDto {
        let quantity: HKQuantity? = switch metric {
        case .avg:
            statistics.averageQuantity()
        case .min:
            statistics.minimumQuantity()
        case .max:
            statistics.maximumQuantity()
        case .sum, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for height",
                details: "Supported metrics: avg, min, max"
            )
        }
        
        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for height"
            )
        }
        
        let meters = quantity.doubleValue(for: .meter())
        return LengthDto(unit: .meters, value: meters)
    }
}
