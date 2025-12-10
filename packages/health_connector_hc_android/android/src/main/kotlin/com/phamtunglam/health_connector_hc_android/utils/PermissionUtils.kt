package com.phamtunglam.health_connector_hc_android.utils

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.health.connect.client.PermissionController
import com.phamtunglam.health_connector_hc_android.mappers.toError
import com.phamtunglam.health_connector_hc_android.mappers.toHealthConnectPermission
import com.phamtunglam.health_connector_hc_android.pigeon.HealthConnectorError
import com.phamtunglam.health_connector_hc_android.pigeon.HealthConnectorErrorCodeDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataPermissionDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataPermissionRequestResultDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeatureDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthPlatformFeaturePermissionRequestResultDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionStatusDto
import com.phamtunglam.health_connector_hc_android.pigeon.PermissionsRequestDto
import kotlinx.coroutines.CompletableDeferred

/**
 * Utility object for handling Health Connect permission operations.
 *
 * This object provides helper methods for validating permissions, requesting permissions,
 * and building permission results.
 */
internal object PermissionUtils {
    /**
     * Tag used for logging throughout the permission utilities.
     */
    private val TAG = PermissionUtils::class.simpleName

    /**
     * Key used for registering the permission request activity result contract.
     */
    private const val PERMISSION_REQUEST_KEY = "health_connector_plugin"

    /**
     * Validates that a single feature permission is declared in AndroidManifest.xml.
     *
     * @param context The Android application context
     * @param feature The feature to validate
     *
     * @throws HealthConnectorError with code `INVALID_PLATFORM_CONFIGURATION` if the feature permission
     *         is not declared in AndroidManifest.xml.
     */
    @Throws(HealthConnectorError::class)
    fun validateFeaturePermissionDeclaredInManifest(
        context: Context,
        feature: HealthPlatformFeatureDto,
    ) {
        Log.d(TAG, "Validating feature permission declared in AndroidManifest for: $feature")

        // Get all permissions declared in AndroidManifest
        val definedPermissions = context.packageManager.getPackageInfo(
            context.packageName, PackageManager.GET_PERMISSIONS
        ).requestedPermissions.orEmpty().toSet()

        // Convert feature to Health Connect permission string
        val featurePermissionString = feature.toHealthConnectPermission()

        // Check if the feature permission is declared
        if (!definedPermissions.contains(featurePermissionString)) {
            val errorMessage =
                "Feature permission '$featurePermissionString' for $feature is not declared in AndroidManifest.xml"
            Log.e(TAG, errorMessage)
            throw HealthConnectorErrorCodeDto.INVALID_PLATFORM_CONFIGURATION.toError(
                details = "Please add the permission '$featurePermissionString' to your AndroidManifest.xml file.",
            )
        }

        Log.d(TAG, "Feature permission for $feature is properly declared in AndroidManifest")
    }

    /**
     * Validates that all requested permissions and features are declared in AndroidManifest.xml.
     *
     * This method checks if the permissions/features being requested have been properly declared
     * in the app's AndroidManifest.xml file. This is required for the permission request to succeed.
     *
     * @param context The Android application context
     * @param request The permissions request containing health data and feature permissions to validate
     *
     * @throws IllegalStateException if any requested permissions/features are not declared in 
     *         AndroidManifest.xml. The error message lists all missing declarations.
     */
    @Throws(IllegalStateException::class)
    fun validatePermissionsDeclaredInManifest(
        context: Context,
        request: PermissionsRequestDto,
    ) {
        Log.d(TAG, "Validating permissions declared in AndroidManifest...")

        // Get all permissions declared in AndroidManifest
        val definedPermissions = context.packageManager.getPackageInfo(
            context.packageName, PackageManager.GET_PERMISSIONS
        ).requestedPermissions.orEmpty().toSet()

        Log.d(TAG, "Found ${definedPermissions.size} permissions declared in AndroidManifest")

        // Convert DTOs to Health Connect permission strings
        val healthDataPermissionStrings = request.healthDataPermissions.map { it.toHealthConnectPermission() }
        val featurePermissionStrings = request.featurePermissions.map { it.toHealthConnectPermission() }
        val allRequestedPermissions = healthDataPermissionStrings + featurePermissionStrings

        // Partition into defined and not defined
        val (defined, notDefined) = allRequestedPermissions.partition {
            definedPermissions.contains(it)
        }

        Log.d(TAG, "Validation result: ${defined.size} defined, ${notDefined.size} not defined")

        // Throw error if any permissions are not defined
        if (notDefined.isNotEmpty()) {
            val errorMessage = "The following permissions/features are not declared in AndroidManifest.xml: ${notDefined.joinToString(", ")}. " +
                "Please add these permissions to your AndroidManifest.xml file. " +
                "Defined permissions: ${defined.joinToString(", ")}"
            Log.e(TAG, errorMessage)
            throw IllegalStateException(errorMessage)
        }

        Log.d(TAG, "All requested permissions are properly declared in AndroidManifest")
    }

    /**
     * Requests permissions from the Android system via Health Connect SDK.
     *
     * @param activity The activity to launch the permission request dialog
     * @param request The permissions to request
     * @return Set of granted permission strings
     */
    suspend fun requestPermissionsFromSystem(
        activity: ComponentActivity,
        request: PermissionsRequestDto,
    ): Set<String> {
        // Convert DTOs to Health Connect permission strings
        val healthDataPermissionStrings = request.healthDataPermissions.map { it.toHealthConnectPermission() }
        val featurePermissionStrings = request.featurePermissions.map { it.toHealthConnectPermission() }
        val allPermissions = healthDataPermissionStrings.union(featurePermissionStrings)

        Log.d(TAG, "Launching permission request for ${allPermissions.size} permissions")

        // Launch permission request and wait for result
        val completer = CompletableDeferred<Set<String>>()
        val contract = PermissionController.createRequestPermissionResultContract()
        val launcher = activity.activityResultRegistry.register(
            PERMISSION_REQUEST_KEY,
            contract,
        ) { grantedPermissions -> completer.complete(grantedPermissions) }

        launcher.launch(allPermissions)
        val grantedPermissions = completer.await()

        Log.d(TAG, "Permission request completed: ${grantedPermissions.size} granted")
        return grantedPermissions
    }

    /**
     * Maps health data permission DTOs to their request results based on granted permissions.
     *
     * @param requestedPermissions The health data permissions that were requested
     * @param grantedPermissions The set of permission strings that were granted
     * @return List of health data permission results
     */
    fun buildHealthDataPermissionResults(
        requestedPermissions: List<HealthDataPermissionDto>,
        grantedPermissions: Set<String>,
    ): List<HealthDataPermissionRequestResultDto> {
        return requestedPermissions.map { permissionDto ->
            HealthDataPermissionRequestResultDto(
                permission = permissionDto,
                status = determinePermissionStatus(permissionDto.toHealthConnectPermission(), grantedPermissions)
            )
        }
    }

    /**
     * Maps feature DTOs to their permission request results based on granted permissions.
     *
     * @param requestedFeatures The features for which permissions were requested
     * @param grantedPermissions The set of permission strings that were granted
     * @return List of feature permission results
     */
    fun buildFeaturePermissionResults(
        requestedFeatures: List<HealthPlatformFeatureDto>,
        grantedPermissions: Set<String>,
    ): List<HealthPlatformFeaturePermissionRequestResultDto> {
        return requestedFeatures.map { featureDto ->
            HealthPlatformFeaturePermissionRequestResultDto(
                feature = featureDto,
                status = determinePermissionStatus(featureDto.toHealthConnectPermission(), grantedPermissions)
            )
        }
    }

    /**
     * Determines if a permission was granted based on the granted permission set.
     *
     * @param permissionString The Health Connect permission string to check
     * @param grantedPermissions The set of granted permission strings
     * @return [PermissionStatusDto.GRANTED] if the permission was granted, [PermissionStatusDto.DENIED] otherwise
     */
    fun determinePermissionStatus(
        permissionString: String,
        grantedPermissions: Set<String>,
    ): PermissionStatusDto {
        return if (permissionString in grantedPermissions) {
            PermissionStatusDto.GRANTED
        } else {
            PermissionStatusDto.DENIED
        }
    }
}

