import Foundation
import HealthKit

/**
 * Internal client wrapper for the HealthKit SDK.
 *
 * This class encapsulates all interactions with the HealthKit SDK, providing a clean API for the Flutter plugin layer.
 * It mirrors the Android `HealthConnectorClient` implementation while adapting to HealthKit's specific behavior.
 *
 * @property store The underlying HealthKit store instance
 */
internal class HealthConnectorClient {

    /**
     * Tag used for logging throughout the client.
     */
    private static let tag = "HealthConnectorClient"

    /**
     * The underlying HealthKit store instance.
     */
    private let store: HKHealthStore

    /**
     * Private initializer to prevent external instantiation.
     *
     * - Parameter store: The HealthKit store instance.
     */
    private init(store: HKHealthStore) {
        self.store = store
    }

    /**
     * Maps HealthKit errors to HealthConnectorError instances.
     *
     * This helper function converts HKError codes to cross-platform error codes:
     * - `errorAuthorizationDenied` → `SECURITY_ERROR`
     * - `errorInvalidArgument` → `INVALID_ARGUMENT`
     * - `errorHealthDataUnavailable`, `errorDatabaseInaccessible` → `HEALTH_PLATFORM_UNAVAILABLE`
     * - All other errors → `UNKNOWN`
     *
     * - Parameter error: The NSError to map
     * - Returns: A HealthConnectorError with the appropriate error code
     */
    private static func mapHealthKitError(_ error: NSError) -> HealthConnectorError {
        // Check if this is a HealthKit error by checking the domain
        if error.domain == HKError.errorDomain {
            let hkErrorCode = HKError.Code(rawValue: error.code)
            switch hkErrorCode {
            case .errorAuthorizationDenied:
                return HealthConnectorErrors.securityError(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
            case .errorInvalidArgument:
                return HealthConnectorErrors.invalidArgument(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
            case .errorHealthDataUnavailable, .errorDatabaseInaccessible:
                return HealthConnectorErrors.healthPlatformUnavailable(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
            default:
                return HealthConnectorErrors.unknown(
                    message: error.localizedDescription,
                    details: error.localizedDescription
                )
            }
        } else {
            return HealthConnectorErrors.unknown(
                message: error.localizedDescription,
                details: error.localizedDescription
            )
        }
    }

    /**
     * Gets or creates a `HealthConnectorClient` instance.
     *
     * This method wraps the HealthKit store creation and handles common initialization errors.
     * The client instance is created using `HKHealthStore()` which returns a new instance.
     *
     * - Returns: A new `HealthConnectorClient` instance wrapping the HealthKit store
     *
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` when:
     *          - HealthKit is not available on the device (e.g., iPad without health capabilities)
     *          - The device is in a restricted mode
     */
    static func getOrCreate() throws -> HealthConnectorClient {
        guard HKHealthStore.isHealthDataAvailable() else {
            HealthConnectorLogger.error(
                tag: tag,
                operation: "getOrCreate",
                phase: "failed",
                message: "HealthKit is not available on this device"
            )
            throw HealthConnectorErrors.healthPlatformUnavailable(
                message: nil,
                details: nil
            )
        }

        let store = HKHealthStore()
        return HealthConnectorClient(store: store)
    }

    /**
     * Gets the current status of the HealthKit platform on the device.
     *
     * - Returns: The current platform status as a `HealthPlatformStatusDto`
     */
    static func getHealthPlatformStatus() -> HealthPlatformStatusDto {
        HealthConnectorLogger.debug(
            tag: tag,
            operation: "getHealthPlatformStatus",
            phase: "entry",
            message: "Getting HealthKit availability status"
        )

        let isAvailable = HKHealthStore.isHealthDataAvailable()
        
        let statusDto = HealthPlatformStatusDto.fromHealthKitAvailability(isAvailable)
        HealthConnectorLogger.info(
            tag: tag,
            operation: "getHealthPlatformStatus",
            phase: "completed",
            message: "HealthKit platform status retrieved",
            context: [
                "isAvailable": isAvailable,
                "statusDto": statusDto
            ]
        )

        return statusDto
    }

    /**
     * Requests the specified health data permissions from the user.
     *
     * Converts between Pigeon DTOs and HealthKit types, handles the authorization request,
     * and returns a detailed result for each requested permission.
     *
     * - Parameters:
     *   - healthDataPermissions: List of health data permissions to request.
     *
     * - Returns: A list of `HealthDataPermissionRequestResultDto` containing the status for each requested permission.
     *
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if invalid permission parameters are provided
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit is unavailable
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func requestPermissions(healthDataPermissions: [HealthDataPermissionDto]) async throws -> [HealthDataPermissionRequestResultDto] {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "requestPermissions",
                phase: "entry",
                message: "Requesting Health Connect permissions",
                context: [
                    "requested_health_data_permissions": healthDataPermissions
                ]
            )

            // Separate permissions into read and write sets
            var typesToRead = Set<HKObjectType>()
            var typesToWrite = Set<HKSampleType>()

            for permission in healthDataPermissions {
                let objectType = permission.toHealthKitObjectType()

                switch permission.accessType {
                case .read:
                    typesToRead.insert(objectType)
                case .write:
                    if let sampleType = objectType as? HKSampleType {
                        typesToWrite.insert(sampleType)
                    }
                }
            }

            // Request authorization from HealthKit
            try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)

            // Create permission request results by checking authorization status
            let results = healthDataPermissions.map { permissionDto -> HealthDataPermissionRequestResultDto in
                let objectType = permissionDto.toHealthKitObjectType()
                let status: PermissionStatusDto

                switch permissionDto.accessType {
                case .read:
                    // HealthKit never reveals read permission status for privacy reasons
                    status = .unknown

                case .write:
                    if let sampleType = objectType as? HKSampleType {
                        let authStatus = store.authorizationStatus(for: sampleType)
                        switch authStatus {
                        case .sharingAuthorized:
                            status = .granted
                        case .sharingDenied:
                            status = .denied
                        case .notDetermined:
                            status = .unknown
                        @unknown default:
                            status = .unknown
                        }
                    } else {
                        status = .unknown
                    }
                }

                return HealthDataPermissionRequestResultDto(permission: permissionDto, status: status)
            }

            HealthConnectorLogger.info(
                tag: HealthConnectorClient.tag,
                operation: "requestPermissions",
                phase: "completed",
                message: "Health Connect permissions requested successfully",
                context: [
                    "granted_health_data_permissions": results
                ]
            )

            return results

        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "requestPermissions",
                phase: "failed",
                message: "Failed to request Health Connect permissions",
                context: [
                    "requested_permissions": healthDataPermissions
                ],
                exception: error
            )
            // Create new error with enhanced context
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(healthDataPermissions): \(baseError.message ?? "Unknown error")",
                details: baseError.details
            )
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "requestPermissions",
                phase: "failed",
                message: "Failed to request Health Connect permissions",
                context: [
                    "requested_permissions": healthDataPermissions
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(healthDataPermissions): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Reads a single health record by ID.
     *
     * - Parameter request: Contains the data type and record ID to read
     * - Returns: ReadRecordResponseDto with the record populated, or nil if not found
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if the record ID format is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func readRecord(request: ReadRecordRequestDto) async throws -> ReadRecordResponseDto? {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "readRecord",
                phase: "entry",
                message: "Reading Health Connect record",
                context: [
                    "request": request
                ]
            )

            // Convert data type to HealthKit quantity type
            let quantityType = request.dataType.toHealthKitQuantityType()
            
            // Create UUID from record ID string
            guard let recordUUID = UUID(uuidString: request.recordId) else {
                HealthConnectorLogger.error(
                    tag: HealthConnectorClient.tag,
                    operation: "readRecord",
                    phase: "failed",
                    message: "Invalid record ID format",
                    context: [
                        "dataType": String(describing: request.dataType),
                        "recordId": request.recordId
                    ]
                )
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid record ID format: \(request.recordId)",
                    details: "Record ID must be a valid UUID string"
                )
            }

            // Query for the specific sample by UUID
            let predicate = HKQuery.predicateForObject(with: recordUUID)

            // Use async continuation to bridge the callback-based API
            let responseDto = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ReadRecordResponseDto?, Error>) in
                let query = HKSampleQuery(
                    sampleType: quantityType,
                    predicate: predicate,
                    limit: 1,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let sample = samples?.first as? HKQuantitySample else {
                        continuation.resume(returning: nil)
                        return
                    }

                    // Convert SDK sample to DTO using typed mappers
                    let recordDto: HealthRecordDto?
                    switch request.dataType {
                    case .activeCaloriesBurned:
                        recordDto = sample.toActiveCaloriesBurnedRecordDto()
                    case .distance:
                        recordDto = sample.toDistanceRecordDto()
                    case .floorsClimbed:
                        recordDto = sample.toFloorsClimbedRecordDto()
                    case .steps:
                        recordDto = sample.toStepRecordDto()
                    case .weight:
                        recordDto = sample.toWeightRecordDto()
                    case .height:
                        recordDto = sample.toHeightRecordDto()
                    case .hydration:
                        recordDto = sample.toHydrationRecordDto()
                    case .leanBodyMass:
                        recordDto = sample.toLeanBodyMassRecordDto()
                    case .bodyFatPercentage:
                        recordDto = sample.toBodyFatPercentageRecordDto()
                    case .bodyTemperature:
                        recordDto = sample.toBodyTemperatureRecordDto()
                    case .wheelchairPushes:
                        recordDto = sample.toWheelchairPushesRecordDto()
                    case .heartRateMeasurementRecord:
                        recordDto = sample.toHeartRateMeasurementRecordDto()
                    }
                    
                    let responseDto: ReadRecordResponseDto? = recordDto.map { ReadRecordResponseDto(record: $0) }

                    continuation.resume(returning: responseDto)
                }

                self.store.execute(query)
            }

            HealthConnectorLogger.info(
                tag: HealthConnectorClient.tag,
                operation: "readRecord",
                phase: "completed",
                message: "Health Connect record read successfully",
                context: [
                    "request": request,
                    "response": responseDto
                ]
            )

            return responseDto
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "readRecord",
                phase: "failed",
                message: "Failed to read Health Connect record",
                context: [
                    "request": request
                ],
                exception: error
            )
            // Create new error with enhanced context, preserving the error code
            throw HealthConnectorError(
                code: baseError.code,
                message: "Failed to process \(request): \(baseError.message ?? "Unknown error")",
                details: baseError.details
            )
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "readRecord",
                phase: "failed",
                message: "Failed to read Health Connect record",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Reads multiple health records within a time range (paginated).
     *
     * ## Pagination Strategy
     *
     * HealthKit doesn't provide native pagination tokens, so this method implements
     * cursor-based pagination using timestamps. To correctly determine if more pages exist,
     * this method uses an "over-fetch" strategy:
     *
     * 1. **Query pageSize + 1 records**: The method queries `pageSize + 1` records from HealthKit
     *    instead of exactly `pageSize`. This extra record acts as a "lookahead" to determine
     *    if more data exists beyond the current page.
     *
     * 2. **Detect last page**: After receiving results:
     *    - If `pageSize + 1` records are returned → more pages exist
     *    - If fewer than `pageSize + 1` records are returned → this is the last page
     *
     * 3. **Remove extra record**: If more pages exist, the last record is removed from the
     *    response before returning to the caller. The caller always receives exactly `pageSize`
     *    records (or fewer on the last page).
     *
     * 4. **Generate nextPageToken**: When more pages exist, `nextPageToken` is generated from
     *    the timestamp of the last record being returned (not the removed record). Subsequent
     *    requests use this token to resume pagination from the correct position.
     *
     * **Why this approach?**
     *
     * Without querying `pageSize + 1`, when HealthKit returns exactly `pageSize` records,
     * the method cannot distinguish between:
     * - "This is exactly the last page" (no more records exist)
     * - "More records exist but weren't returned yet" (another page is needed)
     *
     * The extra record eliminates this ambiguity and ensures the last page never incorrectly
     * includes a `nextPageToken` that leads to empty results.
     *
     * - Parameter request: Contains data type, time range, page size, optional page token,
     *                     and optional data origin package names for filtering
     * - Returns: ReadRecordsResponseDto with the records list populated and optional next page token.
     *            The list will contain at most `pageSize` records. `nextPageToken` is nil when no more pages exist.
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if time range or page size is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func readRecords(request: ReadRecordsRequestDto) async throws -> ReadRecordsResponseDto {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "readRecords",
                phase: "entry",
                message: "Reading Health Connect records",
                context: [
                    "request": request
                ]
            )

            // Validate time range
            if request.startTime >= request.endTime {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid time range: startTime must be before endTime",
                    details: "startTime=\(request.startTime), endTime=\(request.endTime)"
                )
            }

            // Parse pageToken if present and adjust startTime for pagination
            var effectiveStartTime = request.startTime
            if let pageToken = request.pageToken, !pageToken.isEmpty {
                // Parse pageToken as timestamp (milliseconds since epoch)
                if let tokenTimestamp = Int64(pageToken) {
                    // Use tokenTimestamp + 1ms as new startTime (exclusive to avoid duplicates)
                    effectiveStartTime = tokenTimestamp + 1
                    
                    // Validate that adjusted startTime is still before endTime
                    if effectiveStartTime >= request.endTime {
                        // Invalid pagination token, return empty result
                        HealthConnectorLogger.warning(
                            tag: HealthConnectorClient.tag,
                            operation: "readRecords",
                            phase: "completed",
                            message: "Invalid pageToken: adjusted startTime >= endTime",
                            context: [
                                "adjustedStartTime": effectiveStartTime,
                                "endTime": request.endTime
                            ]
                        )
                        return createEmptyResponse(for: request.dataType)
                    }
                    
                    HealthConnectorLogger.debug(
                        tag: HealthConnectorClient.tag,
                        operation: "readRecords",
                        phase: "pagination",
                        message: "Using pageToken for pagination",
                        context: [
                            "originalStartTime": request.startTime,
                            "adjustedStartTime": effectiveStartTime
                        ]
                    )
                } else {
                    // Invalid pageToken format, log warning but continue with original startTime
                    HealthConnectorLogger.warning(
                        tag: HealthConnectorClient.tag,
                        operation: "readRecords",
                        phase: "pagination",
                        message: "Invalid pageToken format, using original startTime",
                        context: [
                            "pageToken": pageToken
                        ]
                    )
                }
            }

            // Convert data type to HealthKit quantity type
            let quantityType = request.dataType.toHealthKitQuantityType()

            // Create time range predicate using effective startTime
            let startDate = Date(timeIntervalSince1970: TimeInterval(effectiveStartTime) / 1000.0)
            let endDate = Date(timeIntervalSince1970: TimeInterval(request.endTime) / 1000.0)
            let timePredicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: .strictStartDate
            )

            // Create compound predicate for data origin filtering if needed
            let predicate: NSPredicate
            if !request.dataOriginPackageNames.isEmpty {
                // Query for sources to get HKSource objects from bundle identifiers
                let sources = try await querySources(for: quantityType, bundleIdentifiers: request.dataOriginPackageNames)
                
                if sources.isEmpty {
                    // No sources found for the given bundle identifiers, return empty result
                    HealthConnectorLogger.warning(
                        tag: HealthConnectorClient.tag,
                        operation: "readRecords",
                        phase: "completed",
                        message: "No sources found for bundle identifiers",
                        context: [
                            "bundleIdentifiers": request.dataOriginPackageNames
                        ]
                    )
                    return createEmptyResponse(for: request.dataType)
                }
                
                // Create individual predicates for each source
                let sourcePredicates = sources.map { source in
                    HKQuery.predicateForObjects(from: source)
                }
                
                // Combine source predicates with OR logic
                let sourcePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: sourcePredicates)
                
                // Combine source and time predicates with AND logic
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sourcePredicate, timePredicate])
            } else {
                // No source filtering, use only time predicate
                predicate = timePredicate
            }

            // Use async continuation to bridge the callback-based API
            let responseDto = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ReadRecordsResponseDto, Error>) in
                // Query pageSize + 1 records to determine if more pages exist.
                // 
                // Rationale: HealthKit doesn't provide a way to check if more records exist beyond
                // the current page. By querying one extra record, we can distinguish between:
                // - Exactly pageSize records returned → last page (no more data)
                // - pageSize + 1 records returned → more pages exist
                //
                // The extra record will be removed before returning results to the caller,
                // ensuring they always receive at most pageSize records.
                let query = HKSampleQuery(
                    sampleType: quantityType,
                    predicate: predicate,
                    limit: Int(request.pageSize) + 1,
                    sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
                ) { _, samples, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to read records: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    let samples = samples ?? []

                    // Convert SDK samples to DTOs using typed mappers
                    let responseDto: ReadRecordsResponseDto
                    switch request.dataType {
                    case .activeCaloriesBurned:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toActiveCaloriesBurnedRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.endTime }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .distance:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toDistanceRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.endTime }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .floorsClimbed:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toFloorsClimbedRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.endTime }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .steps:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toStepRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.endTime }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .weight:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toWeightRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.time }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .height:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toHeightRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.time }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .hydration:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toHydrationRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.startTime }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .leanBodyMass:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toLeanBodyMassRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.time }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .bodyFatPercentage:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toBodyFatPercentageRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.time }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .bodyTemperature:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toBodyTemperatureRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.time }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .wheelchairPushes:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toWheelchairPushesRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.endTime }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })

                    case .heartRateMeasurementRecord:
                        let typedRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toHeartRateMeasurementRecordDto() }
                        let (trimmedRecords, nextPageToken) = self.applyPagination(
                            records: typedRecords,
                            pageSize: request.pageSize,
                            timestampExtractor: { $0.time }
                        )
                        responseDto = ReadRecordsResponseDto(nextPageToken: nextPageToken, records: trimmedRecords.map { $0 as HealthRecordDto })
                    }

                    continuation.resume(returning: responseDto)
                }

                self.store.execute(query)
            }
            
            HealthConnectorLogger.info(
                tag: HealthConnectorClient.tag,
                operation: "readRecords",
                phase: "completed",
                message: "Health Connect records read successfully",
                context: [
                    "request": request,
                    "response": responseDto
                ]
            )
            
            return responseDto
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "readRecords",
                phase: "failed",
                message: "Failed to read Health Connect records",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "readRecords",
                phase: "failed",
                message: "Failed to read Health Connect records",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Applies pagination logic to records array.
     *
     * This helper implements the "over-fetch" pagination strategy:
     *
     * - **Input**: Records array that may contain `pageSize + 1` items (due to querying one extra)
     * - **Output**: Exactly `pageSize` records (or fewer if last page) with optional `nextPageToken`
     *
     * **Why remove the last record?**
     *
     * When we query `pageSize + 1` records and receive that many, it means more data exists.
     * However, we must return exactly `pageSize` records to the caller. The extra (last) record
     * was only used as a "lookahead" indicator. We remove it and generate `nextPageToken` from
     * the actual last record being returned, so the next page starts from the correct position.
     *
     * If we receive `pageSize` or fewer records, all records are returned and no `nextPageToken`
     * is generated, indicating this is the last page.
     *
     * - Parameters:
     *   - records: Array of records (may contain pageSize + 1 items as a result of over-fetching)
     *   - pageSize: Requested page size (the maximum number of records to return)
     *   - timestampExtractor: Closure to extract timestamp from record for pagination token
     * - Returns: Tuple of (trimmed records array with at most pageSize items, optional nextPageToken)
     */
    private func applyPagination<T>(
        records: [T],
        pageSize: Int64,
        timestampExtractor: (T) -> Int64
    ) -> (records: [T], nextPageToken: String?) {
        var mutableRecords = records
        let nextPageToken: String?
        
        if mutableRecords.count > pageSize {
            // More pages exist: we received pageSize + 1 records, confirming there's more data.
            // Remove the extra record that was only used to detect if more pages exist.
            // This ensures we return exactly pageSize records to the caller.
            mutableRecords.removeLast()
            // Generate nextPageToken from the last record we're actually returning (not the removed one).
            // This ensures the next page starts from the correct position.
            nextPageToken = String(timestampExtractor(mutableRecords.last!))
        } else {
            // This is the last page: we received pageSize or fewer records, meaning no more data exists.
            // Return all records as-is and indicate no more pages with nil nextPageToken.
            nextPageToken = nil
        }
        
        return (mutableRecords, nextPageToken)
    }


    /**
     * Queries HealthKit for sources matching the given bundle identifiers.
     *
     * This helper method queries a sample of records for a given sample type to
     * collect HKSource objects, then filters them by bundle identifier. This is
     * necessary because HealthKit doesn't provide a direct API to get sources by
     * bundle identifier - sources must be obtained from existing samples.
     *
     * To improve efficiency, we query a reasonable number of samples (up to 1000)
     * to collect unique sources. If all requested bundle identifiers are found
     * before reaching the limit, we can return early.
     *
     * - Parameters:
     *   - sampleType: The HealthKit sample type to query sources for
     *   - bundleIdentifiers: List of bundle identifiers to filter sources by
     * - Returns: Set of HKSource objects matching the bundle identifiers
     * - Throws: Errors from HealthKit queries
     */
    private func querySources(for sampleType: HKSampleType, bundleIdentifiers: [String]) async throws -> Set<HKSource> {
        return try await withCheckedThrowingContinuation { continuation in
            // Query a sample of records to collect sources
            // Use a reasonable limit to balance between completeness and performance
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: nil,
                limit: 1000, // Query up to 1000 samples to find sources
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                // Extract unique sources that match the bundle identifiers
                let matchingSources = Set((samples ?? [])
                    .compactMap { $0.sourceRevision.source }
                    .filter { bundleIdentifiers.contains($0.bundleIdentifier) })
                
                continuation.resume(returning: matchingSources)
            }
            
            self.store.execute(query)
        }
    }

    /**
     * Creates an empty response DTO for the given data type.
     *
     * - Parameter dataType: The data type for the empty response
     * - Returns: ReadRecordsResponseDto with empty records list
     */
    private func createEmptyResponse(for dataType: HealthDataTypeDto) -> ReadRecordsResponseDto {
        return ReadRecordsResponseDto(nextPageToken: nil, records: [])
    }

    // ==================== WRITE OPERATIONS ====================

    /**
     * Writes a single health record.
     *
     * - Parameter request: Contains the health record to write
     * - Returns: WriteRecordResponseDto containing the platform-assigned record ID
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if record data is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func writeRecord(request: WriteRecordRequestDto) async throws -> WriteRecordResponseDto {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "writeRecord",
                phase: "entry",
                message: "Writing Health Connect record",
                context: [
                    "request": request
                ]
            )

            // Extract record from request and convert to HealthKit sample using pattern matching
            let sample: HKSample
            switch request.record {
            case let record as ActiveCaloriesBurnedRecordDto:
                sample = try record.toHealthKit()
            case let record as DistanceRecordDto:
                sample = try record.toHealthKit()
            case let record as FloorsClimbedRecordDto:
                sample = try record.toHealthKit()
            case let record as StepRecordDto:
                sample = try record.toHealthKit()
            case let record as WeightRecordDto:
                sample = try record.toHealthKit()
            case let record as HeightRecordDto:
                sample = try record.toHealthKit()
            case let record as HydrationRecordDto:
                sample = try record.toHealthKit()
            case let record as LeanBodyMassRecordDto:
                sample = try record.toHealthKit()
            case let record as BodyFatPercentageRecordDto:
                sample = try record.toHealthKit()
            case let record as BodyTemperatureRecordDto:
                sample = try record.toHealthKit()
            case let record as WheelchairPushesRecordDto:
                sample = try record.toHealthKit()
            case let record as HeartRateMeasurementRecordDto:
                sample = try record.toHealthKit()
            default:
                throw HealthConnectorErrors.invalidArgument(
                    message: "Unsupported record type: \(type(of: request.record))",
                    details: nil
                )
            }

            // Write to HealthKit using pseudo-atomic transaction
            return try await withCheckedThrowingContinuation { continuation in
                store.save(sample) { success, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to write record: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    if success {
                        let recordId = sample.uuid.uuidString
                        let responseDto = WriteRecordResponseDto(recordId: recordId)
                        HealthConnectorLogger.info(
                            tag: HealthConnectorClient.tag,
                            operation: "writeRecord",
                            phase: "completed",
                            message: "Health Connect record written successfully",
                            context: [
                                "request": request,
                                "assignedRecordId": recordId
                            ]
                        )
                        continuation.resume(returning: responseDto)
                    } else {
                        continuation.resume(
                            throwing: HealthConnectorErrors.unknown(
                                message: "Failed to write record",
                                details: "HealthKit save returned false"
                            )
                        )
                    }
                }
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "writeRecord",
                phase: "failed",
                message: "Failed to write Health Connect record",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "writeRecord",
                phase: "failed",
                message: "Failed to write Health Connect record",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Updates a single health record using delete-then-insert pattern.
     *
     * HealthKit uses an immutable data model where samples cannot be updated once saved.
     * This method implements update-like behavior by:
     * 1. Deleting the old sample using delete(_:withCompletion:)
     * 2. Inserting a new sample with corrected values using save(_:withCompletion:)
     *
     * Since HealthKit assigns a new UUID to each sample, the returned record ID will
     * be different from the input ID. This is expected HealthKit behavior.
     *
     * - Parameter request: Contains the health record to update
     * - Returns: UpdateRecordResponseDto containing the new record ID (different from input)
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if record ID is invalid or record data is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func updateRecord(request: UpdateRecordRequestDto) async throws -> UpdateRecordResponseDto {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "updateRecord",
                phase: "entry",
                message: "Updating Health Connect record",
                context: [
                    "request": request
                ]
            )

            // Extract record ID and determine data type from record using pattern matching
            let (recordId, dataType): (String?, HealthDataTypeDto)
            switch request.record {
            case let record as ActiveCaloriesBurnedRecordDto:
                recordId = record.id
                dataType = .activeCaloriesBurned
            case let record as DistanceRecordDto:
                recordId = record.id
                dataType = .distance
            case let record as FloorsClimbedRecordDto:
                recordId = record.id
                dataType = .floorsClimbed
            case let record as StepRecordDto:
                recordId = record.id
                dataType = .steps
            case let record as WeightRecordDto:
                recordId = record.id
                dataType = .weight
            case let record as HeightRecordDto:
                recordId = record.id
                dataType = .height
            case let record as HydrationRecordDto:
                recordId = record.id
                dataType = .hydration
            case let record as LeanBodyMassRecordDto:
                recordId = record.id
                dataType = .leanBodyMass
            case let record as BodyFatPercentageRecordDto:
                recordId = record.id
                dataType = .bodyFatPercentage
            case let record as BodyTemperatureRecordDto:
                recordId = record.id
                dataType = .bodyTemperature
            case let record as WheelchairPushesRecordDto:
                recordId = record.id
                dataType = .wheelchairPushes
            case let record as HeartRateMeasurementRecordDto:
                recordId = record.id
                dataType = .heartRateMeasurementRecord
            default:
                throw HealthConnectorErrors.invalidArgument(
                    message: "Unsupported record type: \(type(of: request.record))",
                    details: nil
                )
            }

            // Validate record ID is not empty
            if recordId?.isEmpty ?? true {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Record ID must be a valid existing ID for update operations. Use writeRecord() for new records.",
                    details: "Record ID: \(recordId ?? "nil")"
                )
            }

            // Convert record ID to UUID
            guard let recordIdString = recordId,
                  let recordUUID = UUID(uuidString: recordIdString) else {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid record ID format: \(recordId ?? "nil")",
                    details: "Record ID must be a valid UUID string"
                )
            }

            // Convert data type to HealthKit quantity type
            let quantityType = dataType.toHealthKitQuantityType()

            // Step 1: Read existing record to verify it exists and get the sample object
            let existingSample: HKSample = try await withCheckedThrowingContinuation { continuation in
                let predicate = HKQuery.predicateForObject(with: recordUUID)
                let query = HKSampleQuery(
                    sampleType: quantityType,
                    predicate: predicate,
                    limit: 1,
                    sortDescriptors: nil
                ) { _, samples, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to read existing record: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    guard let sample = samples?.first else {
                        continuation.resume(
                            throwing: HealthConnectorErrors.invalidArgument(
                                message: "Record not found: \(recordIdString)",
                                details: "No record found with ID \(recordIdString) for dataType \(dataType)"
                            )
                        )
                        return
                    }

                    continuation.resume(returning: sample)
                }

                self.store.execute(query)
            }

            // Step 2: Convert record to HealthKit sample using pattern matching
            // Convert to HealthKit sample, but with new UUID (will be assigned by HealthKit)
            let newSample: HKSample
            switch request.record {
            case let record as ActiveCaloriesBurnedRecordDto:
                newSample = try record.toHealthKit()
            case let record as DistanceRecordDto:
                newSample = try record.toHealthKit()
            case let record as FloorsClimbedRecordDto:
                newSample = try record.toHealthKit()
            case let record as StepRecordDto:
                newSample = try record.toHealthKit()
            case let record as WeightRecordDto:
                newSample = try record.toHealthKit()
            case let record as HeightRecordDto:
                newSample = try record.toHealthKit()
            case let record as HydrationRecordDto:
                newSample = try record.toHealthKit()
            case let record as LeanBodyMassRecordDto:
                newSample = try record.toHealthKit()
            case let record as BodyFatPercentageRecordDto:
                newSample = try record.toHealthKit()
            case let record as BodyTemperatureRecordDto:
                newSample = try record.toHealthKit()
            case let record as WheelchairPushesRecordDto:
                newSample = try record.toHealthKit()
            case let record as HeartRateMeasurementRecordDto:
                newSample = try record.toHealthKit()
            default:
                throw HealthConnectorErrors.invalidArgument(
                    message: "Unsupported record type: \(type(of: request.record))",
                    details: nil
                )
            }

            // Step 3: Delete the old sample
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                store.delete(existingSample) { success, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to delete existing record: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    if !success {
                        continuation.resume(
                            throwing: HealthConnectorErrors.unknown(
                                message: "Failed to delete existing record",
                                details: "HealthKit delete returned false"
                            )
                        )
                        return
                    }

                    continuation.resume(returning: ())
                }
            }

            // Step 4: Write the new sample
            let newRecordId = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                store.save(newSample) { success, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to write new record after delete: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    if success {
                        let newRecordId = newSample.uuid.uuidString
                        HealthConnectorLogger.info(
                            tag: HealthConnectorClient.tag,
                            operation: "updateRecord",
                            phase: "completed",
                            message: "Health Connect record updated successfully",
                            context: [
                                "request": request
                            ]
                        )
                        continuation.resume(returning: newRecordId)
                    } else {
                        continuation.resume(
                            throwing: HealthConnectorErrors.unknown(
                                message: "Failed to write new record after delete",
                                details: "HealthKit save returned false. Old record was already deleted."
                            )
                        )
                    }
                }
            }

            return UpdateRecordResponseDto(recordId: newRecordId)
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "updateRecord",
                phase: "failed",
                message: "Failed to update Health Connect record",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "updateRecord",
                phase: "failed",
                message: "Failed to update Health Connect record",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Writes multiple health records atomically.
     *
     * - Parameter request: Contains the list of health records to write
     * - Returns: WriteRecordsResponseDto containing the platform-assigned record IDs
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if any record data is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func writeRecords(request: WriteRecordsRequestDto) async throws -> WriteRecordsResponseDto {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "writeRecords",
                phase: "entry",
                message: "Writing Health Connect records",
                context: [
                    "request": request
                ]
            )

            // Extract records from request and convert to HealthKit samples using pattern matching
            var samples: [HKSample] = []

            for record in request.records {
                let sample: HKSample
                switch record {
                case let record as ActiveCaloriesBurnedRecordDto:
                    sample = try record.toHealthKit()
                case let record as DistanceRecordDto:
                    sample = try record.toHealthKit()
                case let record as FloorsClimbedRecordDto:
                    sample = try record.toHealthKit()
                case let record as StepRecordDto:
                    sample = try record.toHealthKit()
                case let record as WeightRecordDto:
                    sample = try record.toHealthKit()
                case let record as HeightRecordDto:
                    sample = try record.toHealthKit()
                case let record as HydrationRecordDto:
                    sample = try record.toHealthKit()
                case let record as LeanBodyMassRecordDto:
                    sample = try record.toHealthKit()
                case let record as BodyFatPercentageRecordDto:
                    sample = try record.toHealthKit()
                case let record as BodyTemperatureRecordDto:
                    sample = try record.toHealthKit()
                case let record as WheelchairPushesRecordDto:
                    sample = try record.toHealthKit()
                case let record as HeartRateMeasurementRecordDto:
                    sample = try record.toHealthKit()
                default:
                    throw HealthConnectorErrors.invalidArgument(
                        message: "Unsupported record type: \(type(of: record))",
                        details: nil
                    )
                }
                samples.append(sample)
            }

            // Atomic batch write using HealthKit's pseudo-atomic transaction
            return try await withCheckedThrowingContinuation { continuation in
                store.save(samples) { success, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to write records: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    if success {
                        let recordIds = samples.map { $0.uuid.uuidString }
                        let responseDto = WriteRecordsResponseDto(recordIds: recordIds)
                        HealthConnectorLogger.info(
                            tag: HealthConnectorClient.tag,
                            operation: "writeRecords",
                            phase: "completed",
                            message: "Health Connect records written successfully",
                            context: [
                                "request": request,
                                "assignedRecordIds": recordIds
                            ]
                        )
                        continuation.resume(returning: responseDto)
                    } else {
                        continuation.resume(
                            throwing: HealthConnectorErrors.unknown(
                                message: "Failed to write records",
                                details: "HealthKit save returned false"
                            )
                        )
                    }
                }
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "writeRecords",
                phase: "failed",
                message: "Failed to write Health Connect records",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "writeRecords",
                phase: "failed",
                message: "Failed to write Health Connect records",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    // ==================== AGGREGATE OPERATIONS ====================

    /**
     * Performs an aggregation query on health records.
     *
     * - Parameter request: Contains data type, aggregation metric, and time range
     * - Returns: AggregateResponseDto with aggregated value and data point count
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if time range or metric is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func aggregate(request: AggregateRequestDto) async throws -> AggregateResponseDto {
        do {
            HealthConnectorLogger.debug(
                tag: HealthConnectorClient.tag,
                operation: "aggregate",
                phase: "entry",
                message: "Aggregating Health Connect data",
                context: [
                    "request": request
                ]
            )

            // Validate time range
            if request.startTime >= request.endTime {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid time range: startTime must be before endTime",
                    details: "startTime=\(request.startTime), endTime=\(request.endTime)"
                )
            }

            // Validate metric for data type (throws INVALID_ARGUMENT for unsupported metrics)
            try request.aggregationMetric.validateForDataType(request.dataType)

            // Convert data type to HealthKit quantity type
            let quantityType = request.dataType.toHealthKitQuantityType()

            // Create time range predicate
            let startDate = Date(timeIntervalSince1970: TimeInterval(request.startTime) / 1000.0)
            let endDate = Date(timeIntervalSince1970: TimeInterval(request.endTime) / 1000.0)
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: .strictStartDate
            )

            // Use HKStatisticsQuery for supported metrics (validation ensures only supported metrics reach here)
            let responseDto = try await aggregateWithStatisticsQuery(
                quantityType: quantityType,
                predicate: predicate,
                metric: request.aggregationMetric,
                dataType: request.dataType
            )
            
            HealthConnectorLogger.info(
                tag: HealthConnectorClient.tag,
                operation: "aggregate",
                phase: "completed",
                message: "Health Connect data aggregated successfully",
                context: [
                    "request": request,
                    "response": responseDto
                ]
            )
            
            return responseDto
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "aggregate",
                phase: "failed",
                message: "Failed to aggregate Health Connect data",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "aggregate",
                phase: "failed",
                message: "Failed to aggregate Health Connect data",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Performs aggregation using HKStatisticsQuery for metrics supported by HealthKit statistics.
     *
     * - Parameters:
     *   - quantityType: The HealthKit quantity type to aggregate
     *   - predicate: The time range predicate
     *   - metric: The aggregation metric
     *   - dataType: The health data type
     * - Returns: AggregateResponseDto with aggregated result
     */
    private func aggregateWithStatisticsQuery(
        quantityType: HKQuantityType,
        predicate: NSPredicate,
        metric: AggregationMetricDto,
        dataType: HealthDataTypeDto
    ) async throws -> AggregateResponseDto {
        let options = try metric.toHealthKitStatisticsOptions(dataType: dataType)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: options
            ) { _, statistics, error in
                if let error = error {
                    if let nsError = error as NSError? {
                        continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                    } else {
                        continuation.resume(
                            throwing: HealthConnectorErrors.unknown(
                                message: "Failed to aggregate records: \(error.localizedDescription)",
                                details: error.localizedDescription
                            )
                        )
                    }
                    return
                }

                guard let statistics = statistics else {
                    // No data available - create empty numeric value
                    let emptyNumericDto = NumericDto(unit: .numeric, value: 0.0)
                    let response = AggregateResponseDto(value: emptyNumericDto)
                    continuation.resume(returning: response)
                    return
                }

                // Extract aggregated value based on data type and metric
                let response: AggregateResponseDto

                switch dataType {
                case .activeCaloriesBurned:
                    // For active calories burned, we use cumulativeSum which returns sumQuantity
                    guard let sumQuantity = statistics.sumQuantity() else {
                        let emptyEnergyDto = EnergyDto(unit: .kilocalories, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyEnergyDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }
                    let energyDto = sumQuantity.toEnergyDto()
                    response = AggregateResponseDto(value: energyDto)

                case .steps:
                    // For steps, we use cumulativeSum which returns sumQuantity
                    guard let sumQuantity = statistics.sumQuantity() else {
                        let emptyNumericDto = NumericDto(unit: .numeric, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyNumericDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }
                    let stepCount = Int64(sumQuantity.doubleValue(for: .count()))
                    let numericDto = stepCount.toNumericDto()
                    response = AggregateResponseDto(value: numericDto)

                case .weight:
                    // For weight, we use discreteAverage, discreteMin, or discreteMax
                    let weightQuantity: HKQuantity?
                    switch metric {
                    case .avg:
                        weightQuantity = statistics.averageQuantity()
                    case .min:
                        weightQuantity = statistics.minimumQuantity()
                    case .max:
                        weightQuantity = statistics.maximumQuantity()
                    default:
                        weightQuantity = nil
                    }

                    guard let quantity = weightQuantity else {
                        let emptyMassDto = MassDto(unit: .kilograms, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyMassDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    let massDto = quantity.toMassDto()
                    response = AggregateResponseDto(value: massDto)

                case .height:
                    // For height, we use discreteAverage, discreteMin, or discreteMax
                    let heightQuantity: HKQuantity?
                    switch metric {
                    case .avg:
                        heightQuantity = statistics.averageQuantity()
                    case .min:
                        heightQuantity = statistics.minimumQuantity()
                    case .max:
                        heightQuantity = statistics.maximumQuantity()
                    default:
                        heightQuantity = nil
                    }

                    guard let quantity = heightQuantity else {
                        let emptyLengthDto = LengthDto(unit: .meters, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyLengthDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    let lengthDto = quantity.toLengthDto()
                    response = AggregateResponseDto(value: lengthDto)

                case .hydration:
                    // For hydration (dietaryWater), we use cumulativeSum for sum only
                    guard let quantity = statistics.sumQuantity() else {
                        let emptyVolumeDto = VolumeDto(unit: .liters, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyVolumeDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    let volumeDto = quantity.toVolumeDto()
                    response = AggregateResponseDto(value: volumeDto)

                case .leanBodyMass:
                    // For lean body mass, we use discreteAverage, discreteMin, or discreteMax
                    let leanBodyMassQuantity: HKQuantity?
                    switch metric {
                    case .avg:
                        leanBodyMassQuantity = statistics.averageQuantity()
                    case .min:
                        leanBodyMassQuantity = statistics.minimumQuantity()
                    case .max:
                        leanBodyMassQuantity = statistics.maximumQuantity()
                    default:
                        leanBodyMassQuantity = nil
                    }

                    guard let quantity = leanBodyMassQuantity else {
                        let emptyMassDto = MassDto(unit: .kilograms, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyMassDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    let massDto = quantity.toMassDto()
                    response = AggregateResponseDto(value: massDto)

                case .distance:
                    // For distance, we use cumulativeSum which returns sumQuantity
                    guard let sumQuantity = statistics.sumQuantity() else {
                        let emptyLengthDto = LengthDto(unit: .meters, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyLengthDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }
                    let lengthDto = sumQuantity.toLengthDto()
                    response = AggregateResponseDto(value: lengthDto)

                case .floorsClimbed:
                    // For floors climbed, we use cumulativeSum which returns sumQuantity
                    guard let sumQuantity = statistics.sumQuantity() else {
                        let emptyNumericDto = NumericDto(unit: .numeric, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyNumericDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }
                    let floorsCount = sumQuantity.doubleValue(for: .count())
                    let numericDto = NumericDto(unit: .numeric, value: floorsCount)
                    response = AggregateResponseDto(value: numericDto)

                case .wheelchairPushes:
                    // For wheelchair pushes, we use cumulativeSum which returns sumQuantity
                    guard let sumQuantity = statistics.sumQuantity() else {
                        let emptyNumericDto = NumericDto(unit: .numeric, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyNumericDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }
                    let pushesCount = Int64(sumQuantity.doubleValue(for: .count()))
                    let numericDto = pushesCount.toNumericDto()
                    response = AggregateResponseDto(value: numericDto)

                case .heartRateMeasurementRecord:
                    // For heart rate, we use discreteAverage, discreteMin, or discreteMax
                    let heartRateQuantity: HKQuantity?
                    switch metric {
                    case .avg:
                        heartRateQuantity = statistics.averageQuantity()
                    case .min:
                        heartRateQuantity = statistics.minimumQuantity()
                    case .max:
                        heartRateQuantity = statistics.maximumQuantity()
                    default:
                        heartRateQuantity = nil
                    }

                    guard let quantity = heartRateQuantity else {
                        let emptyNumericDto = NumericDto(unit: .numeric, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyNumericDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    // Heart rate is in beats per minute (count/minute)
                    let unit = HKUnit.count().unitDivided(by: .minute())
                    let bpmValue = quantity.doubleValue(for: unit)
                    let numericDto = NumericDto(unit: .numeric, value: bpmValue)
                    response = AggregateResponseDto(value: numericDto)

                case .bodyTemperature:
                    // For body temperature, we use discreteAverage, discreteMin, or discreteMax
                    let temperatureQuantity: HKQuantity?
                    switch metric {
                    case .avg:
                        temperatureQuantity = statistics.averageQuantity()
                    case .min:
                        temperatureQuantity = statistics.minimumQuantity()
                    case .max:
                        temperatureQuantity = statistics.maximumQuantity()
                    default:
                        temperatureQuantity = nil
                    }

                    guard let quantity = temperatureQuantity else {
                        let emptyTemperatureDto = TemperatureDto(unit: .celsius, value: 0.0)
                        let emptyResponse = AggregateResponseDto(value: emptyTemperatureDto)
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    let temperatureDto = quantity.toTemperatureDto()
                    response = AggregateResponseDto(value: temperatureDto)

                case .bodyFatPercentage:
                    // Body fat percentage does not support aggregation
                    let emptyPercentageDto = PercentageDto(unit: .decimal, value: 0.0)
                    let emptyResponse = AggregateResponseDto(value: emptyPercentageDto)
                    continuation.resume(returning: emptyResponse)
                    return
                }

                continuation.resume(returning: response)
            }

            self.store.execute(query)
        }
    }


    // ==================== DELETE OPERATIONS ====================

    /**
     * Deletes all records of a data type within a time range.
     *
     * Uses HealthKit's `deleteObjects(of:predicate:withCompletion:)` API.
     *
     * - Parameter request: Contains data type and time range for deletion
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if time range is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if deletion fails
     */
    func deleteRecordsByTimeRange(request: DeleteRecordsByTimeRangeRequestDto) async throws {
        HealthConnectorLogger.debug(
            tag: HealthConnectorClient.tag,
            operation: "deleteRecordsByTimeRange",
            phase: "entry",
            message: "Deleting Health Connect records by time range",
            context: [
                "request": request
            ]
        )

        do {
            // Validate time range
            if request.startTime >= request.endTime {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid time range: startTime must be before endTime",
                    details: "startTime=\(request.startTime), endTime=\(request.endTime)"
                )
            }

            let sampleType = try request.dataType.toHealthKitSampleType()
            let startDate = Date(timeIntervalSince1970: TimeInterval(request.startTime) / 1000.0)
            let endDate = Date(timeIntervalSince1970: TimeInterval(request.endTime) / 1000.0)

            // Create time range predicate
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: [.strictStartDate, .strictEndDate]
            )

            // Delete objects matching the predicate
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                store.deleteObjects(of: sampleType, predicate: predicate) { success, count, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to delete records: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    if success {
                        HealthConnectorLogger.info(
                            tag: HealthConnectorClient.tag,
                            operation: "deleteRecordsByTimeRange",
                            phase: "completed",
                            message: "Health Connect records deleted successfully",
                            context: [
                                "request": request
                            ]
                        )
                        continuation.resume(returning: ())
                    } else {
                        continuation.resume(
                            throwing: HealthConnectorErrors.unknown(
                                message: "Failed to delete records",
                                details: "HealthKit delete returned false"
                            )
                        )
                    }
                }
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "deleteRecordsByTimeRange",
                phase: "failed",
                message: "Failed to delete Health Connect records by time range",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "deleteRecordsByTimeRange",
                phase: "failed",
                message: "Failed to delete Health Connect records by time range",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Deletes specific records by their IDs.
     *
     * Uses query-then-delete pattern since HealthKit doesn't support direct UUID deletion.
     *
     * - Parameter request: Contains data type and list of record IDs to delete
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if record IDs are invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if deletion fails
     */
    func deleteRecordsByIds(request: DeleteRecordsByIdsRequestDto) async throws {
        HealthConnectorLogger.debug(
            tag: HealthConnectorClient.tag,
            operation: "deleteRecordsByIds",
            phase: "entry",
            message: "Deleting Health Connect records by IDs",
            context: [
                "request": request
            ]
        )

        do {
            let sampleType = try request.dataType.toHealthKitSampleType()

            // Convert string IDs to UUIDs
            let uuids = request.recordIds.compactMap { UUID(uuidString: $0) }
            guard uuids.count == request.recordIds.count else {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid record IDs provided",
                    details: "Some record IDs are not valid UUIDs"
                )
            }

            // Step 1: Query for objects with specific UUIDs
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
                let uuidPredicate = HKQuery.predicateForObjects(with: Set(uuids))

                let query = HKSampleQuery(
                    sampleType: sampleType,
                    predicate: uuidPredicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { query, samples, error in
                    if let error = error {
                        if let nsError = error as NSError? {
                            continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to query records: \(error.localizedDescription)",
                                    details: error.localizedDescription
                                )
                            )
                        }
                        return
                    }

                    guard let samples = samples else {
                        continuation.resume(returning: [])
                        return
                    }

                    continuation.resume(returning: samples)
                }

                store.execute(query)
            }

            // Step 2: Delete the retrieved samples
            if !samples.isEmpty {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    store.delete(samples) { success, error in
                        if let error = error {
                            if let nsError = error as NSError? {
                                continuation.resume(throwing: HealthConnectorClient.mapHealthKitError(nsError))
                            } else {
                                continuation.resume(
                                    throwing: HealthConnectorErrors.unknown(
                                        message: "Failed to delete records: \(error.localizedDescription)",
                                        details: error.localizedDescription
                                    )
                                )
                            }
                            return
                        }

                        if success {
                            HealthConnectorLogger.info(
                                tag: HealthConnectorClient.tag,
                                operation: "deleteRecordsByIds",
                                phase: "completed",
                                message: "Health Connect records deleted successfully",
                                context: [
                                    "request": request
                                ]
                            )
                            continuation.resume(returning: ())
                        } else {
                            continuation.resume(
                                throwing: HealthConnectorErrors.unknown(
                                    message: "Failed to delete records",
                                    details: "HealthKit delete returned false"
                                )
                            )
                        }
                    }
                }
            } else {
                HealthConnectorLogger.warning(
                    tag: HealthConnectorClient.tag,
                    operation: "deleteRecordsByIds",
                    phase: "completed",
                    message: "No records to delete (empty IDs list)"
                )
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "deleteRecordsByIds",
                phase: "failed",
                message: "Failed to delete Health Connect records by IDs",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw baseError
        } catch {
            HealthConnectorLogger.error(
                tag: HealthConnectorClient.tag,
                operation: "deleteRecordsByIds",
                phase: "failed",
                message: "Failed to delete Health Connect records by IDs",
                context: [
                    "request": request
                ],
                exception: error
            )
            throw HealthConnectorErrors.unknown(
                message: "Failed to process \(request): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }
}
