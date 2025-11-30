package com.phamtunglam.health_connector_hc_android

import android.content.Context
import androidx.activity.ComponentActivity
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.BodyFatRecord
import androidx.health.connect.client.records.BodyTemperatureRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.FloorsClimbedRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.HeightRecord
import androidx.health.connect.client.records.HydrationRecord
import androidx.health.connect.client.records.LeanBodyMassRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.WheelchairPushesRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Energy
import androidx.health.connect.client.units.Length
import androidx.health.connect.client.units.Mass
import androidx.health.connect.client.units.Temperature
import androidx.health.connect.client.units.Volume
import com.phamtunglam.health_connector_hc_android.mappers.id
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
import com.phamtunglam.health_connector_hc_android.pigeon.EnergyDto
import com.phamtunglam.health_connector_hc_android.pigeon.EnergyUnitDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthConnectorError
import com.phamtunglam.health_connector_hc_android.pigeon.HealthConnectorErrorCodeDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataPermissionRequestResultDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataTypeDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeatureDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeaturePermissionRequestResultDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeatureStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.LengthDto
import com.phamtunglam.health_connector_hc_android.pigeon.LengthUnitDto
import com.phamtunglam.health_connector_hc_android.pigeon.MassDto
import com.phamtunglam.health_connector_hc_android.pigeon.MassUnitDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionsRequestResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.ReadRecordsResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.TemperatureDto
import com.phamtunglam.health_connector_hc_android.pigeon.TemperatureUnitDto
import com.phamtunglam.health_connector_hc_android.pigeon.UpdateRecordRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.UpdateRecordResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.VolumeDto
import com.phamtunglam.health_connector_hc_android.pigeon.VolumeUnitDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordResponseDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordsRequestDto
import com.phamtunglam.health_connector_hc_android.pigeon.WriteRecordsResponseDto
import com.phamtunglam.health_connector_hc_android.utils.HealthConnectorLogger
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
                return HealthConnectorClient(HealthConnectClient.getOrCreate(context))
            } catch (e: UnsupportedOperationException) {
                HealthConnectorLogger.error(
                    tag = TAG ?: "HealthConnectorClient",
                    operation = "getOrCreate",
                    phase = "failed",
                    message = "Failed to create Health Connect client due to SDK version too low or running in a profile mode",
                    exception = e,
                )
                throw HealthConnectorErrorCodeDto.INSTALLATION_OR_UPDATE_REQUIRED.toError(details = e.message)
            } catch (e: IllegalStateException) {
                HealthConnectorLogger.error(
                    tag = TAG ?: "HealthConnectorClient",
                    operation = "getOrCreate",
                    phase = "failed",
                    message = "Failed to create Health Connect client due to service not available",
                    exception = e,
                )
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
            HealthConnectorLogger.debug(
                tag = TAG ?: "HealthConnectorClient",
                operation = "getHealthPlatformStatus",
                phase = "entry",
                message = "Getting Health Connect SDK status",
            )

            val statusCode = HealthConnectClient.getSdkStatus(context)
            val statusDto = statusCode.toHealthPlatformStatusDto()

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "getHealthPlatformStatus",
                phase = "completed",
                message = "Health Connect platform status retrieved",
                context = mapOf(
                    "status_code" to statusCode,
                    "status_dto" to statusDto,
                ),
            )

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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "requestPermissions",
            phase = "entry",
            message = "Requesting Health Connect permissions",
            context = mapOf(
                "requested_health_data_permissions" to request.healthDataPermissions,
                "requested_feature_permissions" to request.featurePermissions,
            ),
        )

        try {
            // Validate that all requested permissions are declared in AndroidManifest
            PermissionUtils.validatePermissionsDeclaredInManifest(activity.applicationContext, request)

            val grantedPermissions = PermissionUtils.requestPermissionsFromSystem(activity, request)

            val healthDataResults = PermissionUtils.buildHealthDataPermissionResults(
                request.healthDataPermissions, grantedPermissions
            )
            val featureResults = PermissionUtils.buildFeaturePermissionResults(
                request.featurePermissions, grantedPermissions
            )

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "requestPermissions",
                phase = "completed",
                message = "Health Connect permissions requested successfully",
                context = mapOf(
                    "granted_health_data_permissions" to healthDataResults,
                    "granted_feature_permissions" to featureResults,
                ),
            )

            return PermissionsRequestResponseDto(
                healthDataPermissionResults = healthDataResults, featurePermissionResults = featureResults
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "requestPermissions",
                phase = "failed",
                message = "Failed to request Health Connect permissions",
                context = mapOf(
                    "requested_permissions" to mapOf(
                        "health_data_permissions" to request.healthDataPermissions,
                        "feature_permissions" to request.featurePermissions,
                    ),
                ),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to process $request : ${e.message ?: "Unknown error"}",
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "getFeatureStatus",
            phase = "entry",
            message = "Checking Health Connect feature status",
            context = mapOf("feature" to feature),
        )

        try {
            // Validate that the feature permission is declared in AndroidManifest
            PermissionUtils.validateFeaturePermissionDeclaredInManifest(context, feature)

            // Map HealthPlatformFeatureDto to Health Connect feature constants
            val healthConnectFeature = feature.toHealthConnectFeature()

            // Check feature status using Health Connect SDK
            val statusCode = client.features.getFeatureStatus(healthConnectFeature)

            // Map Health Connect status to HealthPlatformFeatureStatusDto
            val statusDto = statusCode.toHealthPlatformFeatureStatusDto()

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "getFeatureStatus",
                phase = "completed",
                message = "Health Connect feature status retrieved",
                context = mapOf(
                    "feature" to feature,
                    "status" to statusDto,
                ),
            )

            return statusDto
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "getFeatureStatus",
                phase = "failed",
                message = "Failed to get Health Connect feature status",
                context = mapOf("feature" to feature),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to get feature status for $feature: ${e.message ?: "Unknown error"}",
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
    suspend fun readRecord(request: ReadRecordRequestDto): ReadRecordResponseDto {
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "readRecord",
            phase = "entry",
            message = "Reading Health Connect record",
            context = mapOf("request" to request),
        )

        try {
            val recordClass = request.dataType.toHealthConnectRecordClass()
            val response = client.readRecord(recordClass, request.recordId)

            // Convert SDK record to DTO using typed mappers
            val recordDto = when (request.dataType) {
                HealthDataTypeDto.ACTIVE_CALORIES_BURNED -> {
                    val record = response.record as ActiveCaloriesBurnedRecord
                    record.toDto()
                }

                HealthDataTypeDto.DISTANCE -> {
                    val record = response.record as DistanceRecord
                    record.toDto()
                }

                HealthDataTypeDto.FLOORS_CLIMBED -> {
                    val record = response.record as FloorsClimbedRecord
                    record.toDto()
                }

                HealthDataTypeDto.STEPS -> {
                    val record = response.record as StepsRecord
                    record.toDto()
                }

                HealthDataTypeDto.WEIGHT -> {
                    val record = response.record as WeightRecord
                    record.toDto()
                }

                HealthDataTypeDto.HEIGHT -> {
                    val record = response.record as HeightRecord
                    record.toDto()
                }

                HealthDataTypeDto.HYDRATION -> {
                    val record = response.record as HydrationRecord
                    record.toDto()
                }

                HealthDataTypeDto.LEAN_BODY_MASS -> {
                    val record = response.record as LeanBodyMassRecord
                    record.toDto()
                }

                HealthDataTypeDto.BODY_FAT_PERCENTAGE -> {
                    val record = response.record as BodyFatRecord
                    record.toDto()
                }

                HealthDataTypeDto.BODY_TEMPERATURE -> {
                    val record = response.record as BodyTemperatureRecord
                    record.toDto()
                }

                HealthDataTypeDto.WHEELCHAIR_PUSHES -> {
                    val record = response.record as WheelchairPushesRecord
                    record.toDto()
                }

                HealthDataTypeDto.HEART_RATE_SERIES_RECORD -> {
                    val record = response.record as HeartRateRecord
                    record.toDto()
                }

                HealthDataTypeDto.SLEEP_SESSION -> {
                    val record = response.record as SleepSessionRecord
                    record.toDto()
                }
            }

            val responseDto = ReadRecordResponseDto(record = recordDto)

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "readRecord",
                phase = "completed",
                message = "Health Connect record read successfully",
                context = mapOf(
                    "request" to request,
                    "response" to responseDto,
                ),
            )

            return responseDto
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "readRecord",
                phase = "failed",
                message = "Failed to read Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "readRecord",
                phase = "failed",
                message = "Failed to read Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "readRecords",
            phase = "entry",
            message = "Reading Health Connect records",
            context = mapOf("request" to request),
        )

        try {
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
            val nextPageToken = if (response.pageToken.isNullOrEmpty()) {
                null
            } else response.pageToken

            // Convert SDK records to DTOs using typed mappers
            val recordDtos = when (request.dataType) {
                HealthDataTypeDto.ACTIVE_CALORIES_BURNED -> {
                    response.records.map { (it as ActiveCaloriesBurnedRecord).toDto() }
                }

                HealthDataTypeDto.DISTANCE -> {
                    response.records.map { (it as DistanceRecord).toDto() }
                }

                HealthDataTypeDto.FLOORS_CLIMBED -> {
                    response.records.map { (it as FloorsClimbedRecord).toDto() }
                }

                HealthDataTypeDto.STEPS -> {
                    response.records.map { (it as StepsRecord).toDto() }
                }

                HealthDataTypeDto.WEIGHT -> {
                    response.records.map { (it as WeightRecord).toDto() }
                }

                HealthDataTypeDto.HEIGHT -> {
                    response.records.map { (it as HeightRecord).toDto() }
                }

                HealthDataTypeDto.HYDRATION -> {
                    response.records.map { (it as HydrationRecord).toDto() }
                }

                HealthDataTypeDto.LEAN_BODY_MASS -> {
                    response.records.map { (it as LeanBodyMassRecord).toDto() }
                }

                HealthDataTypeDto.BODY_FAT_PERCENTAGE -> {
                    response.records.map { (it as BodyFatRecord).toDto() }
                }

                HealthDataTypeDto.BODY_TEMPERATURE -> {
                    response.records.map { (it as BodyTemperatureRecord).toDto() }
                }

                HealthDataTypeDto.WHEELCHAIR_PUSHES -> {
                    response.records.map { (it as WheelchairPushesRecord).toDto() }
                }

                HealthDataTypeDto.HEART_RATE_SERIES_RECORD -> {
                    response.records.map { (it as HeartRateRecord).toDto() }
                }

                HealthDataTypeDto.SLEEP_SESSION -> {
                    response.records.map { (it as SleepSessionRecord).toDto() }
                }
            }

            val responseDto = ReadRecordsResponseDto(
                records = recordDtos,
                nextPageToken = nextPageToken
            )

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "readRecords",
                phase = "completed",
                message = "Health Connect records read successfully",
                context = mapOf(
                    "request" to request,
                    "response" to responseDto,
                ),
            )

            return responseDto
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "readRecords",
                phase = "failed",
                message = "Failed to read Health Connect records",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "readRecords",
                phase = "failed",
                message = "Failed to read Health Connect records",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "writeRecord",
            phase = "entry",
            message = "Writing Health Connect record",
            context = mapOf("request" to request),
        )

        try {
            // Convert record DTO to Health Connect Record using extension
            val record: Record = request.record.toHealthConnect()

            // Write to Health Connect using ACID transaction
            val response = client.insertRecords(listOf(record))
            val recordId = response.recordIdsList.first()

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "writeRecord",
                phase = "completed",
                message = "Health Connect record written successfully",
                context = mapOf(
                    "request" to request,
                    "assignedRecordId" to recordId,
                ),
            )

            return WriteRecordResponseDto(recordId = recordId)
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "writeRecord",
                phase = "failed",
                message = "Failed to write Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "writeRecord",
                phase = "failed",
                message = "Failed to write Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "writeRecords",
            phase = "entry",
            message = "Writing Health Connect records",
            context = mapOf("request" to request),
        )

        try {
            // Convert record DTOs to Health Connect Records using extension
            val records = request.records.map { it.toHealthConnect() }

            // Atomic batch write using Health Connect's ACID transaction
            val response = client.insertRecords(records)
            val recordIds = response.recordIdsList

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "writeRecords",
                phase = "completed",
                message = "Health Connect records written successfully",
                context = mapOf(
                    "request" to request,
                    "assignedRecordIds" to recordIds,
                ),
            )

            return WriteRecordsResponseDto(recordIds = recordIds)
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "writeRecords",
                phase = "failed",
                message = "Failed to write Health Connect records",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "writeRecords",
                phase = "failed",
                message = "Failed to write Health Connect records",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "updateRecord",
            phase = "entry",
            message = "Updating Health Connect record",
            context = mapOf("request" to request),
        )

        try {
            val recordDto = request.record
            if (recordDto.id.isNullOrEmpty()) {
                throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(
                    details = "Record ID must be a valid existing ID for update operations. Use writeRecord() for new records."
                )
            }

            // Convert record DTO to Health Connect Record
            val record: Record = recordDto.toHealthConnect()

            client.updateRecords(listOf(record))

            // Retrieve updated record ID from the response metadata
            val recordId = record.metadata.id

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "updateRecord",
                phase = "completed",
                message = "Health Connect record updated successfully",
                context = mapOf("request" to request),
            )

            return UpdateRecordResponseDto(recordId = recordId)
        } catch (e: IllegalArgumentException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "updateRecord",
                phase = "failed",
                message = "Failed to update Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(
                details = "Invalid record data for update: ${e.message ?: "Invalid argument"}",
            )
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "updateRecord",
                phase = "failed",
                message = "Failed to update Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: HealthConnectorError) {
            // Re-throw HealthConnectorError as-is
            throw e
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "updateRecord",
                phase = "failed",
                message = "Failed to update Health Connect record",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "aggregate",
            phase = "entry",
            message = "Aggregating Health Connect data",
            context = mapOf("request" to request),
        )

        try {
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

            // Convert result to MeasurementUnitDto based on data type
            // If no data is available, return default values (0 with appropriate units)
            val valueDto = when (request.dataType) {
                HealthDataTypeDto.ACTIVE_CALORIES_BURNED -> {
                    val energy = aggregatedValue?.let { it as? Energy }
                    energy?.toDto() ?: EnergyDto(
                        value = 0.0,
                        unit = EnergyUnitDto.KILOCALORIES
                    )
                }

                HealthDataTypeDto.DISTANCE -> {
                    val length = aggregatedValue?.let { it as? Length }
                    length?.toDto() ?: LengthDto(
                        value = 0.0,
                        unit = LengthUnitDto.METERS
                    )
                }

                HealthDataTypeDto.HEIGHT -> {
                    val length = aggregatedValue?.let { it as? Length }
                    length?.toDto() ?: LengthDto(
                        value = 0.0,
                        unit = LengthUnitDto.METERS
                    )
                }

                HealthDataTypeDto.HYDRATION -> {
                    val volume = aggregatedValue?.let { it as? Volume }
                    volume?.toDto() ?: VolumeDto(
                        value = 0.0,
                        unit = VolumeUnitDto.LITERS
                    )
                }

                HealthDataTypeDto.FLOORS_CLIMBED -> {
                    val floorsCount = aggregatedValue?.let { it as? Double } ?: 0.0
                    floorsCount.toNumericDto()
                }

                HealthDataTypeDto.STEPS -> {
                    val stepCount = aggregatedValue?.let { it as? Long } ?: 0L
                    stepCount.toNumericDto()
                }

                HealthDataTypeDto.WEIGHT -> {
                    val mass = aggregatedValue?.let { it as? Mass }
                    mass?.toDto() ?: MassDto(
                        value = 0.0,
                        unit = MassUnitDto.KILOGRAMS
                    )
                }

                HealthDataTypeDto.LEAN_BODY_MASS -> {
                    val mass = aggregatedValue?.let { it as? Mass }
                    mass?.toDto() ?: MassDto(
                        value = 0.0,
                        unit = MassUnitDto.KILOGRAMS
                    )
                }

                HealthDataTypeDto.BODY_TEMPERATURE -> {
                    val temperature = aggregatedValue?.let { it as? Temperature }
                    temperature?.toDto() ?: TemperatureDto(
                        value = 0.0,
                        unit = TemperatureUnitDto.CELSIUS
                    )
                }

                HealthDataTypeDto.WHEELCHAIR_PUSHES -> {
                    val pushesCount = aggregatedValue?.let { it as? Long } ?: 0L
                    pushesCount.toNumericDto()
                }

                HealthDataTypeDto.HEART_RATE_SERIES_RECORD -> {
                    val bpmValue = aggregatedValue?.let { it as? Long } ?: 0L
                    bpmValue.toNumericDto()
                }

                HealthDataTypeDto.SLEEP_SESSION -> {
                    // Sleep duration is returned as Duration, convert to seconds
                    val duration = aggregatedValue?.let { it as? java.time.Duration }
                    val seconds = duration?.seconds?.toDouble() ?: 0.0
                    seconds.toNumericDto()
                }

                HealthDataTypeDto.BODY_FAT_PERCENTAGE -> throw IllegalArgumentException(
                    "Body fat percentage data type does not support aggregation"
                )
            }

            val responseDto = AggregateResponseDto(value = valueDto)

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "aggregate",
                phase = "completed",
                message = "Health Connect data aggregated successfully",
                context = mapOf(
                    "request" to request,
                    "response" to responseDto,
                ),
            )

            return responseDto
        } catch (e: IllegalArgumentException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "aggregate",
                phase = "failed",
                message = "Failed to aggregate Health Connect data",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.INVALID_ARGUMENT.toError(details = e.message)
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "aggregate",
                phase = "failed",
                message = "Failed to aggregate Health Connect data",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: HealthConnectorError) {
            // Re-throw HealthConnectorError as-is
            throw e
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "aggregate",
                phase = "failed",
                message = "Failed to aggregate Health Connect data",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to process $request: ${e.message ?: "Unknown error"}",
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "deleteRecords",
            phase = "entry",
            message = "Deleting Health Connect records by time range",
            context = mapOf("request" to request),
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

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecords",
                phase = "completed",
                message = "Health Connect records deleted successfully",
                context = mapOf("request" to request),
            )
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecords",
                phase = "failed",
                message = "Failed to delete Health Connect records",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecords",
                phase = "failed",
                message = "Failed to delete Health Connect records",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "deleteRecordsByIds",
            phase = "entry",
            message = "Deleting Health Connect records by IDs",
            context = mapOf("request" to request),
        )

        if (request.recordIds.isEmpty()) {
            HealthConnectorLogger.warning(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecordsByIds",
                phase = "completed",
                message = "No records to delete (empty IDs list)",
            )
            return
        }

        try {
            val recordClass = request.dataType.toHealthConnectRecordClass()

            client.deleteRecords(
                recordType = recordClass,
                recordIdsList = request.recordIds,
                clientRecordIdsList = emptyList(),
            )

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecordsByIds",
                phase = "completed",
                message = "Health Connect records deleted successfully",
                context = mapOf("request" to request),
            )
        } catch (e: SecurityException) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecordsByIds",
                phase = "failed",
                message = "Failed to delete Health Connect records by IDs",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.SECURITY_ERROR.toError(
                details = "Permission access denied while processing $request: ${e.message ?: "Access denied"}",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "deleteRecordsByIds",
                phase = "failed",
                message = "Failed to delete Health Connect records by IDs",
                context = mapOf("request" to request),
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(details = "Failed to process $request: ${e.message ?: "Unknown error"}")
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "getGrantedPermissions",
            phase = "entry",
            message = "Getting granted Health Connect permissions",
        )

        try {
            // Get granted permissions from Health Connect SDK
            val grantedPermissionStrings = client.permissionController.getGrantedPermissions()

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

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "getGrantedPermissions",
                phase = "completed",
                message = "Granted Health Connect permissions retrieved",
                context = mapOf(
                    "granted_health_data_permissions" to healthDataPermissions,
                    "granted_feature_permissions" to featurePermissions,
                ),
            )

            return PermissionsRequestResponseDto(
                healthDataPermissionResults = healthDataPermissions,
                featurePermissionResults = featurePermissions
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "getGrantedPermissions",
                phase = "failed",
                message = "Failed to get granted Health Connect permissions",
                exception = e,
            )
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
        HealthConnectorLogger.debug(
            tag = TAG ?: "HealthConnectorClient",
            operation = "revokeAllPermissions",
            phase = "entry",
            message = "Revoking all Health Connect permissions",
        )

        try {
            // Revoke all permissions using Health Connect SDK
            client.permissionController.revokeAllPermissions()

            HealthConnectorLogger.info(
                tag = TAG ?: "HealthConnectorClient",
                operation = "revokeAllPermissions",
                phase = "completed",
                message = "All Health Connect permissions revoked successfully",
            )
        } catch (e: Exception) {
            HealthConnectorLogger.error(
                tag = TAG ?: "HealthConnectorClient",
                operation = "revokeAllPermissions",
                phase = "failed",
                message = "Failed to revoke all Health Connect permissions",
                exception = e,
            )
            throw HealthConnectorErrorCodeDto.UNKNOWN.toError(
                details = "Failed to revoke all permissions: ${e.message}",
            )
        }
    }
}

