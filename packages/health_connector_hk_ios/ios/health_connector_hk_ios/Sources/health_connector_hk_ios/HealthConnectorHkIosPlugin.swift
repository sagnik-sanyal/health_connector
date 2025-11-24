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
 * ## Threading
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
     *
     * Note: Stored as Any? to avoid @available restrictions. Cast to HealthConnectorClient when using.
     */
    private var healthClient: Any?

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
        NSLog("\(HealthConnectorHkIosPlugin.tag): Getting HealthKit status...")

        if #available(iOS 15.0, *) {
            let statusDto = HealthConnectorClient.getHealthPlatformStatus()
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit status DTO: \(statusDto)")
            completion(.success(statusDto))
        } else {
            // iOS version is below 15.0, return not available status
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            completion(.success(.notAvailable))
        }
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog(
                        "\(HealthConnectorHkIosPlugin.tag): Requesting permission DTOs for: \(request.healthDataPermissions.map { "\($0.accessType)_\($0.healthDataType)" }.joined(separator: ", "))..."
                    )

                    // Request health data permissions from HealthKit
                    let healthDataResults = try await client.requestPermissions(healthDataPermissions: request.healthDataPermissions)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Health data permission request result DTOs: \(healthDataResults)")

                    // Construct the response
                    let response = PermissionsRequestResponseDto(
                        healthDataPermissionResults: healthDataResults
                    )

                    completion(.success(response))

                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error requesting permissions: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error requesting permissions: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog("\(HealthConnectorHkIosPlugin.tag): Reading single record: dataType=\(request.dataType), id=\(request.recordId)")

                    let result = try await client.readRecord(request: request)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully read record")

                    completion(.success(result))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error reading record: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error reading record: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog(
                        "\(HealthConnectorHkIosPlugin.tag): Reading records: dataType=\(request.dataType), startTime=\(request.startTime), endTime=\(request.endTime), pageSize=\(request.pageSize)"
                    )

                    let result = try await client.readRecords(request: request)
                    let recordCount = result.stepsRecords?.count ?? result.weightRecords?.count ?? 0
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully read \(recordCount) records")

                    completion(.success(result))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error reading records: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error reading records: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog("\(HealthConnectorHkIosPlugin.tag): Writing single record: dataType=\(request.dataType)")

                    let result = try await client.writeRecord(request: request)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully wrote record with ID: \(result.recordId)")

                    completion(.success(result))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error writing record: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error writing record: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    // Calculate total record count for logging
                    let recordCount = (request.stepsRecords?.count ?? 0) + (request.weightRecords?.count ?? 0)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Writing \(recordCount) records: dataTypes=\(request.dataTypes)")

                    let result = try await client.writeRecords(request: request)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully wrote \(result.recordIds.count) records")

                    completion(.success(result))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error writing records: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error writing records: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog("\(HealthConnectorHkIosPlugin.tag): Updating single record: dataType=\(request.dataType)")

                    let result = try await client.updateRecord(request: request)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully updated record with ID: \(result.recordId)")

                    completion(.success(result))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error updating record: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error updating record: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog(
                        "\(HealthConnectorHkIosPlugin.tag): Aggregating records: dataType=\(request.dataType), metric=\(request.aggregationMetric), startTime=\(request.startTime), endTime=\(request.endTime)"
                    )

                    let result = try await client.aggregate(request: request)
                    NSLog(
                        "\(HealthConnectorHkIosPlugin.tag): Successfully aggregated records"
                    )

                    completion(.success(result))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error aggregating records: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error aggregating records: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog("\(HealthConnectorHkIosPlugin.tag): Deleting records by IDs: dataType=\(request.dataType), count=\(request.recordIds.count)")

                    try await client.deleteRecordsByIds(request: request)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully deleted records by IDs")

                    completion(.success(()))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error deleting records by IDs: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error deleting records by IDs: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
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
        if #available(iOS 15.0, *) {
            Task {
                do {
                    // Get or create the HealthKit client
                    if healthClient == nil {
                        healthClient = try HealthConnectorClient.getOrCreate()
                    }

                    guard let client = healthClient as? HealthConnectorClient else {
                        throw HealthConnectorErrors.healthPlatformUnavailable()
                    }

                    NSLog("\(HealthConnectorHkIosPlugin.tag): Deleting records by time range: dataType=\(request.dataType), startTime=\(request.startTime), endTime=\(request.endTime)")

                    try await client.deleteRecordsByTimeRange(request: request)
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Successfully deleted records by time range")

                    completion(.success(()))
                } catch let error as HealthConnectorError {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Error deleting records by time range: \(error.code) - \(error.message ?? "no message")")
                    completion(.failure(error))
                } catch {
                    NSLog("\(HealthConnectorHkIosPlugin.tag): Unknown error deleting records by time range: \(error.localizedDescription)")
                    let healthConnectorError = HealthConnectorErrors.unknown(
                        message: error.localizedDescription,
                        details: error.localizedDescription
                    )
                    completion(.failure(healthConnectorError))
                }
            }
        } else {
            // iOS version is below 15.0
            NSLog("\(HealthConnectorHkIosPlugin.tag): HealthKit requires iOS 15.0+, current version is not supported")
            let error = HealthConnectorErrors.healthPlatformUnavailable(
                message: "HealthKit requires iOS 15.0 or later. Current iOS version is not supported.",
                details: nil
            )
            completion(.failure(error))
        }
    }
}
