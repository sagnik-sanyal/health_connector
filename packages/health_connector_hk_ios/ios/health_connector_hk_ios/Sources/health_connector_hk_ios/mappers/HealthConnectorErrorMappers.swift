import Foundation

/**
 * Extension functions for creating standardized [HealthConnectorError] instances used throughout the Health Connector plugin.
 */

/**
 * Extension to provide string representation for `HealthConnectorErrorCodeDto`.
 *
 * This extension adds a `stringValue` property to convert enum cases to their
 * uppercase string representation, matching the Android .name property behavior.
 */
extension HealthConnectorErrorCodeDto {
    /**
     * Returns the uppercase string representation of the error code.
     *
     * This matches the Android implementation where `HealthConnectorErrorCodeDto.UNKNOWN.name`
     * returns "UNKNOWN". Used when creating `HealthConnectorError` instances.
     *
     * - Returns: Uppercase string representation of the error code
     */
    var stringValue: String {
        switch self {
        case .unknown:
            return "UNKNOWN"
        case .healthPlatformUnavailable:
            return "HEALTH_PLATFORM_UNAVAILABLE"
        case .unsupportedHealthPlatformApi:
            return "UNSUPPORTED_HEALTH_PLATFORM_API"
        case .invalidPlatformConfiguration:
            return "INVALID_PLATFORM_CONFIGURATION"
        case .invalidArgument:
            return "INVALID_ARGUMENT"
        case .securityError:
            return "SECURITY_ERROR"
        }
    }
}

/**
 * Creates a [HealthConnectorError] from this error code with the appropriate message.
 *
 * - Parameter details: Additional error details such as the original exception information or
 *                      suggested actions for the user.
 * - Returns: A [HealthConnectorError] instance with the appropriate error code and message.
 */
extension HealthConnectorErrorCodeDto {
    func toError(details: Any? = nil) -> HealthConnectorError {
        let message: String
        switch self {
        case .healthPlatformUnavailable:
            message = "HealthKit is unavailable"
        case .invalidPlatformConfiguration:
            message = "Invalid platform configuration"
        case .unknown:
            message = "An unknown error occurred"
        case .securityError:
            message = "Security/permission error: Access denied or insufficient permissions"
        case .invalidArgument:
            message = "Invalid argument: Input validation failed"
        case .unsupportedHealthPlatformApi:
            message = "Unsupported health platform API"
        }
        return HealthConnectorError(code: stringValue, message: message, details: details)
    }
}

/**
 * Factory for creating standardized error instances used throughout the Health Connector plugin.
 *
 * This struct provides methods to create `HealthConnectorError` instances with consistent error codes
 * and messages that mirror the Android implementation.
 */
internal struct HealthConnectorErrors {
    /**
     * Creates a `HealthConnectorError` indicating that HealthKit is unavailable on the device.
     *
     * Common scenarios include:
     * - HealthKit is not supported on the device (e.g., iPad without health capabilities)
     * - The device is in a restricted mode
     * - HealthKit framework is unavailable
     *
     * - Parameters:
     *   - message: Custom error message. If provided, it will be appended to the default message with `: ` separator
     *   - details: Additional error details such as underlying exception information.
     *              Can be any type that conforms to `Sendable`.
     * - Returns: A `HealthConnectorError` instance with error code `HEALTH_PLATFORM_UNAVAILABLE`
     */
    static func healthPlatformUnavailable(message: String? = nil, details: Sendable? = nil) -> HealthConnectorError {
        return HealthConnectorError(
            code: HealthConnectorErrorCodeDto.healthPlatformUnavailable.stringValue,
            message: "HealthKit is unavailable\(getMessageOrEmpty(message))",
            details: details
        )
    }

    /**
     * Creates a `HealthConnectorError` for unexpected or uncategorized errors.
     *
     * This error serves as a catch-all for exceptions that don't fit into other specific error categories.
     * It should be used when:
     * - An unexpected exception is caught that doesn't have a specific error type
     * - An error occurs that cannot be properly categorized
     * - A generic error needs to be propagated to Flutter without additional context
     *
     * - Parameters:
     *   - message: Custom error message. If provided, it will be appended to the default message with `: ` separator
     *   - details: Additional error details such as the original exception information.
     * - Returns: A `HealthConnectorError` instance
     */
    static func unknown(message: String? = nil, details: Sendable? = nil) -> HealthConnectorError {
        return HealthConnectorError(
            code: HealthConnectorErrorCodeDto.unknown.stringValue,
            message: "An unknown error occurred\(getMessageOrEmpty(message))",
            details: details
        )
    }

    /**
     * Creates a `HealthConnectorError` indicating that the requested API or feature is not supported
     * on the current health platform.
     *
     * This error should be used when:
     * - A platform-specific API is called on an unsupported platform
     * - A feature is requested that isn't available on iOS HealthKit
     * - An operation is attempted that only works on Android Health Connect
     *
     * - Parameters:
     *   - message: Custom error message. If provided, it will be appended to the default message with `: ` separator
     *   - details: Additional error details such as information about the unsupported API.
     *              Can be any type that conforms to `Sendable`.
     * - Returns: A `HealthConnectorError` instance with error code `UNSUPPORTED_HEALTH_PLATFORM_API`
     */
    static func unsupportedHealthPlatformApi(message: String? = nil, details: Sendable? = nil) -> HealthConnectorError {
        return HealthConnectorError(
            code: HealthConnectorErrorCodeDto.unsupportedHealthPlatformApi.stringValue,
            message: "Unsupported health platform API\(getMessageOrEmpty(message))",
            details: details
        )
    }

    /**
     * Creates a `HealthConnectorError` for invalid platform configuration issues.
     *
     * This error is used when the native platform is not properly configured to use the health platform.
     * Common scenarios include:
     * - Missing required permissions in Info.plist
     * - Incorrect Info.plist declarations
     *
     * - Parameters:
     *   - message: Custom error message. If provided, it will be appended to the default message with `: ` separator
     *   - details: Additional error details such as which specific permissions are missing or
     *              what configuration needs to be added.
     * - Returns: A `HealthConnectorError` instance with error code `INVALID_PLATFORM_CONFIGURATION`
     */
    static func invalidPlatformConfiguration(message: String? = nil, details: Sendable? = nil) -> HealthConnectorError {
        return HealthConnectorError(
            code: HealthConnectorErrorCodeDto.invalidPlatformConfiguration.stringValue,
            message: "Invalid platform configuration\(getMessageOrEmpty(message))",
            details: details
        )
    }

    /**
     * Creates a `HealthConnectorError` for invalid argument or input validation errors.
     *
     * This error occurs when invalid input is provided to a method, such as:
     * - Invalid record ID format (e.g., malformed UUID)
     * - Invalid time range (e.g., start time after end time)
     * - Invalid record data (e.g., negative values where not allowed)
     * - Invalid pagination parameters
     *
     * This error maps to `HKError.invalidArgument` on iOS and `IllegalArgumentException` on Android.
     *
     * - Parameters:
     *   - message: Custom error message. If provided, it will be appended to the default message with `: ` separator
     *   - details: Additional error details such as the original error information
     *              or which specific parameter was invalid.
     * - Returns: A `HealthConnectorError` instance with error code `INVALID_ARGUMENT`
     */
    static func invalidArgument(message: String? = nil, details: Sendable? = nil) -> HealthConnectorError {
        return HealthConnectorError(
            code: HealthConnectorErrorCodeDto.invalidArgument.stringValue,
            message: "Invalid argument: Input validation failed\(getMessageOrEmpty(message))",
            details: details
        )
    }

    /**
     * Creates a `HealthConnectorError` for security/permission errors.
     *
     * This error occurs when a request is made without proper permissions
     * or when access is denied by the health platform.
     *
     * Common scenarios include:
     * - Missing required permissions for the requested operation
     * - User denied permission access
     * - Attempting to access data without proper authorization
     *
     * This error maps to `HKError.errorAuthorizationDenied` on iOS.
     *
     * - Parameters:
     *   - message: Custom error message. If provided, it will be appended to the default message with `: ` separator
     *   - details: Additional error details such as the original error information
     *              or which specific permission was denied.
     * - Returns: A `HealthConnectorError` instance with error code `SECURITY_ERROR`
     */
    static func securityError(message: String? = nil, details: Sendable? = nil) -> HealthConnectorError {
        return HealthConnectorError(
            code: HealthConnectorErrorCodeDto.securityError.stringValue,
            message: "Security error: Permission denied or insufficient access\(getMessageOrEmpty(message))",
            details: details
        )
    }

    private static func getMessageOrEmpty(_ message: String?) -> String {
        return message == nil ? "" : ": \(message!)"
    }
}

