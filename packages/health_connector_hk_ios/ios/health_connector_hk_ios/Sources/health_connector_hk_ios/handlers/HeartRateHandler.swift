import Foundation
import HealthKit

/// Handler for heart rate measurement data (instant quantity type)
///
/// **Data Type:** Heart Rate Measurement
/// **Record Pattern:** Instant (single timestamp, no duration)
/// **Aggregation:** Average, Min, Max (discrete values)
/// **HealthKit Type:** HKQuantityTypeIdentifier.heartRate
///
/// **Usage:**
/// - Reading: Retrieves heart rate measurements at specific points in time
/// - Writing: Records heart rate measurements (beats per minute)
/// - Aggregating: Supports avg (resting heart rate), min (lowest BPM), max (peak BPM)
/// - Pagination: Uses time (not endTime) for cursor-based pagination
///
/// **Example:**
/// - Heart rate measurement at 10:30 AM: 72 BPM
/// - time: 10:30 AM (single timestamp)
///
/// **Key Difference from Interval Records:**
/// - Instant records have same startDate and endDate
/// - Uses `.time` field for pagination (not `.endTime`)
/// - Aggregation uses discrete statistics (not cumulative)
///
/// **Note:** This is different from Heart Rate Variability (HRV) or Resting Heart Rate,
/// which are separate HealthKit data types.

struct HeartRateHandler: HealthKitQuantityHandler {
    // MARK: - HealthKitTypeHandler

    static var supportedType: HealthDataTypeDto {
        return .heartRateMeasurementRecord
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
        guard let dto = quantitySample.toHeartRateMeasurementRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to HeartRateMeasurementRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        // Type guard: Verify this is a HeartRateMeasurementRecordDto
        guard let heartRateDto = dto as? HeartRateMeasurementRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected HeartRateMeasurementRecordDto, got \(type(of: dto))"
            )
        }

        // Delegate to existing mapper extension
        // This mapper is already implemented in HealthRecordMappers.swift
        return try heartRateDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        // Heart rate uses the heartRate quantity type
        // Unit: count/min (beats per minute)
        return HKQuantityType.quantityType(forIdentifier: .heartRate)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        // Type guard: Verify this is a HeartRateMeasurementRecordDto
        guard let heartRateDto = dto as? HeartRateMeasurementRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected HeartRateMeasurementRecordDto, got \(type(of: dto))"
            )
        }

        // Instant records use 'time' field for pagination (NOT endTime!)
        // This is the key difference from interval records like Steps
        return heartRateDto.time
    }

    // MARK: - HealthKitQuantityHandler (Aggregation Support)

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .avg:
            // Discrete average for average heart rate
            return .discreteAverage
        case .min:
            // Discrete minimum for lowest heart rate
            return .discreteMin
        case .max:
            // Discrete maximum for highest/peak heart rate
            return .discreteMax
        case .sum, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for heart rate (discrete data)",
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
                message: "Aggregation metric '\(metric)' not supported for heart rate",
                details: "Supported metrics: avg, min, max"
            )
        }

        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for heartRate"
            )
        }

        let bpm = quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
        return NumericDto(unit: .numeric, value: bpm)
    }
}
