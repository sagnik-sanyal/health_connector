import 'package:flutter/services.dart' show PlatformException;
import 'package:health_connector_core/health_connector_core.dart'
    show
        AggregateRequest,
        AggregateResponse,
        HealthConnectorException,
        HealthConnectorLogger,
        HealthConnectorPlatformClient,
        HealthDataPermission,
        HealthDataType,
        HealthPlatformFeature,
        HealthPlatformFeaturePermission,
        HealthPlatformFeatureStatus,
        HealthPlatformStatus,
        HealthRecord,
        HealthRecordId,
        MeasurementUnit,
        Permission,
        PermissionRequestResult,
        PermissionStatus,
        ReadRecordRequest,
        ReadRecordsRequest,
        ReadRecordsResponse;
import 'package:health_connector_hc_android/src/mappers/mappers.dart';
import 'package:health_connector_hc_android/src/pigeon/health_connector_platform_api.g.dart'
    show
        DeleteRecordsByIdsRequestDto,
        DeleteRecordsByTimeRangeRequestDto,
        HealthConnectorPlatformApi,
        HealthPlatformStatusDto;
import 'package:meta/meta.dart' show immutable;

/// Platform client that communicates with native Android Health Connect code.
///
/// This class acts as a bridge between Dart and platform-specific native code,
/// using generated Pigeon code for type-safe method channel communication.
@immutable
final class HealthConnectorHCClient implements HealthConnectorPlatformClient {
  const HealthConnectorHCClient();

  static const String _tag = 'HealthConnectorHCClient';

  static final _logger = HealthConnectorLogger();

  /// The Pigeon-generated platform API client for native communication.
  static final HealthConnectorPlatformApi _platformClient =
      HealthConnectorPlatformApi();

  @override
  Future<HealthPlatformStatus> getHealthPlatformStatus() async {
    _logger.debug(_tag, 'getHealthPlatformStatus: entry');

    try {
      final statusDto = await _platformClient.getHealthPlatformStatus();

      final status = switch (statusDto) {
        HealthPlatformStatusDto.available => HealthPlatformStatus.available,
        HealthPlatformStatusDto.notAvailable =>
          HealthPlatformStatus.unavailable,
        HealthPlatformStatusDto.installationOrUpdateRequired =>
          HealthPlatformStatus.installationOrUpdateRequired,
      };

      _logger.info(
        _tag,
        'getHealthPlatformStatus: completed successfully, status=$status',
      );

      return status;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'getHealthPlatformStatus: failed',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to get health platform status: '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<PermissionRequestResult>> requestPermissions(
    List<Permission> permissions,
  ) async {
    final permissionsCount = permissions.length;
    final healthDataCount = permissions
        .whereType<HealthDataPermission>()
        .length;
    final featureCount = permissions
        .whereType<HealthPlatformFeaturePermission>()
        .length;

    _logger.debug(
      _tag,
      'requestPermissions: entry with total=$permissionsCount, '
      'healthData=$healthDataCount, features=$featureCount',
    );

    if (permissions.isEmpty) {
      _logger.debug(
        _tag,
        'requestPermissions: empty permissions list, returning empty result',
      );

      return [];
    }

    try {
      final requestDto = permissions.toDto();

      final responseDto = await _platformClient.requestPermissions(requestDto);

      final results = responseDto.toDomain();

      _logger.info(
        _tag,
        'requestPermissions: completed successfully, '
        '${results.length} result(s)',
      );

      return results;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'requestPermissions: platform exception - total=$permissionsCount, '
        'healthData=$healthDataCount, features=$featureCount',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to request permissions (total: $permissionsCount, '
        'health data: $healthDataCount, features: $featureCount): '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Gets all permissions that have been granted to the app.
  ///
  /// Returns a list of all permissions that are currently granted.
  /// This can be used to check which data types the app has access to without
  /// prompting the user.
  ///
  /// ## Returns
  ///
  /// - A list of [Permission] objects representing all currently
  /// granted permissions.
  ///
  /// ## Throws
  ///
  /// - [HealthConnectorException] if the platform request fails or
  ///   returns invalid data.
  Future<List<Permission>> getGrantedPermissions() async {
    _logger.debug(_tag, 'getGrantedPermissions: entry');

    try {
      final responseDto = await _platformClient.getGrantedPermissions();

      final results = responseDto.toDomain();

      // Filter only granted permissions
      final grantedPermissions = results
          .where((result) => result.status == PermissionStatus.granted)
          .map((result) => result.permission)
          .toList();

      _logger.info(
        _tag,
        'getGrantedPermissions: completed successfully, '
        '${grantedPermissions.length} granted permission(s)',
      );

      return grantedPermissions;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'getGrantedPermissions: platform exception',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to get granted permissions from platform: '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Revokes all permissions that have been granted to the app.
  ///
  /// Removes all health data permissions that were previously granted.
  /// After calling this method, the app will need to request permissions
  /// again before accessing health data.
  ///
  /// ## Throws
  ///
  /// - [HealthConnectorException] if the platform request fails
  Future<void> revokeAllPermissions() async {
    _logger.debug(_tag, 'revokeAllPermissions: entry');

    try {
      await _platformClient.revokeAllPermissions();

      _logger.info(_tag, 'revokeAllPermissions: completed successfully');
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'revokeAllPermissions: platform exception',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to revoke all permissions from platform: '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// Queries the native platform to determine feature availability.
  ///
  /// Checks whether a specific platform feature (e.g., exercise routes,
  /// workout goals) is available and enabled on the device.
  ///
  /// ## Parameters
  ///
  /// - [feature]: The platform feature to check
  ///
  /// ## Returns
  ///
  /// A [HealthPlatformFeatureStatus] indicating whether the feature is
  /// available, unavailable, or requires an update.
  ///
  /// ## Throws
  ///
  /// - [HealthConnectorException] if the platform request fails
  Future<HealthPlatformFeatureStatus> getFeatureStatus(
    HealthPlatformFeature feature,
  ) async {
    _logger.debug(_tag, 'getFeatureStatus: entry for feature=$feature');

    try {
      final featureDto = feature.toDto();

      final statusDto = await _platformClient.getFeatureStatus(featureDto);

      final status = statusDto.toDomain();

      _logger.info(
        _tag,
        'getFeatureStatus: completed successfully, feature=$feature, '
        'status=$status',
      );

      return status;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'getFeatureStatus: platform exception for feature=$feature',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to get feature status for feature=$feature from platform: '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<R?> readRecord<R extends HealthRecord>(
    ReadRecordRequest<R> request,
  ) async {
    _logger.debug(
      _tag,
      'readRecord: entry for dataType=${request.dataType.identifier}, '
      'recordId=${request.id.value}',
    );

    try {
      final requestDto = request.toDto();

      final responseDto = await _platformClient.readRecord(requestDto);

      if (responseDto == null) {
        _logger.info(_tag, 'readRecord: completed, record not found');

        return null; // Record not found
      }

      // Extract record based on data type using typed fields
      final record = responseDto.toDomain<R>(request.dataType);

      _logger.info(_tag, 'readRecord: completed successfully, record found');

      return record;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'readRecord: platform exception for '
        'dataType=${request.dataType.identifier}, recordId=${request.id.value}',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to read record (dataType=${request.dataType.identifier}, '
        'recordId=${request.id.value}): ${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<ReadRecordsResponse<R>> readRecords<R extends HealthRecord>(
    ReadRecordsRequest<R> request,
  ) async {
    final timeRange =
        '${request.startTime.toIso8601String()} to '
        '${request.endTime.toIso8601String()}';
    final pageSize = request.pageSize;
    final pageToken = request.pageToken ?? 'none';

    _logger.debug(
      _tag,
      'readRecords: entry for dataType=${request.dataType.identifier}, '
      'timeRange=$timeRange, pageSize=$pageSize, pageToken=$pageToken',
    );

    try {
      final requestDto = request.toDto();

      final responseDto = await _platformClient.readRecords(requestDto);

      final response = responseDto.toDomain<R>(request);

      _logger.info(
        _tag,
        'readRecords: completed successfully, ${response.records.length} '
        'record(s) found, hasMorePages=${response.hasMorePages}',
      );

      return response;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'readRecords: platform exception for '
        'dataType=${request.dataType.identifier}, '
        'timeRange=$timeRange, pageSize=$pageSize, pageToken=$pageToken',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to read records (dataType=${request.dataType.identifier}, '
        'timeRange=$timeRange, pageSize=$pageSize, pageToken=$pageToken): '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<HealthRecordId> writeRecord<R extends HealthRecord>(R record) async {
    final recordType = record.runtimeType.toString();
    final recordId = record.id.value;

    _logger.debug(
      _tag,
      'writeRecord: entry for recordType=$recordType, recordId=$recordId',
    );

    try {
      final requestDto = record.toWriteRecordRequestDto();

      final responseDto = await _platformClient.writeRecord(requestDto);

      final assignedRecordId = responseDto.recordId.toHealthRecordId();

      _logger.info(
        _tag,
        'writeRecord: completed successfully, '
        'assigned recordId=${assignedRecordId.value}',
      );

      return assignedRecordId;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'writeRecord: platform exception for recordType=$recordType, '
        'recordId=$recordId',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to write record (type=$recordType, id=$recordId): '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<List<HealthRecordId>> writeRecords<R extends HealthRecord>(
    List<R> records,
  ) async {
    final recordsCount = records.length;
    final recordType = records.isNotEmpty
        ? records.first.runtimeType.toString()
        : 'unknown';

    _logger.debug(
      _tag,
      'writeRecords: entry with count=$recordsCount, recordType=$recordType',
    );

    if (records.isEmpty) {
      _logger.debug(
        _tag,
        'writeRecords: empty records list, returning empty result',
      );

      return [];
    }

    try {
      final requestDto = records.toWriteRecordsRequestDto();

      final responseDto = await _platformClient.writeRecords(requestDto);

      final recordIds = responseDto.recordIds
          .map((id) => id.toHealthRecordId())
          .toList();

      _logger.info(
        _tag,
        'writeRecords: completed successfully, ${recordIds.length} '
        'record(s) written',
      );

      return recordIds;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'writeRecords: platform exception for count=$recordsCount, '
        'type=$recordType',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to write records (count=$recordsCount, type=$recordType): '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<HealthRecordId> updateRecord<R extends HealthRecord>(R record) async {
    final recordType = record.runtimeType.toString();
    final recordId = record.id.value;

    _logger.debug(
      _tag,
      'updateRecord: entry for recordType=$recordType, recordId=$recordId',
    );

    try {
      final requestDto = record.toUpdateRecordRequestDto();

      final responseDto = await _platformClient.updateRecord(requestDto);

      final updatedRecordId = responseDto.recordId.toHealthRecordId();

      _logger.info(
        _tag,
        'updateRecord: completed successfully, '
        'recordId=${updatedRecordId.value}',
      );

      return updatedRecordId;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'updateRecord: platform exception for recordType=$recordType, '
        'recordId=$recordId',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to update record (type=$recordType, id=$recordId): '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<AggregateResponse<R, U>> aggregate<
    R extends HealthRecord,
    U extends MeasurementUnit
  >(AggregateRequest<R, U> request) async {
    final timeRange =
        '${request.startTime.toIso8601String()} to '
        '${request.endTime.toIso8601String()}';

    _logger.debug(
      _tag,
      'aggregate: entry for dataType=${request.dataType.identifier}, '
      'metric=${request.aggregationMetric.name}, timeRange=$timeRange',
    );

    try {
      final requestDto = request.toDto();

      final responseDto = await _platformClient.aggregate(requestDto);

      final response = responseDto.toDomain<R, U>(request.dataType);

      _logger.info(
        _tag,
        'aggregate: completed successfully, value=${response.value}',
      );

      return response;
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'aggregate: platform exception for '
        'dataType=${request.dataType.identifier}, '
        'metric=${request.aggregationMetric.name}, timeRange=$timeRange',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to perform aggregation '
        '(dataType=${request.dataType.identifier}, '
        'metric=${request.aggregationMetric.name}, timeRange=$timeRange): '
        '${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteRecords<R extends HealthRecord>({
    required HealthDataType<R, MeasurementUnit> dataType,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final timeRange =
        '${startTime.toIso8601String()} to ${endTime.toIso8601String()}';

    _logger.debug(
      _tag,
      'deleteRecords: entry for dataType=${dataType.identifier}, '
      'timeRange=$timeRange',
    );

    try {
      final requestDto = DeleteRecordsByTimeRangeRequestDto(
        dataType: dataType.toDto(),
        startTime: startTime.millisecondsSinceEpoch,
        endTime: endTime.millisecondsSinceEpoch,
      );

      await _platformClient.deleteRecordsByTimeRange(requestDto);

      _logger.info(
        _tag,
        'deleteRecords: completed successfully for '
        'dataType=${dataType.identifier}, timeRange=$timeRange',
      );
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'deleteRecords: platform exception for '
        'dataType=${dataType.identifier}, timeRange=$timeRange',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to delete records by time range '
        '(dataType=${dataType.identifier}, '
        'timeRange=$timeRange): ${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> deleteRecordsByIds<R extends HealthRecord>({
    required HealthDataType<R, MeasurementUnit> dataType,
    required List<HealthRecordId> recordIds,
  }) async {
    final idsCount = recordIds.length;

    _logger.debug(
      _tag,
      'deleteRecordsByIds: entry for dataType=${dataType.identifier}, '
      'recordIdsCount=$idsCount',
    );

    if (recordIds.isEmpty) {
      _logger.debug(
        _tag,
        'deleteRecordsByIds: empty recordIds list, returning',
      );

      return;
    }

    try {
      final requestDto = DeleteRecordsByIdsRequestDto(
        dataType: dataType.toDto(),
        recordIds: recordIds.map((id) => id.toDto()).toList(),
      );

      await _platformClient.deleteRecordsByIds(requestDto);

      _logger.info(
        _tag,
        'deleteRecordsByIds: completed successfully for '
        'dataType=${dataType.identifier}, recordIdsCount=$idsCount',
      );
    } on PlatformException catch (e, st) {
      _logger.error(
        _tag,
        'deleteRecordsByIds: platform exception for '
        'dataType=${dataType.identifier}, recordIdsCount=$idsCount',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed to delete records by IDs (dataType=${dataType.identifier}, '
        'recordIdsCount=$idsCount): ${e.message ?? 'Unknown error'}',
        cause: e,
        stackTrace: st,
      );
    }
  }
}
