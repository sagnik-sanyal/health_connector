import Flutter
import UIKit
import HealthKit

/**
 * Flutter plugin for accessing HealthKit on iOS devices.
 *
 * This plugin serves as the bridge between Flutter and the iOS HealthKit SDK,
 * providing access to health and fitness data stored on the device. It implements both
 * `FlutterPlugin` for lifecycle management and `HealthConnectorPlatformApi` for platform API communication.
 *
 * **Minimum iOS Version: 15.0**
 *
 * This plugin requires iOS 15.0+ for native Swift concurrency support. While Swift's async/await,
 * Task, and withCheckedThrowingContinuation features can be back-deployed to iOS 13.0 with Xcode 13.2+,
 * we've chosen iOS 15.0 as the minimum to ensure:
 * - Native Swift concurrency runtime without back-deployment shims
 * - Simpler deployment without reliance on compatibility layers
 * - Potentially smaller binary sizes
 *
 * **Note**: HealthKit APIs used (HKHealthStore, HKSampleQuery, etc.) have been available since iOS 8.0.
 * The iOS 15.0 requirement is a deliberate design choice for native concurrency support, not a HealthKit limitation.
 *
 * ## Threading
 *
 * All HealthKit operations are executed asynchronously using Swift's async/await to prevent
 * blocking the main thread. Results are delivered back to Flutter via completion handlers.
 *
 * - See Also:
 *   - `HealthConnectorPlatformApi`
 *   - `HealthConnectorClient`
 */
public class HealthConnectorHkIosPlugin: NSObject, FlutterPlugin, HealthConnectorPlatformApi {

    /**
     * Tag used for logging throughout the plugin.
     */
    private static let tag = "HealthConnectorHkIosPlugin"

    /**
     * Cached instance of the HealthKit client.
     * Created lazily on first use and reused for subsequent operations.
     * Cleared when the engine is detached.
     */
    private var healthClient: HealthConnectorClient?

    // MARK: - FlutterPlugin Lifecycle Methods

    /**
     * Registers the plugin with the Flutter engine.
     *
     * - Parameter registrar: Provides access to the Flutter engine and binary messenger
     */
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = HealthConnectorHkIosPlugin()
        HealthConnectorPlatformApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }

    // MARK: - HealthConnectorPlatformApi Implementation

    /**
     * Gets the current status of the HealthKit platform on the device.
     *
     * - Parameter completion: Called with a `Result` containing the platform status
     */
    public func getHealthPlatformStatus(completion: @escaping (Result<HealthPlatformStatusDto, Error>) -> Void) {
        let statusDto = HealthConnectorClient.getHealthPlatformStatus()
        completion(.success(statusDto))
    }

    /**
     * Requests permissions from the user.
     *
     * iOS implementation that auto-grants feature permissions since HealthKit doesn't
     * have a separate permission system for features.
     *
     * - Parameters:
     *   - request: Contains lists of health data permissions and feature permissions to request.
     *   - completion: Called with a `Result` containing the permission request results.
     *
     * - Throws: `HealthConnectorError.healthPlatformUnavailable` if HealthKit is unavailable
     * - Throws: `HealthConnectorError.unknown` for unexpected errors
     */
    public func requestPermissions(request: PermissionsRequestDto, completion: @escaping (Result<PermissionsRequestResponseDto, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                // Request health data permissions from HealthKit
                let healthDataResults = try await client.requestPermissions(healthDataPermissions: request.healthDataPermissions)

                // Construct the response
                let response = PermissionsRequestResponseDto(
                    healthDataPermissionResults: healthDataResults
                )

                completion(.success(response))

            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "requestPermissions",
                    phase: "failed",
                    message: "Failed to request Health Connect permissions",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "requestPermissions",
                    phase: "failed",
                    message: "Failed to request Health Connect permissions",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Reads a single health record by ID.
     *
     * - Parameters:
     *   - request: Contains the data type and record ID to read
     *   - completion: Called with a `Result` containing the read record response or nil if not found
     */
    public func readRecord(request: ReadRecordRequestDto, completion: @escaping (Result<ReadRecordResponseDto?, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                let result = try await client.readRecord(request: request)

                completion(.success(result))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "readRecord",
                    phase: "failed",
                    message: "Failed to read Health Connect record",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "readRecord",
                    phase: "failed",
                    message: "Failed to read Health Connect record",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Reads multiple health records within a time range.
     *
     * - Parameters:
     *   - request: Contains data type, time range, page size, and optional page token
     *   - completion: Called with a `Result` containing the read records response
     */
    public func readRecords(request: ReadRecordsRequestDto, completion: @escaping (Result<ReadRecordsResponseDto, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                let result = try await client.readRecords(request: request)

                completion(.success(result))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "readRecords",
                    phase: "failed",
                    message: "Failed to read Health Connect records",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "readRecords",
                    phase: "failed",
                    message: "Failed to read Health Connect records",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Writes a single health record.
     *
     * - Parameters:
     *   - request: Contains the data type and the typed record to write
     *   - completion: Called with a `Result` containing the write record response
     */
    public func writeRecord(request: WriteRecordRequestDto, completion: @escaping (Result<WriteRecordResponseDto, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                let result = try await client.writeRecord(request: request)

                completion(.success(result))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "writeRecord",
                    phase: "failed",
                    message: "Failed to write Health Connect record",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "writeRecord",
                    phase: "failed",
                    message: "Failed to write Health Connect record",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Writes multiple health records atomically.
     *
     * - Parameters:
     *   - request: Contains the data types and the list of typed records to write
     *   - completion: Called with a `Result` containing the write records response
     */
    public func writeRecords(request: WriteRecordsRequestDto, completion: @escaping (Result<WriteRecordsResponseDto, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                let result = try await client.writeRecords(request: request)

                completion(.success(result))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "writeRecords",
                    phase: "failed",
                    message: "Failed to write Health Connect records",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "writeRecords",
                    phase: "failed",
                    message: "Failed to write Health Connect records",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Updates a single health record using delete-then-insert pattern.
     *
     * - Parameters:
     *   - request: Contains the data type and the typed record to update
     *   - completion: Called with a `Result` containing the update record response
     */
    public func updateRecord(request: UpdateRecordRequestDto, completion: @escaping (Result<UpdateRecordResponseDto, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                let result = try await client.updateRecord(request: request)

                completion(.success(result))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "updateRecord",
                    phase: "failed",
                    message: "Failed to update Health Connect record",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "updateRecord",
                    phase: "failed",
                    message: "Failed to update Health Connect record",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Performs an aggregation query on health records.
     *
     * - Parameters:
     *   - request: Contains data type, aggregation metric, and time range
     *   - completion: Called with a `Result` containing the aggregation response
     */
    public func aggregate(request: AggregateRequestDto, completion: @escaping (Result<AggregateResponseDto, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                let result = try await client.aggregate(request: request)

                completion(.success(result))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "aggregate",
                    phase: "failed",
                    message: "Failed to aggregate Health Connect data",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "aggregate",
                    phase: "failed",
                    message: "Failed to aggregate Health Connect data",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Deletes health records by their IDs.
     *
     * Uses query-then-delete pattern since HealthKit doesn't support direct deletion by UUID.
     *
     * - Parameters:
     *   - request: Contains the data type and list of record IDs to delete
     *   - completion: Called with a `Result` indicating success or failure
     */
    public func deleteRecordsByIds(request: DeleteRecordsByIdsRequestDto, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                try await client.deleteRecordsByIds(request: request)

                completion(.success(()))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "deleteRecordsByIds",
                    phase: "failed",
                    message: "Failed to delete Health Connect records by IDs",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "deleteRecordsByIds",
                    phase: "failed",
                    message: "Failed to delete Health Connect records by IDs",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }

    /**
     * Deletes health records within a time range.
     *
     * - Parameters:
     *   - request: Contains the data type, start time, and end time
     *   - completion: Called with a `Result` indicating success or failure
     */
    public func deleteRecordsByTimeRange(request: DeleteRecordsByTimeRangeRequestDto, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                // Get or create the HealthKit client
                if healthClient == nil {
                    healthClient = try HealthConnectorClient.getOrCreate()
                }

                guard let client = healthClient else {
                    throw HealthConnectorErrors.healthPlatformUnavailable()
                }

                try await client.deleteRecordsByTimeRange(request: request)

                completion(.success(()))
            } catch let error as HealthConnectorError {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "deleteRecordsByTimeRange",
                    phase: "failed",
                    message: "Failed to delete Health Connect records by time range",
                    context: [
                        "error_code": String(describing: error.code),
                        "error_message": error.message ?? "no message"
                    ],
                    exception: error
                )
                completion(.failure(error))
            } catch {
                HealthConnectorLogger.error(
                    tag: HealthConnectorHkIosPlugin.tag,
                    operation: "deleteRecordsByTimeRange",
                    phase: "failed",
                    message: "Failed to delete Health Connect records by time range",
                    exception: error
                )
                let healthConnectorError = HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
                completion(.failure(healthConnectorError))
            }
        }
    }
}
