package com.phamtunglam.health_connector_hc_android

import android.content.Context
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Mass
import com.phamtunglam.health_connector_hc_android.mappers.toDto
import com.phamtunglam.health_connector_hc_android.mappers.toError
import com.phamtunglam.health_connector_hc_android.mappers.toHealthConnect
import com.phamtunglam.health_connector_hc_android.mappers.toHealthConnectFeature
import com.phamtunglam.health_connector_hc_android.mappers.toHealthConnectMetric
import com.phamtunglam.health_connector_hc_android.mappers.toHealthConnectRecordClass
import com.phamtunglam.health_connector_hc_android.mappers.toHealthDataPermissionDto
import com.phamtunglam.health_connector_hc_android.mappers.toHealthPlatformFeatureDto
import com.phamtunglam.health_connector_hc_android.mappers.toHealthPlatformFeatureStatusDto
import com.phamtunglam.health_connector_hc_android.mappers.toHealthPlatformStatusDto
import com.phamtunglam.health_connector_hc_android.mappers.toNumericDto
import com.phamtunglam.health_connector_hc_android.pigeon.AggregateRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.AggregateResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.DeleteRecordsByIdsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.DeleteRecordsByTimeRangeRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthConnectorError
import com.phamtunglam.health_connector_hc_android.pigeon.HealthConnectorErrorCodeDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataPermissionRequestResultDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataTypeDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeatureDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeaturePermissionRequestResultDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeatureStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionsRequestResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordsResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.UpdateRecordRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.UpdateRecordResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordsResponseDto
import com.phamtunglam.health_connector_hc_android.utils.PermissionUtils
import java.time.Instant

/**
 * Internal client wrapper for the Android Health Connect SDK.
 *
 * @property client The underlying Health Connect SDK client instance
 */
internal class HealthConnectorClient private constructor(private val client: HealthConnectClient) {
    companion object {
        /**
         * Tag used for logging throughout the client.
         */
        private val TAG = HealthConnectorClient::class.simpleName

        /**
         * Gets or creates a [HealthConnectorClient] instance.
         *
         * @param context Android application context used to access Health Connect services
         * @return A new [HealthConnectorClient] instance wrapping the Health Connect SDK client
         *
         * @throws HealthConnectorError with code `HEALTH_PLATFORM_NOT_AVAILABLE` when:
         *         - The device SDK version is too low (below API 26)
         *         - The app is running in a profile/work profile that doesn't support Health Connect
         *         - Health Connect SDK initialization fails
         */
        @Throws(HealthConnectorError::class)
        fun getOrCreate(context: Context): HealthConnectorClient {
            try {
                return HealthConnectorClient(
                    HealthConnectClient.getOrCreate(
                        context
                    )
                )
            } catch (e: UnsupportedOperationException) {
                Log.e(
                    TAG,
                    "Failed to create Health Connect client due to SDK version too low or running in a profile mode.",
                    e,
                )
                throw HealthConnectorErrorCodeDto.INSTALLATION_OR_UPDATE_REQUIRED.toError(details = e.message)
            } catch (e: IllegalStateException) {
                Log.e(TAG, "Failed to create Health Connect client due to service not available", e)
                throw HealthConnectorErrorCodeDto.HEALTH_PLATFORM_UNAVAILABLE.toError(details = e.message)
            }
        }

        /**
         * Gets the current status of the Health Connect platform on the device.
         *
         * @param context Android application context used to query Health Connect status
         * @return The current platform status as a [HealthPlatformStatusDto]
         */
        fun getHealthPlatformStatus(context: Context): HealthPlatformStatusDto {
            Log.d(TAG, "Getting Health Connect SDK status...")

            val statusCode = HealthConnectClient.getSdkStatus(context)
            Log.d(TAG, "Health Connect SDK status code: $statusCode.")

            val statusDto = statusCode.toHealthPlatformStatusDto()
            Log.d(TAG, "Health Connect SDK status DTO: $statusDto.")

            return statusDto
        }
    }

    /**
     * Requests the specified permissions from the user.
     *
     * @param activity The [ComponentActivity] that will host the permission request UI
     * @param request The permissions request containing both health data and feature permissions
     * @return [PermissionsRequestResponseDto] containing separate result lists for health data
     *         and feature permissions
     *
     * @throws HealthConnectorError with code `INVALID_PLATFORM_CONFIGURATION` if any requested
     *         permissions/features are not declared in AndroidManifest.xml
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun requestPermissions(
        activity: ComponentActivity,
        request: PermissionsRequestDto,
    ): PermissionsRequestResponseDto {
        try {
            Log.d(
                TAG,
                "Requesting ${request.healthDataPermissions.size} health data permissions " + "and ${request.featurePermissions.size} feature permissions"
            )

            // Validate that all requested permissions are declared in AndroidManifest
            PermissionUtils.validatePermissionsDeclaredInManifest(activity.applicationContext, request)

            val grantedPermissions = PermissionUtils.requestPermissionsFromSystem(activity, request)

            val healthDataResults = PermissionUtils.buildHealthDataPermissionResults(
                request.healthDataPermissions, grantedPermissions
            )
            val featureResults = PermissionUtils.buildFeaturePermissionResults(
                request.featurePermissions, grantedPermissions
            )

            Log.d(
                TAG,
                "Completed permission request: ${healthDataResults.size} health data, ${featureResults.size} features"
            )

            return PermissionsRequestResponseDto(
                healthDataPermissionResults = healthDataResults, featurePermissionResults = featureResults
            )
        } catch (e: Exception) {
            val totalPermissions = request.healthDataPermissions.size + request.featurePermissions.size
            Log.e(TAG, "Unexpected error while requesting permissions", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to request permissions (total: $totalPermissions, health data: ${request.healthDataPermissions.size}, features: ${request.featurePermissions.size}): ${e.message ?: "Unknown error"}",
            )
        }
    }

    /**
     * Gets the status of a specific feature on the current platform.
     *
     * @param context The Android application context
     * @param feature The feature to check availability for
     * @return [HealthPlatformFeatureStatusDto.AVAILABLE] if the feature is available,
     *         [HealthPlatformFeatureStatusDto.UNAVAILABLE] otherwise
     *
     * @throws HealthConnectorError with code `INVALID_PLATFORM_CONFIGURATION` if the feature permission
     *         is not declared in AndroidManifest.xml
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    fun getFeatureStatus(context: Context, feature: HealthPlatformFeatureDto): HealthPlatformFeatureStatusDto {
        try {
            Log.d(TAG, "Checking feature status for: $feature...")

            // Validate that the feature permission is declared in AndroidManifest
            PermissionUtils.validateFeaturePermissionDeclaredInManifest(context, feature)

            // Map HealthPlatformFeatureDto to Health Connect feature constants
            val healthConnectFeature = feature.toHealthConnectFeature()

            // Check feature status using Health Connect SDK
            val statusCode = client.features.getFeatureStatus(healthConnectFeature)
            Log.d(TAG, "Health Connect feature status code for $feature: $statusCode.")

            // Map Health Connect status to HealthPlatformFeatureStatusDto
            val statusDto = statusCode.toHealthPlatformFeatureStatusDto()
            Log.d(TAG, "Feature status DTO for $feature: $statusDto.")

            return statusDto
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error during feature status check", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to get feature status for feature=$feature: ${e.message ?: "Unknown error"}",
            )
        }
    }

    /**
     * Reads a single health record by ID.
     *
     * @param request Contains the data type and record ID to read
     * @return ReadRecordResponseDto with the appropriate typed field populated, or null if not found
     *
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun readRecord(request: ReadRecordRequestDto): ReadRecordResponseDto? {
        try {
            Log.d(TAG, "Reading single record: dataType=${request.dataType}, id=${request.recordId}")

            val recordClass = request.dataType.toHealthConnectRecordClass()
            val response = client.readRecord(recordClass, request.recordId)

            // Convert SDK record to DTO using typed mappers
            return when (request.dataType) {
                HealthDataTypeDto.STEPS -> {
                    val record = response.record as StepsRecord
                    ReadRecordResponseDto(
                        dataType = HealthDataTypeDto.STEPS,
                        stepsRecord = record.toDto(),
                        weightRecord = null
                    )
                }

                HealthDataTypeDto.WEIGHT -> {
                    val record = response.record as WeightRecord
                    ReadRecordResponseDto(
                        dataType = HealthDataTypeDto.WEIGHT,
                        stepsRecord = null,
                        weightRecord = record.toDto()
                    )
                }
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while reading record", e)
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while reading record (dataType=${request.dataType}, recordId=${request.recordId}): ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while reading record", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to read record (dataType=${request.dataType}, recordId=${request.recordId}): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Reads multiple health records within a time range (paginated).
     *
     * @param request Contains data type, time range, page size, optional page token,
     *                and optional data origin package names for filtering
     * @return ReadRecordsResponseDto with the appropriate typed list populated and optional next page token
     *
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun readRecords(request: ReadRecordsRequestDto): ReadRecordsResponseDto {
        try {
            Log.d(
                TAG,
                "Reading records: dataType=${request.dataType}, " + "startTime=${request.startTime}, endTime=${request.endTime}, pageSize=${request.pageSize}, dataOriginPackageNames=${request.dataOriginPackageNames.size} sources"
            )

            val recordClass = request.dataType.toHealthConnectRecordClass()
            val timeRangeFilter = TimeRangeFilter.between(
                Instant.ofEpochMilli(request.startTime), Instant.ofEpochMilli(request.endTime)
            )

            // Create data origin filter if package names are provided
            val dataOrigins = request.dataOriginPackageNames.map { packageName ->
                DataOrigin(packageName)
            }

            val readRequest = ReadRecordsRequest(
                recordType = recordClass,
                timeRangeFilter = timeRangeFilter,
                dataOriginFilter = dataOrigins.toSet(),
                pageSize = request.pageSize.toInt(),
                pageToken = request.pageToken
            )

            val response = client.readRecords(readRequest)

            // Convert SDK records to DTOs using typed mappers
            return when (request.dataType) {
                HealthDataTypeDto.STEPS -> {
                    val stepRecords = response.records.map { (it as StepsRecord).toDto() }

                    ReadRecordsResponseDto(
                        dataType = HealthDataTypeDto.STEPS,
                        stepsRecords = stepRecords,
                        weightRecords = null,
                        nextPageToken = response.pageToken
                    )
                }

                HealthDataTypeDto.WEIGHT -> {
                    val weightRecords = response.records.map { (it as WeightRecord).toDto() }

                    ReadRecordsResponseDto(
                        dataType = HealthDataTypeDto.WEIGHT,
                        stepsRecords = null,
                        weightRecords = weightRecords,
                        nextPageToken = response.pageToken
                    )
                }
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while reading records", e)
            val timeRange = "${request.startTime} to ${request.endTime}"
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while reading records (dataType=${request.dataType}, timeRange=$timeRange, pageSize=${request.pageSize}): ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while reading records", e)
            val timeRange = "${request.startTime} to ${request.endTime}"
            val pageToken = request.pageToken ?: "none"
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to read records (dataType=${request.dataType}, timeRange=$timeRange, pageSize=${request.pageSize}, pageToken=$pageToken): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Writes a single health record.
     *
     * @param request Contains the data type and the typed record to write
     * @return WriteRecordResponseDto containing the platform-assigned record ID
     *
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun writeRecord(request: WriteRecordRequestDto): WriteRecordResponseDto {
        try {
            Log.d(TAG, "Writing single record: dataType=${request.dataType}")

            // Extract typed record from request DTO
            val record: Record = when (request.dataType) {
                HealthDataTypeDto.STEPS -> {
                    requireNotNull(request.stepsRecord) { "stepsRecord must not be null for STEPS type" }
                    request.stepsRecord.toHealthConnect()
                }

                HealthDataTypeDto.WEIGHT -> {
                    requireNotNull(request.weightRecord) { "weightRecord must not be null for WEIGHT type" }
                    request.weightRecord.toHealthConnect()
                }
            }

            // Write to Health Connect using ACID transaction
            val response = client.insertRecords(listOf(record))
            val recordId = response.recordIdsList.first()

            Log.d(TAG, "Successfully wrote record with ID: $recordId")

            return WriteRecordResponseDto(recordId = recordId)
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while writing record", e)
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while writing record (dataType=${request.dataType}): ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while writing record", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to write record (dataType=${request.dataType}): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Writes multiple health records atomically.
     *
     * @param request Contains the data type and the list of typed records to write
     * @return WriteRecordsResponseDto containing the platform-assigned record IDs
     *
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun writeRecords(request: WriteRecordsRequestDto): WriteRecordsResponseDto {
        try {
            Log.d(TAG, "Writing records: dataTypes=${request.dataTypes}")

            // Extract typed records from request DTO
            val records = request.dataTypes.map { dataTypeDto ->
                when (dataTypeDto) {
                    HealthDataTypeDto.STEPS -> {
                        requireNotNull(request.stepsRecords) { "stepsRecords must not be null for STEPS type" }
                        request.stepsRecords.map { it.toHealthConnect() }
                    }

                    HealthDataTypeDto.WEIGHT -> {
                        requireNotNull(request.weightRecords) { "weightRecords must not be null for WEIGHT type" }
                        request.weightRecords.map { it.toHealthConnect() }
                    }
                }
            }.flatten()

            // Atomic batch write using Health Connect's ACID transaction
            val response = client.insertRecords(records)
            val recordIds = response.recordIdsList

            Log.d(TAG, "Successfully wrote ${recordIds.size} records")

            return WriteRecordsResponseDto(recordIds = recordIds)
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while writing records", e)
            val recordsCount = request.stepsRecords?.size ?: request.weightRecords?.size ?: 0
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while writing records (dataTypes=${request.dataTypes}, count=$recordsCount): ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while writing records", e)
            val recordsCount = request.stepsRecords?.size ?: request.weightRecords?.size ?: 0
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to write records (dataTypes=${request.dataTypes}, count=$recordsCount): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Updates a single health record.
     *
     * @param request Contains the data type and the typed record to update
     * @return UpdateRecordResponseDto containing the updated record ID (same as input)
     *
     * @throws HealthConnectorError with code `INVALID_ARGUMENT` if record ID is invalid
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun updateRecord(request: UpdateRecordRequestDto): UpdateRecordResponseDto {
        try {
            Log.d(TAG, "Updating single record: dataType=${request.dataType}")

            // Extract typed record from request DTO
            val record = when (request.dataType) {
                HealthDataTypeDto.STEPS -> {
                    requireNotNull(request.stepsRecord) { "stepsRecord must not be null for STEPS type" }
                    val stepsRecord = request.stepsRecord
                    // Validate record ID is not empty or "none"
                    if (stepsRecord.id.isEmpty() || stepsRecord.id == "none") {
                        throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(
                            details = "Record ID must be a valid existing ID for update operations. Use writeRecord() for new records."
                        )
                    }
                    stepsRecord.toHealthConnect()
                }

                HealthDataTypeDto.WEIGHT -> {
                    requireNotNull(request.weightRecord) { "weightRecord must not be null for WEIGHT type" }
                    val weightRecord = request.weightRecord
                    // Validate record ID is not empty or "none"
                    if (weightRecord.id.isEmpty() || weightRecord.id == "none") {
                        throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(
                            details = "Record ID must be a valid existing ID for update operations. Use writeRecord() for new records."
                        )
                    }
                    weightRecord.toHealthConnect()
                }
            }

            // Update record using Health Connect's updateRecords API
            client.updateRecords(listOf(record))
            val recordId = record.metadata.id

            Log.d(TAG, "Successfully updated record with ID: $recordId")

            return UpdateRecordResponseDto(recordId = recordId)
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "Invalid argument while updating record", e)
            throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(
                details = "Invalid record data for update (dataType=${request.dataType}): ${e.message ?: "Invalid argument"}",
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while updating record", e)
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while updating record (dataType=${request.dataType}): ${e.message ?: "Access denied"}",
            )
        } catch (e: HealthConnectorError) {
            // Re-throw HealthConnectorError as-is
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while updating record", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to update record (dataType=${request.dataType}): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Performs an aggregation query on health records.
     *
     * @param request Contains data type, aggregation metric, and time range
     * @return AggregateResponseDto with aggregated value and data point count
     *
     * @throws HealthConnectorError with code `INVALID_ARGUMENT` if time range or metric is invalid
     * @throws HealthConnectorError with code `SECURITY_ERROR` if authorization is denied
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun aggregate(request: AggregateRequestDto): AggregateResponseDto {
        try {
            Log.d(
                TAG,
                "Aggregating records: dataType=${request.dataType}, metric=${request.aggregationMetric}, startTime=${request.startTime}, endTime=${request.endTime}"
            )

            // Validate time range
            if (request.startTime >= request.endTime) {
                throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(
                    details = "Invalid time range: startTime must be before endTime. startTime=${request.startTime}, endTime=${request.endTime}"
                )
            }

            // Convert metric to Health Connect metric and create aggregate request
            val metric = request.aggregationMetric.toHealthConnectMetric(request.dataType)
            val aggregateRequest = AggregateRequest(
                metrics = setOf(metric),
                timeRangeFilter = TimeRangeFilter.between(
                    Instant.ofEpochMilli(request.startTime),
                    Instant.ofEpochMilli(request.endTime)
                ),
            )

            // Execute aggregate request
            val response = client.aggregate(aggregateRequest)

            // Extract aggregated value from response
            // The result may be null if no data is available in the time range
            val aggregatedValue = response[metric]

            // Convert result to DTO based on data type
            return when (request.dataType) {
                HealthDataTypeDto.STEPS -> {
                    val stepCount = aggregatedValue?.let { it as? Long } ?: 0L
                    val numericDto = stepCount.toNumericDto()
                    AggregateResponseDto(
                        aggregationMetric = request.aggregationMetric,
                        dataType = request.dataType,
                        doubleValue = numericDto.value,
                        massValue = null
                    )
                }

                HealthDataTypeDto.WEIGHT -> {
                    val mass = aggregatedValue?.let { it as? Mass }
                    val massDto = mass?.toDto()
                    AggregateResponseDto(
                        aggregationMetric = request.aggregationMetric,
                        dataType = request.dataType,
                        doubleValue = null,
                        massValue = massDto
                    )
                }
            }
        } catch (e: IllegalArgumentException) {
            Log.e(TAG, "Invalid argument during aggregation", e)
            throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(details = e.message)
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error during aggregation", e)
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while aggregating records (dataType=${request.dataType}, metric=${request.aggregationMetric}): ${e.message ?: "Access denied"}",
            )
        } catch (e: HealthConnectorError) {
            // Re-throw HealthConnectorError as-is
            throw e
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error during aggregation", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to aggregate records (dataType=${request.dataType}, metric=${request.aggregationMetric}): ${e.message ?: "Unknown error"}",
            )
        }
    }

    /**
     * Deletes all records of a data type within a time range.
     *
     * @param request Contains data type and time range for deletion
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if deletion fails
     */
    @Throws(HealthConnectorError::class)
    suspend fun deleteRecordsByTimeRange(request: DeleteRecordsByTimeRangeRequestDto) {
        Log.d(
            TAG, "Deleting records by time range: dataType=${request.dataType}, " +
                    "startTime=${request.startTime}, endTime=${request.endTime}"
        )

        try {
            val recordClass = request.dataType.toHealthConnectRecordClass()
            val timeRangeFilter = TimeRangeFilter.between(
                Instant.ofEpochMilli(request.startTime),
                Instant.ofEpochMilli(request.endTime)
            )

            client.deleteRecords(
                recordType = recordClass,
                timeRangeFilter = timeRangeFilter,
            )

            Log.d(TAG, "Successfully deleted records by time range")
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while deleting records by time range", e)
            val timeRange = "${request.startTime} to ${request.endTime}"
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while deleting records by time range (dataType=${request.dataType}, timeRange=$timeRange): ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while deleting records by time range", e)
            val timeRange = "${request.startTime} to ${request.endTime}"
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to delete records by time range (dataType=${request.dataType}, timeRange=$timeRange): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Deletes specific records by their IDs.
     *
     * @param request Contains data type and list of record IDs to delete
     * @throws HealthConnectorError with code `SECURITY_ERROR` if permission access is denied
     * @throws HealthConnectorError with code `UNKNOWN` if deletion fails
     */
    @Throws(HealthConnectorError::class)
    suspend fun deleteRecordsByIds(request: DeleteRecordsByIdsRequestDto) {
        Log.d(TAG, "Deleting ${request.recordIds.size} records by ID: dataType=${request.dataType}")

        try {
            val recordClass = request.dataType.toHealthConnectRecordClass()

            client.deleteRecords(
                recordType = recordClass,
                recordIdsList = request.recordIds,
                clientRecordIdsList = emptyList(),
            )

            Log.d(TAG, "Successfully deleted ${request.recordIds.size} records by IDs")
        } catch (e: SecurityException) {
            Log.e(TAG, "Security error while deleting records by IDs", e)
            val recordIdsCount = request.recordIds.size
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while deleting records by IDs (dataType=${request.dataType}, recordIdsCount=$recordIdsCount): ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while deleting records by IDs", e)
            val recordIdsCount = request.recordIds.size
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to delete records by IDs (dataType=${request.dataType}, recordIdsCount=$recordIdsCount): ${e.message ?: "Unknown error"}")
        }
    }

    /**
     * Gets all permissions that have been granted to the app.
     *
     * @return [PermissionsRequestResponseDto] containing separate lists for health data and feature permissions
     *         that have been granted
     *
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun getGrantedPermissions(): PermissionsRequestResponseDto {
        try {
            Log.d(TAG, "Getting granted permissions...")

            // Get granted permissions from Health Connect SDK
            val grantedPermissionStrings = client.permissionController.getGrantedPermissions()

            Log.d(TAG, "Health Connect SDK returned ${grantedPermissionStrings.size} granted permissions")

            // Convert permission strings back to DTOs
            val healthDataPermissions = mutableListOf<HealthDataPermissionRequestResultDto>()
            val featurePermissions = mutableListOf<HealthPlatformFeaturePermissionRequestResultDto>()

            for (permissionString in grantedPermissionStrings) {
                // Try to parse as health data permission
                val healthDataPermission = permissionString.toHealthDataPermissionDto()
                if (healthDataPermission != null) {
                    healthDataPermissions.add(
                        HealthDataPermissionRequestResultDto(
                            permission = healthDataPermission,
                            status = PermissionStatusDto.GRANTED
                        )
                    )
                    continue
                }

                // Try to parse as feature permission
                val featurePermission = permissionString.toHealthPlatformFeatureDto()
                if (featurePermission != null) {
                    featurePermissions.add(
                        HealthPlatformFeaturePermissionRequestResultDto(
                            feature = featurePermission,
                            status = PermissionStatusDto.GRANTED
                        )
                    )
                }
            }

            Log.d(
                TAG,
                "Converted to ${healthDataPermissions.size} health data permissions and ${featurePermissions.size} feature permissions"
            )

            return PermissionsRequestResponseDto(
                healthDataPermissionResults = healthDataPermissions,
                featurePermissionResults = featurePermissions
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while getting granted permissions", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to get granted permissions: ${e.message}",
            )
        }
    }

    /**
     * Revokes all permissions that have been granted to the app.
     *
     * @throws HealthConnectorError with code `UNKNOWN` if an unexpected error occurs
     */
    @Throws(HealthConnectorError::class)
    suspend fun revokeAllPermissions() {
        try {
            Log.d(TAG, "Revoking all permissions...")

            // Revoke all permissions using Health Connect SDK
            client.permissionController.revokeAllPermissions()

            Log.d(TAG, "Successfully revoked all permissions")
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while revoking all permissions", e)
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to revoke all permissions: ${e.message}",
            )
        }
    }
}

