import Foundation
import HealthKit

// MARK: - Base Protocol

/// Base protocol for all health data type handlers
///
/// This protocol defines the minimal interface that all handlers must implement.
/// Specific handler types (sample, quantity, correlation, characteristic) extend this base.
///
/// **Compatibility:** iOS 15+
/// **Verified:** December 1, 2025

protocol HealthKitTypeHandler {
    /// The HealthDataTypeDto enum case this handler supports
    static var supportedType: HealthDataTypeDto { get }

    /// The HealthKit data category (determines API usage patterns)
    static var category: HealthKitDataCategory { get }
}

// MARK: - Sample-Based Handlers

/// Protocol for handlers that work with HKSample types
///
/// This includes quantity samples, category samples, correlations, and workouts.
/// All sample-based types can be created, read, updated, and deleted.
///
/// **Note:** Characteristics do NOT implement this protocol (they use direct API access)

protocol HealthKitSampleHandler: HealthKitTypeHandler {
    /// Convert HealthKit sample to Pigeon DTO
    ///
    /// - Parameter sample: The HKSample to convert
    /// - Returns: The corresponding HealthRecordDto
    /// - Throws: HealthConnectorError if conversion fails or type mismatch occurs
    ///
    /// **Implementation Note:** Always verify the sample type before conversion.
    /// Throw HealthConnectorErrors.invalidArgument for type mismatches.
    static func toDTO(_ sample: HKSample) throws -> HealthRecordDto

    /// Convert Pigeon DTO to HealthKit sample
    ///
    /// - Parameter dto: The HealthRecordDto to convert
    /// - Returns: The corresponding HKSample
    /// - Throws: HealthConnectorError if DTO is wrong type or conversion fails
    ///
    /// **Implementation Note:** Throw HealthConnectorErrors.invalidArgument if DTO type is wrong
    static func toHealthKit(_ dto: HealthRecordDto) throws -> HKSample

    /// Get the HKSampleType for queries
    ///
    /// - Returns: The HKSampleType used for this health data type
    ///
    /// **Example:**
    /// ```swift
    /// return HKQuantityType.quantityType(forIdentifier: .stepCount)!
    /// ```
    static func getSampleType() -> HKSampleType

    /// Extract timestamp from DTO for pagination
    ///
    /// For interval records (start/end time), return endTime.
    /// For instant records (single time), return time.
    ///
    /// - Parameter dto: The HealthRecordDto to extract timestamp from
    /// - Returns: Timestamp in milliseconds since epoch
    /// - Throws: HealthConnectorError if DTO type mismatch occurs
    ///
    /// **Implementation Note:** Throw HealthConnectorErrors.invalidArgument for type mismatches.
    /// **Used by:** readRecords() pagination logic to determine page tokens
    static func extractTimestamp(_ dto: HealthRecordDto) throws -> Int64
}

// MARK: - Quantity-Specific

/// Protocol for quantity types that support aggregation
///
/// Quantity types can be aggregated using HKStatisticsQuery.
/// Different quantity types support different aggregation metrics:
/// - Cumulative types (steps, distance): .sum
/// - Discrete types (weight, heart rate): .avg, .min, .max
///
/// **Examples:** Steps, weight, heart rate, distance, calories

protocol HealthKitQuantityHandler: HealthKitSampleHandler {
    /// Convert aggregation metric to HKStatisticsOptions
    ///
    /// - Parameter metric: The aggregation metric requested
    /// - Returns: Corresponding HKStatisticsOptions for the query
    /// - Throws: HealthConnectorError if the metric is not supported for this data type
    ///
    /// **Mapping:**
    /// - `.sum` → `.cumulativeSum`
    /// - `.avg` → `.discreteAverage`
    /// - `.min` → `.discreteMin`
    /// - `.max` → `.discreteMax`
    ///
    /// **Implementation Note:** Throw `HealthConnectorErrors.invalidArgument` for unsupported metrics
    /// instead of returning empty options.
    static func toStatisticsOptions(_ metric: AggregationMetricDto) throws -> HKStatisticsOptions
    
    /// Extract aggregated value from HKStatistics
    ///
    /// - Parameters:
    ///   - statistics: The HKStatistics result from the query
    ///   - metric: The aggregation metric requested
    /// - Returns: The measurement unit DTO (MassDto, LengthDto, NumericDto, etc.)
    /// - Throws: HealthConnectorError.invalidArgument if metric is unsupported or result is null
    static func extractAggregateValue(
        from statistics: HKStatistics,
        metric: AggregationMetricDto
    ) throws -> MeasurementUnitDto
}

// MARK: - Correlation-Specific

/// Protocol for correlation types that need custom delete logic
///
/// Correlations contain multiple samples that must be deleted together.
/// **Critical:** Deleting a correlation does NOT automatically delete contained samples.
/// Each sample must be deleted individually.
///
/// **Reference:** Apple HealthKit documentation on HKCorrelation deletion
/// **Examples:** Blood pressure (systolic + diastolic), food (nutrients)

protocol HealthKitCorrelationHandler: HealthKitSampleHandler {
    /// Delete correlation and all contained samples
    ///
    /// - Parameters:
    ///   - correlation: The HKCorrelation object to delete
    ///   - store: The HealthKit store
    ///
    /// - Throws: HealthConnectorError if deletion fails
    ///
    /// **Important:** Must delete both:
    /// 1. The correlation object itself
    /// 2. All objects in `correlation.objects`
    ///
    /// **Implementation Pattern:**
    /// ```swift
    /// try await store.delete(correlation)  // Delete correlation metadata
    /// for sample in correlation.objects {
    ///     try await store.delete(sample)   // Delete each contained sample
    /// }
    /// ```
    static func deleteCorrelation(_ correlation: HKCorrelation, from store: HKHealthStore) async throws
}

// MARK: - Characteristic-Specific

/// Protocol for characteristic types (read-only, direct API)
///
/// Characteristics are NOT samples - they have no UUID, timestamps, or metadata.
/// They are accessed directly via HKHealthStore properties, not queries.
///
/// **Examples:** Biological sex, date of birth, blood type, Fitzpatrick skin type
///
/// **Key Differences from Samples:**
/// - No write support (read-only)
/// - No delete support (permanent)
/// - No query support (direct property access)
/// - No time range filtering

protocol HealthKitCharacteristicHandler: HealthKitTypeHandler {
    /// Read characteristic value directly from store
    ///
    /// - Parameter store: The HealthKit store
    /// - Returns: The characteristic data as a HealthRecordDto
    /// - Throws: HealthConnectorError if reading fails
    ///
    /// **Implementation Note:** Use direct HKHealthStore methods like:
    /// - `store.biologicalSex()`
    /// - `store.dateOfBirthComponents()`
    /// - `store.bloodType()`
    ///
    /// **No query needed** - characteristics use synchronous property access.
    static func readCharacteristic(from store: HKHealthStore) throws -> HealthRecordDto

    // Note: No write method - characteristics are read-only
    // Note: No delete method - characteristics cannot be deleted
    // Note: No query method - use direct store property access
}
