import 'package:health_connector_annotation/health_connector_annotation.dart'
    show Since, SupportedHealthPlatforms;
import 'package:health_connector_core/src/models/exceptions/health_connector_exception.dart'
    show HealthConnectorException;
import 'package:health_connector_core/src/models/health_platform.dart';

/// Error codes for [HealthConnectorException].
///
/// These codes help identify the specific type of error that occurred.
@Since('0.1.0')
enum HealthConnectorErrorCode {
  /// Unknown or unspecified error.
  unknown('UNKNOWN'),

  /// Health Connect installation or update is required.
  ///
  /// This error occurs when Health Connect is not installed on the device
  /// or requires an update to a newer version. This is specific to Android's
  /// Health Connect and will never be thrown on other platforms.
  @SupportedHealthPlatforms([
    HealthPlatform.healthConnect,
  ])
  installationOrUpdateRequired('INSTALLATION_OR_UPDATE_REQUIRED'),

  /// Health platform is unavailable on this device.
  ///
  /// This error indicates that the health platform is not available and
  /// cannot be used.
  ///
  /// **Platform-specific notes:**
  /// - **iOS:** Apple Health is generally available on all iOS devices
  /// - **Android:** May occur if Health Connect is incompatible with the device
  healthPlatformUnavailable('HEALTH_PLATFORM_UNAVAILABLE'),

  /// Failed to parse data from the platform.
  ///
  /// This can occur when the platform returns malformed data or when
  /// the JSON structure doesn't match the expected format.
  parsingError('PARSING_ERROR'),

  /// Attempted to use platform APIs or features that are not supported
  /// on the current health platform.
  ///
  /// This typically indicates a developer error where permissions, data types,
  /// or features are being requested that aren't available on
  /// the current health platform.
  unsupportedHealthPlatformApi('UNSUPPORTED_HEALTH_PLATFORM_API'),

  /// Platform configuration is missing or invalid.
  ///
  /// This indicates platform-specific configuration is not properly set up.
  ///
  /// **Android:** Health data permissions or feature permissions are
  /// missing from the AndroidManifest.xml file.
  invalidPlatformConfiguration('INVALID_PLATFORM_CONFIGURATION'),

  /// Security/permission error occurred.
  ///
  /// This error occurs when a request is made without proper permissions
  /// or when access is denied by the health platform.
  securityError('SECURITY_ERROR'),

  /// I/O error occurred during data operations.
  ///
  /// This error occurs when disk I/O operations fail, such as:
  /// - Reading or writing health data fails
  /// - Database operations fail
  /// - Storage access issues
  ioError('IO_ERROR'),

  /// Remote/IPC communication error occurred.
  ///
  /// This error occurs when inter-process communication (IPC) with the
  /// health platform service fails, such as:
  /// - Health service is not responding
  /// - Network/transportation failures
  remoteError('REMOTE_ERROR'),

  /// Invalid argument provided to the operation.
  ///
  /// This error occurs when invalid parameters are passed to an operation,
  /// such as:
  /// - Invalid record IDs
  /// - Invalid time ranges
  /// - Invalid data types or values
  /// - Missing required parameters
  invalidArgument('INVALID_ARGUMENT');

  const HealthConnectorErrorCode(this.code);

  /// The error code string.
  final String code;
}
