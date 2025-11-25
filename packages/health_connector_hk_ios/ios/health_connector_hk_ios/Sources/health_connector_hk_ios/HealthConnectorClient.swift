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
            NSLog("\(tag): HealthKit is not available on this device")
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
        NSLog("\(tag): Getting HealthKit availability status...")

        let isAvailable = HKHealthStore.isHealthDataAvailable()
        NSLog("\(tag): HealthKit available: \(isAvailable)")

        let statusDto = HealthPlatformStatusDto.fromHealthKitAvailability(isAvailable)
        NSLog("\(tag): HealthKit status DTO: \(statusDto)")

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
            NSLog(
                "\(HealthConnectorClient.tag): Requesting permission DTOs for: \(healthDataPermissions.map { "\($0.accessType)_\($0.healthDataType)" }.joined(separator: ", "))..."
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

            NSLog("\(HealthConnectorClient.tag): Requesting HealthKit authorization for \(typesToRead.count) read types and \(typesToWrite.count) write types...")

            // Request authorization from HealthKit
            try await store.requestAuthorization(toShare: typesToWrite, read: typesToRead)

            NSLog("\(HealthConnectorClient.tag): HealthKit authorization request completed")

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

            NSLog("\(HealthConnectorClient.tag): Permission request result DTOs: \(results)")

            return results

        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            let permissionsCount = healthDataPermissions.count
            NSLog("\(HealthConnectorClient.tag): HealthKit error during permission request: \(error.localizedDescription)")
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            // Create new error with enhanced context
            throw HealthConnectorErrors.unknown(
                message: "Failed to request permissions (total: \(permissionsCount)): \(baseError.message ?? "Unknown error")",
                details: baseError.details
            )
        } catch {
            let permissionsCount = healthDataPermissions.count
            NSLog("\(HealthConnectorClient.tag): Unknown error during permission request: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to request permissions (total: \(permissionsCount)): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Reads a single health record by ID.
     *
     * - Parameter request: Contains the data type and record ID to read
     * - Returns: ReadRecordResponseDto with the appropriate typed field populated, or nil if not found
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if the record ID format is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func readRecord(request: ReadRecordRequestDto) async throws -> ReadRecordResponseDto? {
        do {
            NSLog("\(HealthConnectorClient.tag): Reading single record: dataType=\(request.dataType), id=\(request.recordId)")

            // Convert data type to HealthKit quantity type
            let quantityType = request.dataType.toHealthKitQuantityType()
            
            // Create UUID from record ID string
            guard let recordUUID = UUID(uuidString: request.recordId) else {
                NSLog("\(HealthConnectorClient.tag): Invalid record ID format: \(request.recordId)")
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid record ID format: \(request.recordId)",
                    details: "Record ID must be a valid UUID string"
                )
            }

            // Query for the specific sample by UUID
            let predicate = HKQuery.predicateForObject(with: recordUUID)

            // Use async continuation to bridge the callback-based API
            return try await withCheckedThrowingContinuation { continuation in
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
                    let responseDto: ReadRecordResponseDto?
                    switch request.dataType {
                    case .steps:
                        if let stepRecord = sample.toStepRecordDto() {
                            responseDto = ReadRecordResponseDto(
                                dataType: .steps,
                                stepsRecord: stepRecord,
                                weightRecord: nil
                            )
                        } else {
                            responseDto = nil
                        }

                    case .weight:
                        if let weightRecord = sample.toWeightRecordDto() {
                            responseDto = ReadRecordResponseDto(
                                dataType: .weight,
                                stepsRecord: nil,
                                weightRecord: weightRecord
                            )
                        } else {
                            responseDto = nil
                        }
                    }

                    continuation.resume(returning: responseDto)
                }

                self.store.execute(query)
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            NSLog("\(HealthConnectorClient.tag): HealthKit error while reading record: \(error.localizedDescription)")
            let baseError = HealthConnectorClient.mapHealthKitError(error)
            // Create new error with enhanced context, preserving the error code
            throw HealthConnectorError(
                code: baseError.code,
                message: "Failed to read record (dataType=\(request.dataType), recordId=\(request.recordId)): \(baseError.message ?? "Unknown error")",
                details: baseError.details
            )
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to read record: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to read record (dataType=\(request.dataType), recordId=\(request.recordId)): \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Reads multiple health records within a time range (paginated).
     *
     * Supports filtering by data origins (source applications) using compound predicates.
     * Records are ordered by start time in ascending order (oldest first) to provide a
     * unified ordering interface across platforms.
     *
     * ## Data Origin Filtering
     *
     * When [dataOriginPackageNames] is not empty, this method filters records to only
     * include those from the specified sources. The filtering uses HealthKit's compound
     * predicate system:
     *
     * 1. For each bundle identifier in the list, individual source predicates are created
     *    using `HKQuery.predicateForObjects(from:)`
     * 2. These source predicates are combined with OR logic using
     *    `NSCompoundPredicate(orPredicateWithSubpredicates:)`
     * 3. The source predicate is then combined with the time range predicate using AND
     *    logic via `NSCompoundPredicate(andPredicateWithSubpredicates:)`
     *
     * When the list is empty, no source filtering is applied (all sources are included).
     *
     * ## Ordering
     *
     * Records are ordered by start time in ascending order (oldest first). This provides
     * a unified ordering interface across platforms. HealthKit supports more flexible
     * ordering configurations, but we standardize on start time ordering for consistency
     * with Health Connect, which only supports ordering by start time.
     *
     * - Parameter request: Contains data type, time range, page size, optional page token,
     *                     and optional data origin package names for filtering
     * - Returns: ReadRecordsResponseDto with the appropriate typed list populated and optional next page token
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if time range or page size is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func readRecords(request: ReadRecordsRequestDto) async throws -> ReadRecordsResponseDto {
        do {
            NSLog(
                "\(HealthConnectorClient.tag): Reading records: dataType=\(request.dataType), startTime=\(request.startTime), endTime=\(request.endTime), pageSize=\(request.pageSize), dataOriginPackageNames=\(request.dataOriginPackageNames.count) sources"
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
                        NSLog("\(HealthConnectorClient.tag): Invalid pageToken: adjusted startTime (\(effectiveStartTime)) >= endTime (\(request.endTime))")
                        return createEmptyResponse(for: request.dataType)
                    }
                    
                    NSLog("\(HealthConnectorClient.tag): Using pageToken for pagination: original startTime=\(request.startTime), adjusted startTime=\(effectiveStartTime)")
                } else {
                    // Invalid pageToken format, log warning but continue with original startTime
                    NSLog("\(HealthConnectorClient.tag): Invalid pageToken format: '\(pageToken)', using original startTime")
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
                    NSLog("\(HealthConnectorClient.tag): No sources found for bundle identifiers: \(request.dataOriginPackageNames)")
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
            return try await withCheckedThrowingContinuation { continuation in
                let query = HKSampleQuery(
                    sampleType: quantityType,
                    predicate: predicate,
                    limit: Int(request.pageSize),
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
                    case .steps:
                        let stepRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toStepRecordDto() }
                        
                        // Generate nextPageToken if we got exactly pageSize records (indicating more may exist)
                        let nextPageToken: String?
                        if stepRecords.count == request.pageSize, let lastRecord = stepRecords.last {
                            // Encode last record's endTime as nextPageToken
                            nextPageToken = String(lastRecord.endTime)
                            NSLog("\(HealthConnectorClient.tag): Generated nextPageToken for steps: \(nextPageToken ?? "nil") (last record endTime: \(lastRecord.endTime))")
                        } else {
                            // Fewer than pageSize records means no more pages
                            nextPageToken = nil
                        }
                        
                        responseDto = ReadRecordsResponseDto(
                            dataType: .steps,
                            nextPageToken: nextPageToken,
                            stepsRecords: stepRecords,
                            weightRecords: nil
                        )

                    case .weight:
                        let weightRecords = samples.compactMap { ($0 as? HKQuantitySample)?.toWeightRecordDto() }
                        
                        // Generate nextPageToken if we got exactly pageSize records (indicating more may exist)
                        let nextPageToken: String?
                        if weightRecords.count == request.pageSize, let lastRecord = weightRecords.last {
                            // Encode last record's time as nextPageToken
                            nextPageToken = String(lastRecord.time)
                            NSLog("\(HealthConnectorClient.tag): Generated nextPageToken for weight: \(nextPageToken ?? "nil") (last record time: \(lastRecord.time))")
                        } else {
                            // Fewer than pageSize records means no more pages
                            nextPageToken = nil
                        }
                        
                        responseDto = ReadRecordsResponseDto(
                            dataType: .weight,
                            nextPageToken: nextPageToken,
                            stepsRecords: nil,
                            weightRecords: weightRecords
                        )
                    }

                    continuation.resume(returning: responseDto)
                }

                self.store.execute(query)
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            NSLog("\(HealthConnectorClient.tag): HealthKit error while reading records: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to read records: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to read records: \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
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
     * - Returns: ReadRecordsResponseDto with empty lists
     */
    private func createEmptyResponse(for dataType: HealthDataTypeDto) -> ReadRecordsResponseDto {
        switch dataType {
        case .steps:
            return ReadRecordsResponseDto(
                dataType: .steps,
                nextPageToken: nil,
                stepsRecords: [],
                weightRecords: nil
            )
        case .weight:
            return ReadRecordsResponseDto(
                dataType: .weight,
                nextPageToken: nil,
                stepsRecords: nil,
                weightRecords: []
            )
        }
    }

    // ==================== WRITE OPERATIONS ====================

    /**
     * Writes a single health record.
     *
     * - Parameter request: Contains the data type and the typed record to write
     * - Returns: WriteRecordResponseDto containing the platform-assigned record ID
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if record data is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func writeRecord(request: WriteRecordRequestDto) async throws -> WriteRecordResponseDto {
        do {
            NSLog("\(HealthConnectorClient.tag): Writing single record: dataType=\(request.dataType)")

            // Extract typed record from request DTO and convert to HealthKit sample
            let sample: HKSample
            switch request.dataType {
            case .steps:
                guard let stepsRecord = request.stepsRecord else {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "stepsRecord must not be nil for STEPS type",
                        details: nil
                    )
                }
                sample = try stepsRecord.toHealthKit()

            case .weight:
                guard let weightRecord = request.weightRecord else {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "weightRecord must not be nil for WEIGHT type",
                        details: nil
                    )
                }
                sample = try weightRecord.toHealthKit()
            }

            // Write to HealthKit using pseudo-atomic transaction
            return try await withCheckedThrowingContinuation { continuation in
                store.save(sample) { success, error in
                    if let error = error {
                        NSLog("\(HealthConnectorClient.tag): Failed to write record: \(error.localizedDescription)")
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
                        NSLog("\(HealthConnectorClient.tag): Successfully wrote record with ID: \(recordId)")
                        continuation.resume(returning: WriteRecordResponseDto(recordId: recordId))
                    } else {
                        NSLog("\(HealthConnectorClient.tag): Failed to write record: HealthKit save returned false")
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
            NSLog("\(HealthConnectorClient.tag): HealthKit error while writing record: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to write record: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to write record: \(error.localizedDescription)",
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
     * - Parameter request: Contains the data type and the typed record to update
     * - Returns: UpdateRecordResponseDto containing the new record ID (different from input)
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if record ID is invalid or record data is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func updateRecord(request: UpdateRecordRequestDto) async throws -> UpdateRecordResponseDto {
        do {
            NSLog("\(HealthConnectorClient.tag): Updating single record: dataType=\(request.dataType)")

            // Validate record ID
            let recordId: String
            switch request.dataType {
            case .steps:
                guard let stepsRecord = request.stepsRecord else {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "stepsRecord must not be nil for STEPS type",
                        details: nil
                    )
                }
                recordId = stepsRecord.id
                
                // Validate record ID is not empty or "none"
                if recordId.isEmpty || recordId == "none" {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "Record ID must be a valid existing ID for update operations. Use writeRecord() for new records.",
                        details: "Record ID: \(recordId)"
                    )
                }

            case .weight:
                guard let weightRecord = request.weightRecord else {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "weightRecord must not be nil for WEIGHT type",
                        details: nil
                    )
                }
                recordId = weightRecord.id
                
                // Validate record ID is not empty or "none"
                if recordId.isEmpty || recordId == "none" {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "Record ID must be a valid existing ID for update operations. Use writeRecord() for new records.",
                        details: "Record ID: \(recordId)"
                    )
                }
            }

            // Convert record ID to UUID
            guard let recordUUID = UUID(uuidString: recordId) else {
                throw HealthConnectorErrors.invalidArgument(
                    message: "Invalid record ID format: \(recordId)",
                    details: "Record ID must be a valid UUID string"
                )
            }

            // Convert data type to HealthKit quantity type
            let quantityType = request.dataType.toHealthKitQuantityType()

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
                                message: "Record not found: \(recordId)",
                                details: "No record found with ID \(recordId) for dataType \(request.dataType)"
                            )
                        )
                        return
                    }

                    continuation.resume(returning: sample)
                }

                self.store.execute(query)
            }

            // Step 2: Extract typed record from request DTO and convert to HealthKit sample
            let newSample: HKSample
            switch request.dataType {
            case .steps:
                guard let stepsRecord = request.stepsRecord else {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "stepsRecord must not be nil for STEPS type",
                        details: nil
                    )
                }
                // Convert to HealthKit sample, but with new UUID (will be assigned by HealthKit)
                newSample = try stepsRecord.toHealthKit()

            case .weight:
                guard let weightRecord = request.weightRecord else {
                    throw HealthConnectorErrors.invalidArgument(
                        message: "weightRecord must not be nil for WEIGHT type",
                        details: nil
                    )
                }
                // Convert to HealthKit sample, but with new UUID (will be assigned by HealthKit)
                newSample = try weightRecord.toHealthKit()
            }

            // Step 3: Delete the old sample
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                store.delete(existingSample) { success, error in
                    if let error = error {
                        NSLog("\(HealthConnectorClient.tag): Failed to delete existing record: \(error.localizedDescription)")
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
                        NSLog("\(HealthConnectorClient.tag): Failed to delete existing record: HealthKit delete returned false")
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
                        NSLog("\(HealthConnectorClient.tag): Failed to write new record after delete: \(error.localizedDescription)")
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
                        NSLog("\(HealthConnectorClient.tag): Successfully updated record: old ID=\(recordId), new ID=\(newRecordId)")
                        continuation.resume(returning: newRecordId)
                    } else {
                        NSLog("\(HealthConnectorClient.tag): Failed to write new record: HealthKit save returned false")
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
            NSLog("\(HealthConnectorClient.tag): HealthKit error while updating record: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to update record: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to update record: \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }

    /**
     * Writes multiple health records atomically.
     *
     * - Parameter request: Contains the data types and the list of typed records to write
     * - Returns: WriteRecordsResponseDto containing the platform-assigned record IDs
     *
     * - Throws: `HealthConnectorError` with code `INVALID_ARGUMENT` if any record data is invalid
     * - Throws: `HealthConnectorError` with code `SECURITY_ERROR` if authorization is denied
     * - Throws: `HealthConnectorError` with code `HEALTH_PLATFORM_UNAVAILABLE` if HealthKit database is inaccessible
     * - Throws: `HealthConnectorError` with code `UNKNOWN` if an unexpected error occurs
     */
    func writeRecords(request: WriteRecordsRequestDto) async throws -> WriteRecordsResponseDto {
        do {
            NSLog("\(HealthConnectorClient.tag): Writing records: dataTypes=\(request.dataTypes)")

            // Extract typed records from request DTO and convert to HealthKit samples
            var samples: [HKSample] = []

            for dataTypeDto in request.dataTypes {
                switch dataTypeDto {
                case .steps:
                    guard let stepsRecords = request.stepsRecords else {
                        throw HealthConnectorErrors.invalidArgument(
                            message: "stepsRecords must not be nil for STEPS type",
                            details: nil
                        )
                    }
                    let stepSamples = try stepsRecords.map { try $0.toHealthKit() }
                    samples.append(contentsOf: stepSamples)

                case .weight:
                    guard let weightRecords = request.weightRecords else {
                        throw HealthConnectorErrors.invalidArgument(
                            message: "weightRecords must not be nil for WEIGHT type",
                            details: nil
                        )
                    }
                    let weightSamples = try weightRecords.map { try $0.toHealthKit() }
                    samples.append(contentsOf: weightSamples)
                }
            }

            // Atomic batch write using HealthKit's pseudo-atomic transaction
            return try await withCheckedThrowingContinuation { continuation in
                store.save(samples) { success, error in
                    if let error = error {
                        NSLog("\(HealthConnectorClient.tag): Failed to write records: \(error.localizedDescription)")
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
                        NSLog("\(HealthConnectorClient.tag): Successfully wrote \(recordIds.count) records")
                        continuation.resume(returning: WriteRecordsResponseDto(recordIds: recordIds))
                    } else {
                        NSLog("\(HealthConnectorClient.tag): Failed to write records: HealthKit save returned false")
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
            NSLog("\(HealthConnectorClient.tag): HealthKit error while writing records: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to write records: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to write records: \(error.localizedDescription)",
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
            NSLog(
                "\(HealthConnectorClient.tag): Aggregating records: dataType=\(request.dataType), metric=\(request.aggregationMetric), startTime=\(request.startTime), endTime=\(request.endTime)"
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
            return try await aggregateWithStatisticsQuery(
                quantityType: quantityType,
                predicate: predicate,
                metric: request.aggregationMetric,
                dataType: request.dataType
            )
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            NSLog("\(HealthConnectorClient.tag): HealthKit error during aggregation: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to aggregate records: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to aggregate records: \(error.localizedDescription)",
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
        let options = metric.toHealthKitStatisticsOptions(dataType: dataType)

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
                    // No data available
                    let response = AggregateResponseDto(
                        aggregationMetric: metric,
                        dataType: dataType,
                        doubleValue: nil,
                        massValue: nil
                    )
                    continuation.resume(returning: response)
                    return
                }

                // Extract aggregated value based on data type and metric
                let response: AggregateResponseDto

                switch dataType {
                case .steps:
                    // For steps, we use cumulativeSum which returns sumQuantity
                    guard let sumQuantity = statistics.sumQuantity() else {
                        let emptyResponse = AggregateResponseDto(
                            aggregationMetric: metric,
                            dataType: dataType,
                            doubleValue: nil,
                            massValue: nil
                        )
                        continuation.resume(returning: emptyResponse)
                        return
                    }
                    let stepCount = Int64(sumQuantity.doubleValue(for: .count()))
                    let numericDto = stepCount.toNumericDto()
                    response = AggregateResponseDto(
                        aggregationMetric: metric,
                        dataType: dataType,
                        doubleValue: numericDto.value,
                        massValue: nil
                    )

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
                        let emptyResponse = AggregateResponseDto(
                            aggregationMetric: metric,
                            dataType: dataType,
                            doubleValue: nil,
                            massValue: nil
                        )
                        continuation.resume(returning: emptyResponse)
                        return
                    }

                    let massDto = quantity.toMassDto()
                    response = AggregateResponseDto(
                        aggregationMetric: metric,
                        dataType: dataType,
                        doubleValue: nil,
                        massValue: massDto
                    )
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
        NSLog("\(HealthConnectorClient.tag): Deleting records by time range: dataType=\(request.dataType)")

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
                        NSLog("\(HealthConnectorClient.tag): Failed to delete records: \(error.localizedDescription)")
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
                        NSLog("\(HealthConnectorClient.tag): Successfully deleted \(count) records")
                        continuation.resume(returning: ())
                    } else {
                        NSLog("\(HealthConnectorClient.tag): Failed to delete records: HealthKit delete returned false")
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
            NSLog("\(HealthConnectorClient.tag): HealthKit error while deleting records: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to delete records: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to delete records: \(error.localizedDescription)",
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
        NSLog("\(HealthConnectorClient.tag): Deleting \(request.recordIds.count) records by ID: dataType=\(request.dataType)")

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
                        NSLog("\(HealthConnectorClient.tag): Failed to query records for deletion: \(error.localizedDescription)")
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
                        NSLog("\(HealthConnectorClient.tag): No samples found for deletion")
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
                            NSLog("\(HealthConnectorClient.tag): Failed to delete records: \(error.localizedDescription)")
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
                            NSLog("\(HealthConnectorClient.tag): Successfully deleted \(samples.count) records")
                            continuation.resume(returning: ())
                        } else {
                            NSLog("\(HealthConnectorClient.tag): Failed to delete records: HealthKit delete returned false")
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
                NSLog("\(HealthConnectorClient.tag): No records found to delete")
            }
        } catch let error as HealthConnectorError {
            // Re-throw HealthConnectorError as-is
            throw error
        } catch let error as NSError {
            NSLog("\(HealthConnectorClient.tag): HealthKit error while deleting records: \(error.localizedDescription)")
            throw HealthConnectorClient.mapHealthKitError(error)
        } catch {
            NSLog("\(HealthConnectorClient.tag): Failed to delete records: \(error.localizedDescription)")
            throw HealthConnectorErrors.unknown(
                message: "Failed to delete records: \(error.localizedDescription)",
                details: error.localizedDescription
            )
        }
    }
}

