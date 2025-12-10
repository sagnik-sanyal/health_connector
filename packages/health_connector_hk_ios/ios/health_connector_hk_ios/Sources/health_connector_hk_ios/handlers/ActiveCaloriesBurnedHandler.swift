import Foundation
import HealthKit

/// Handler for active calories burned data (interval quantity type)
///
/// **Data Type:** Active Energy Burned
/// **Record Pattern:** Interval (has startTime and endTime)
/// **Aggregation:** Sum only (cumulative calories)
/// **HealthKit Type:** HKQuantityTypeIdentifier.activeEnergyBurned
///
/// **Usage:**
/// - Reading: Retrieves active calories burned over time intervals
/// - Writing: Records active calories burned during activities
/// - Aggregating: Supports sum (total calories burned)
/// - Pagination: Uses endTime for cursor-based pagination
///
/// **Example:**
/// - Burning 150 kcal during a 30-minute run from 2:00 PM to 2:30 PM
/// - startTime: 2:00 PM, endTime: 2:30 PM, energy: 150 kcal
///
/// **Note:** Active calories exclude basal metabolic rate (BMR).
/// For total calories, use activeEnergyBurned + basalEnergyBurned.

struct ActiveCaloriesBurnedHandler: HealthKitQuantityHandler {
    static var supportedType: HealthDataTypeDto {
        .activeCaloriesBurned
    }
    static var category: HealthKitDataCategory {
        .quantitySample
    }

    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto {
        guard let quantitySample = sample as? HKQuantitySample else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected HKQuantitySample, got \(type(of: sample))")
        }
        guard let dto = quantitySample.toActiveCaloriesBurnedRecordDto() else {
            throw HealthConnectorErrors.invalidArgument(message: "Failed to convert HKQuantitySample to ActiveCaloriesBurnedRecordDto")
        }
        return dto
    }

    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample {
        guard let caloriesDto = dto as? ActiveCaloriesBurnedRecordDto else {
            throw HealthConnectorErrors.invalidArgument(
                message: "Expected ActiveCaloriesBurnedRecordDto, got \(type(of: dto))"
            )
        }
        return try caloriesDto.toHealthKit()
    }

    static func getSampleType() -> HKSampleType {
        return HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    }

    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64 {
        guard let caloriesDto = dto as? ActiveCaloriesBurnedRecordDto else {
            throw HealthConnectorErrors.invalidArgument(message: "Expected ActiveCaloriesBurnedRecordDto, got \(type(of: dto))")
        }
        return caloriesDto.endTime
    }

    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions {
        switch metric {
        case .sum:
            return .cumulativeSum
        case .avg, .min, .max, .count:
            throw HealthConnectorErrors.invalidArgument(
                message: "Aggregation metric '\(metric)' not supported for active calories (cumulative data)",
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
                message: "Aggregation metric '\(metric)' not supported for active calories",
                details: "Only 'sum' is supported"
            )
        }
        
        guard let quantity else {
            throw HealthConnectorErrors.invalidArgument(
                message: "No aggregation result for metric '\(metric)'",
                details: "Statistics returned nil for activeEnergyBurned"
            )
        }
        
        return quantity.toEnergyDto()
    }
}
