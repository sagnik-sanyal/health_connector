package com.phamtunglam.health_connector_hc_android.mappers

import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.FloorsClimbedRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataPermissionDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataTypeDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeatureDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionAccessTypeDto

/**
 * Converts a [HealthDataPermissionDto] to a Health Connect permission string.
 *
 * @receiver The [HealthDataPermissionDto] to convert
 * @return The Health Connect permission string corresponding to the DTO
 */
internal fun HealthDataPermissionDto.toHealthConnectPermission(): String {
    return when (this.healthDataType) {
        HealthDataTypeDto.ACTIVE_CALORIES_BURNED -> {
            when (this.accessType) {
                PermissionAccessTypeDto.READ -> HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class)
                PermissionAccessTypeDto.WRITE -> HealthPermission.getWritePermission(ActiveCaloriesBurnedRecord::class)
            }
        }

        HealthDataTypeDto.STEPS -> {
            when (this.accessType) {
                PermissionAccessTypeDto.READ -> HealthPermission.getReadPermission(StepsRecord::class)
                PermissionAccessTypeDto.WRITE -> HealthPermission.getWritePermission(StepsRecord::class)
            }
        }

        HealthDataTypeDto.WEIGHT -> {
            when (this.accessType) {
                PermissionAccessTypeDto.READ -> HealthPermission.getReadPermission(WeightRecord::class)
                PermissionAccessTypeDto.WRITE -> HealthPermission.getWritePermission(WeightRecord::class)
            }
        }

        HealthDataTypeDto.DISTANCE -> {
            when (this.accessType) {
                PermissionAccessTypeDto.READ -> HealthPermission.getReadPermission(DistanceRecord::class)
                PermissionAccessTypeDto.WRITE -> HealthPermission.getWritePermission(DistanceRecord::class)
            }
        }

        HealthDataTypeDto.FLOORS_CLIMBED -> {
            when (this.accessType) {
                PermissionAccessTypeDto.READ -> HealthPermission.getReadPermission(FloorsClimbedRecord::class)
                PermissionAccessTypeDto.WRITE -> HealthPermission.getWritePermission(FloorsClimbedRecord::class)
            }
        }
    }
}

/**
 * Converts a Health Connect permission string back to a [HealthDataPermissionDto].
 *
 * @receiver The Health Connect permission string to parse
 * @return The corresponding [HealthDataPermissionDto], or null if the permission string
 *         doesn't match a known health data permission format
 */
internal fun String.toHealthDataPermissionDto(): HealthDataPermissionDto? {
    // Health Connect permission strings follow the pattern:
    // android.permission.health.READ_STEPS, android.permission.health.WRITE_WEIGHT, etc.
    val prefix = "android.permission.health."
    if (!this.startsWith(prefix)) {
        return null
    }

    val suffix = this.removePrefix(prefix)
    val parts = suffix.split("_", limit = 2)
    if (parts.size != 2) {
        return null
    }

    val accessTypeStr = parts[0] // READ or WRITE
    val dataTypeStr = parts[1] // STEPS, WEIGHT, etc.

    val accessType = when (accessTypeStr) {
        "READ" -> PermissionAccessTypeDto.READ
        "WRITE" -> PermissionAccessTypeDto.WRITE
        else -> return null
    }

    val dataType = when (dataTypeStr) {
        "ACTIVE_CALORIES_BURNED" -> HealthDataTypeDto.ACTIVE_CALORIES_BURNED
        "STEPS" -> HealthDataTypeDto.STEPS
        "WEIGHT" -> HealthDataTypeDto.WEIGHT
        "DISTANCE" -> HealthDataTypeDto.DISTANCE
        "FLOORS_CLIMBED" -> HealthDataTypeDto.FLOORS_CLIMBED
        else -> return null // Unknown data type, skip it
    }

    return HealthDataPermissionDto(healthDataType = dataType, accessType = accessType)
}

/**
 * Converts a Health Platform Feature DTO to a Health Connect permission string.
 *
 * @receiver The [HealthPlatformFeatureDto] to convert
 * @return The Health Connect permission string corresponding to the feature
 */
internal fun HealthPlatformFeatureDto.toHealthConnectPermission(): String {
    return when (this) {
        HealthPlatformFeatureDto.READ_HEALTH_DATA_IN_BACKGROUND -> "android.permission.health.READ_HEALTH_DATA_IN_BACKGROUND"
        HealthPlatformFeatureDto.READ_HEALTH_DATA_HISTORY -> "android.permission.health.READ_HEALTH_DATA_HISTORY"
    }
}

/**
 * Converts a Health Connect permission string back to a [HealthPlatformFeatureDto].
 *
 * @receiver The Health Connect permission string to parse
 * @return The corresponding [HealthPlatformFeatureDto], or null if the permission string
 *         doesn't match a known feature permission format
 */
internal fun String.toHealthPlatformFeatureDto(): HealthPlatformFeatureDto? {
    return when (this) {
        "android.permission.health.READ_HEALTH_DATA_IN_BACKGROUND" -> HealthPlatformFeatureDto.READ_HEALTH_DATA_IN_BACKGROUND
        "android.permission.health.READ_HEALTH_DATA_HISTORY" -> HealthPlatformFeatureDto.READ_HEALTH_DATA_HISTORY
        else -> null
    }
}

