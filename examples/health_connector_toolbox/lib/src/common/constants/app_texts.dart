import 'package:health_connector_core/health_connector_core.dart';

/// Centralized collection of all text strings used throughout the application.
///
/// This class provides a single source of truth for all UI text, making it
/// easier to maintain, localize, and update text content.
abstract final class AppTexts {
  // ==========================================================================
  // App Titles
  // ==========================================================================
  static const String healthConnectorToolbox = 'Health Connector Toolbox';

  // ==========================================================================
  // Common UI Elements
  // ==========================================================================
  static const String retry = 'Retry';
  static const String save = 'Save';
  static const String pleaseSelect = 'Please select';

  // ==========================================================================
  // Common Labels
  // ==========================================================================
  static const String id = 'ID';
  static const String status = 'Status';
  static const String time = 'Time';
  static const String date = 'Date';
  static const String startDate = 'Start Date';
  static const String startTime = 'Start Time';
  static const String endDate = 'End Date';
  static const String endTime = 'End Time';
  static const String dataType = 'Data Type';
  static const String value = 'Value';
  static const String valueType = 'Value Type';
  static const String metric = 'Metric';
  static const String type = 'Type';
  static const String name = 'Name';
  static const String count = 'Count';
  static const String duration = 'Duration';
  static const String deviceLabel = 'Device';
  static const String recording = 'Recording';
  static const String recordingMethod = 'Recording Method';

  // ==========================================================================
  // Common Status Values
  // ==========================================================================
  static const String unknown = 'Unknown';
  static const String granted = 'granted';
  static const String denied = 'denied';
  static const String available = 'Available';
  static const String unavailable = 'Unavailable';
  static const String notRequested = 'Not requested';
  static const String notAvailable = 'N/A';
  static const String nullValue = 'none';

  // ==========================================================================
  // Health Platforms
  // ==========================================================================
  static const String appleHealth = 'Apple Health';
  static const String healthConnect = 'Health Connect';

  // ==========================================================================
  // Health Data Types
  // ==========================================================================
  static const String steps = 'Steps';
  static const String stepsLabel = 'steps';
  static const String stepsDescription = 'Step count data over a time interval';
  static const String stepCount = 'Step Count';
  static const String weight = 'Weight';
  static const String weightDescription =
      'Body weight measurement at a point in time';
  static const String weightValue = 'Weight Value (kg)';
  static const String weightKg = 'Weight (kg)';
  static const String weightLbs = 'Weight (lbs)';
  static const String weightGrams = 'Weight (g)';
  static const String distance = 'Distance';
  static const String distanceDescription =
      'Distance traveled over a time interval';
  static const String distanceValue = 'Distance Value (m)';
  static const String distanceMeters = 'Distance (m)';
  static const String distanceKm = 'Distance (km)';
  static const String activeCaloriesBurned = 'Active Calories Burned';
  static const String activeCaloriesBurnedDescription =
      'Active calories burned during physical activity over a time interval';
  static const String activeCaloriesBurnedValue =
      'Active Calories Burned (kcal)';
  static const String activeCaloriesBurnedKcal = 'Active Calories (kcal)';
  static const String activeCaloriesBurnedCal = 'Active Calories (cal)';

  // ==========================================================================
  // Device Types
  // ==========================================================================
  static const String deviceType = 'Device Type';
  static const String phone = 'Phone';
  static const String watch = 'Watch';
  static const String fitnessBand = 'Fitness Band';
  static const String ring = 'Ring';
  static const String scale = 'Scale';
  static const String chestStrap = 'Chest Strap';
  static const String headMounted = 'Head Mounted';
  static const String smartDisplay = 'Smart Display';

  // ==========================================================================
  // Recording Methods
  // ==========================================================================
  static const String manualEntry = 'Manual Entry';
  static const String automaticallyRecorded = 'Automatically Recorded';
  static const String activelyRecorded = 'Actively Recorded';

  // ==========================================================================
  // Measurement Units
  // ==========================================================================
  static const String mass = 'Mass';
  static const String numeric = 'Numeric';
  static const String length = 'Length';
  static const String energy = 'Energy';
  static const String bloodGlucose = 'Blood Glucose';
  static const String power = 'Power';
  static const String pressure = 'Pressure';
  static const String temperature = 'Temperature';
  static const String velocity = 'Velocity';
  static const String volume = 'Volume';

  // ==========================================================================
  // Aggregation Metrics
  // ==========================================================================
  static const String aggregationMetric = 'Aggregation Metric';
  static const String aggregate = 'Aggregate';
  static const String sum = 'Sum';
  static const String average = 'Average';
  static const String minimum = 'Minimum';
  static const String maximum = 'Maximum';
  static const String timeRange = 'Time Range';
  static const String aggregationResult = 'Aggregation Result';

  // ==========================================================================
  // Permissions
  // ==========================================================================
  static const String permissions = 'Permissions';
  static const String read = 'Read';
  static const String write = 'Write';
  static const String requestPermissions = 'Request Permissions';
  static const String requestPermissionsTitle = requestPermissions;
  static const String requestSelectedPermissions =
      'Request Selected Permissions';
  static const String dataTypePermissions = 'Data Type Permissions';
  static const String featurePermissions = 'Feature Permissions';
  static const String feature = 'Feature';
  static const String readHealthDataInBackground =
      'Read Health Data in Background';
  static const String readHealthDataHistory = 'Read Health Data History';
  static const String stepsRead = 'Steps - Read';
  static const String stepsWrite = 'Steps - Write';
  static const String weightRead = 'Weight - Read';
  static const String weightWrite = 'Weight - Write';
  static const String distanceRead = 'Distance - Read';
  static const String distanceWrite = 'Distance - Write';
  static const String activeCaloriesBurnedRead =
      'Active Calories Burned - Read';
  static const String activeCaloriesBurnedWrite =
      'Active Calories Burned - Write';
  static const String iosReadPermissionUnknownStatusNote =
      'Note: On iOS, read permissions may show as "unknown" status even after '
      'being granted due to privacy restrictions. '
      'This is a platform limitation.';

  // ==========================================================================
  // Common Success Messages
  // ==========================================================================
  static const String successfullyWroteRecord =
      'Successfully wrote record with ID';
  static const String recordDeletedSuccessfully = 'Record deleted successfully';
  static const String successfullyDeletedRecords = 'Successfully deleted';
  static const String requestCompleted = 'Request completed';

  // ==========================================================================
  // Common Error Messages
  // ==========================================================================
  static const String errorPrefixColon = 'Error';
  static const String failedToLoadNextPage = 'Failed to load next page';
  static const String failedToRequestPermissions =
      'Failed to request permissions';
  static const String failedToLoadFeatureStatuses =
      'Failed to load feature statuses';

  // ==========================================================================
  // Permission Error Messages
  // ==========================================================================
  static const String readPermissionDenied =
      'Read permission denied or not supported. Please grant read permission.';
  static const String writePermissionDeniedSteps =
      'Write permission denied or not supported. '
      'Please grant write permission for steps.';
  static const String writePermissionDeniedWeight =
      'Write permission denied or not supported. '
      'Please grant write permission for weight.';
  static const String writePermissionDeniedDistance =
      'Write permission denied or not supported. '
      'Please grant write permission for distance.';
  static const String writePermissionDeniedActiveCaloriesBurned =
      'Write permission denied or not supported. '
      'Please grant write permission for active calories burned.';

  // ==========================================================================
  // Validation Messages
  // ==========================================================================
  static const String pleaseSelectBothStartAndEndDateTime =
      'Please select both start and end date/time';
  static const String pleaseSelectDateTime = 'Please select a date and time';
  static const String pleaseSelectDataType = 'Please select a data type';
  static const String pleaseSelectMetric = 'Please select a metric';
  static const String pleaseSelectDeviceType = 'Please select a device type';
  static const String pleaseSelectRecordingMethod =
      'Please select a recoding method';
  static const String pleaseSelectAtLeastOnePermission =
      'Please select at least one permission';
  static const String pleaseEnterStepCount = 'Please enter step count';
  static const String pleaseEnterWeight = 'Please enter weight';
  static const String pleaseEnterDistance = 'Please enter distance';
  static const String pleaseEnterActiveCaloriesBurned =
      'Please enter active calories burned';
  static const String pleaseEnterValidNumber = 'Please enter a valid number';
  static const String endTimeMustBeAfterStartTime =
      'End time must be after start time';
  static const String countMustBeNonNegative = 'Count must be non-negative';
  static const String weightMustBeGreaterThanZero =
      'Weight must be greater than 0';
  static const String distanceMustBeGreaterThanZero =
      'Distance must be greater than 0';
  static const String activeCaloriesBurnedMustBeGreaterThanZero =
      'Active calories burned must be greater than 0';
  static const String pageSizeMustBeBetween1And10000 =
      'Page size must be between 1 and 10000';

  // ==========================================================================
  // Page Titles and Actions
  // ==========================================================================
  static const String insertHealthRecord = 'Insert Health Record';
  static const String insertSteps = 'Insert Steps';
  static const String insertWeight = 'Insert Weight';
  static const String insertDistance = 'Insert Distance';
  static const String insertActiveCaloriesBurned =
      'Insert Active Calories Burned';
  static const String readHealthRecords = 'Read Health Records';
  static const String readAggregateData = 'Read Aggregate Data';

  // ==========================================================================
  // Page Actions
  // ==========================================================================
  static const String readRecords = 'Read Records';
  static const String writeRecords = 'Write Records';
  static const String loadMore = 'Load More';

  // ==========================================================================
  // Record Display
  // ==========================================================================
  static const String recordDetails = 'Record Details';
  static const String unknownRecordType = 'Unknown Record Type';
  static const String startLabel = 'Start';
  static const String endLabel = 'End';
  static const String records = 'record(s)';
  static const String foundRecords = 'Found';
  static const String moreAvailable = 'More available';
  static const String noRecordsFound = 'No records found';
  static const String pageSize =
      'Page Size (1-${HealthConnectorConfigConstants.maxPageSize})';

  // ==========================================================================
  // Health Record Detail Fields
  // ==========================================================================
  static const String startZoneOffsetSeconds = 'Start Zone Offset (sec)';
  static const String endZoneOffsetSeconds = 'End Zone Offset (sec)';
  static const String zoneOffsetSeconds = 'Zone Offset (sec)';

  // ==========================================================================
  // Health Record Metadata
  // ==========================================================================
  static const String metadata = 'Metadata';
  static const String dataOrigin = 'Data Origin';
  static const String lastModified = 'Last Modified';
  static const String clientRecordId = 'Client Record ID';
  static const String clientRecordVersion = 'Client Record Version';
  static const String manufacturer = 'Manufacturer';
  static const String model = 'Model';
  static const String hardwareVersion = 'Hardware Version';
  static const String firmwareVersion = 'Firmware Version';
  static const String softwareVersion = 'Software Version';
  static const String localIdentifier = 'Local Identifier';
  static const String udiDeviceId = 'UDI Device ID';
}
