import Foundation
import HealthKit

/// Handler for step count data (interval quantity type)
///
/// **Data Type:** Steps
/// **Record Pattern:** Interval (has startTime and endTime)
/// **Aggregation:** Sum only (cumulative count)
/// **HealthKit Type:** HKQuantityTypeIdentifier.stepCount
///
/// **Usage:**
/// - Reading: Retrieves step count samples over time ranges
/// - Writing: Records step counts for specific time intervals
/// - Aggregating: Supports sum (total steps) over date ranges
/// - Pagination: Uses endTime for cursor-based pagination
///
/// **Example:**
/// - Walking 1000 steps from 9:00 AM to 9:15 AM
/// - startTime: 9:00 AM, endTime: 9:15 AM, steps: 1000

struct StepsHandler: HealthKitQuantityHandler {
    // MARK: - HealthKitTypeHandler

    static var supportedType: HealthDataTypeDto {
        return .steps
    }

    static var category: HealthKitDataCategory {
        return .quantitySample
    }

    // MARK: - HealthKitSampleHandler

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        // Type guard: Verify this is a quantity sample
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected HKQuantitySample, got \(type(of: sample))"
            )
        }

        // Delegate to existing mapper extension
        // This mapper is already implemented in HealthRecordMappers.swift
        guard let dto = quantitySample.toStepRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to StepRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        // Type guard: Verify this is a StepRecordDto
        guard let stepDto = dto as? StepRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected StepRecordDto, got \(type(of: dto))"
            )
        }

        // Delegate to existing mapper extension
        // This mapper is already implemented in HealthRecordMappers.swift
        return try stepDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        // Steps use the stepCount quantity type
        return HKQuantityType.quantityType(forIdentifier: .stepCount)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        // Type guard: Verify this is a StepRecordDto
        guard let stepDto = dto as? StepRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected StepRecordDto, got \(type(of: dto))"
            )
        }

        // Interval records use endTime for pagination
        // This ensures records are ordered by when they completed
        return stepDto.endTime
    }

    // MARK: - HealthKitQuantityHandler (Aggregation Support)

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .sum:
            // Cumulative sum for total step count
            return .cumulativeSum
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for steps (cumulative data)",
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
                message: "Aggregation metric '\(metric)' not supported for steps",
                details: "Only 'sum' is supported"
            )
        }
        
        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for stepCount"
            )
        }
        
        let count = quantity.doubleValue(for: .count())
        return NumericDto(unit: .numeric, value: count)
    }
}
