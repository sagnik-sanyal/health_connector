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
        HealthPlatformFeaturePermission,
        HealthPlatformStatus,
        HealthRecord,
        HealthRecordId,
        MeasurementUnit,
        Permission,
        PermissionRequestResult,
        ReadRecordRequest,
        ReadRecordsRequest,
        ReadRecordsResponse,
        HealthConnectorErrorCode;
import 'package:health_connector_hk_ios/src/mappers/mappers.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show
        DeleteRecordsByIdsRequestDto,
        DeleteRecordsByTimeRangeRequestDto,
        HealthConnectorPlatformApi,
        HealthPlatformStatusDto;
import 'package:meta/meta.dart' show immutable;

/// Platform client that communicates with native iOS HealthKit code.
///
/// This class acts as a bridge between Dart and platform-specific native code,
/// using generated Pigeon code for type-safe method channel communication.
@immutable
final class HealthConnectorHKClient implements HealthConnectorPlatformClient {
  const HealthConnectorHKClient();

  static const String _tag = 'HealthConnectorHKClient';

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
    final featurePermissions = permissions
        .whereType<HealthPlatformFeaturePermission>()
        .toList();
    if (featurePermissions.isNotEmpty) {
      final exception = HealthConnectorException(
        HealthConnectorErrorCode.unsupportedHealthPlatformApi,
        'Failed requestPermissions due to '
        'unsupported feature permission: $featurePermissions',
      );

      _logger.error(
        _tag,
        exception.toString(),
        exception: exception,
      );

      throw exception;
    }

    final healthDataPermissions = permissions
        .whereType<HealthDataPermission>()
        .toList();

    _logger.debug(
      _tag,
      'requestPermissions: $permissions',
    );

    if (healthDataPermissions.isEmpty) {
      _logger.debug(
        _tag,
        'requestPermissions: empty permissions list, returning empty result',
      );

      return [];
    }

    try {
      final requestDto = healthDataPermissions.toDto();

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
        'Failed requestPermissions with platform exception for $permissions',
        exception: e,
        stackTrace: st,
      );

      throw HealthConnectorException(
        e.code.toHealthConnectorErrorCode(),
        'Failed requestPermissions with platform exception for $permissions: '
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
