import Foundation
import HealthKit

/**
 * Extension to convert `AggregationMetricDto` to HealthKit aggregation options.
 *
 * Note: HealthKit uses different aggregation approaches than Android Health Connect.
 * This mapper adapts the DTO to HealthKit's query-based aggregation.
 */
extension AggregationMetricDto {
    /**
     * Gets the HealthKit statistics options for this aggregation metric.
     *
     * HealthKit uses `HKStatisticsOptions` for aggregation queries, which differ
     * from Android's direct metric constants.
     *
     * - Parameter dataType: The health data type for which to get aggregation options
     * - Returns: The appropriate `HKStatisticsOptions` for the aggregation metric.
     *            Returns empty options ([]) if the metric requires reading records instead.
     */
    func toHealthKitStatisticsOptions(dataType: HealthDataTypeDto) -> HKStatisticsOptions {
        switch dataType {
        case .steps:
            switch self {
            case .sum:
                return .cumulativeSum
            case .avg, .min, .max, .count:
                // These require reading individual records and calculating
                // HealthKit doesn't provide direct aggregation for these on steps
                return []
            }

        case .weight:
            switch self {
            case .avg:
                return .discreteAverage
            case .min:
                return .discreteMin
            case .max:
                return .discreteMax
            case .sum, .count:
                // SUM not meaningful for weight, COUNT requires reading records
                return []
            }
        }
    }

    /**
     * Validates if this aggregation metric is valid for the given data type.
     *
     * This matches the Android implementation which only supports metrics that can be
     * performed directly via the platform's aggregation API.
     *
     * - Parameter dataType: The health data type to validate against
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if the metric is invalid
     */
    func validateForDataType(_ dataType: HealthDataTypeDto) throws {
        switch dataType {
        case .steps:
            // Only SUM is supported for steps (matches Android Health Connect behavior)
            if self != .sum {
                let metricName = String(describing: self)
                throw HealthConnectorErrors.invalidArgument(
                    message: "\(metricName) not directly supported for steps in HealthKit",
                    details: "\(metricName) not directly supported for steps in HealthKit."
                )
            }
        case .weight:
            // Only AVG, MIN, MAX are supported for weight (matches Android Health Connect behavior)
            switch self {
            case .avg, .min, .max:
                break // These are supported
            case .sum, .count:
                let metricName = String(describing: self)
                throw HealthConnectorErrors.invalidArgument(
                    message: "\(metricName) not directly supported for weight in HealthKit",
                    details: "\(metricName) not directly supported for weight in HealthKit."
                )
            }
        }
    }
}

