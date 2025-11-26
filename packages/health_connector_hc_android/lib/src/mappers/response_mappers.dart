import 'package:health_connector_core/health_connector_core.dart'
    show
        ActiveCaloriesBurnedHealthDataType,
        HealthConnectorErrorCode,
        HealthConnectorException,
        HealthDataType,
        DistanceHealthDataType,
        StepsHealthDataType,
        WeightHealthDataType,
        HealthRecord,
        ReadRecordsRequest,
        AggregateResponse,
        ReadRecordsResponse,
        MeasurementUnit,
        Numeric;
import 'package:health_connector_hc_android/src/mappers/health_record_mappers.dart';
import 'package:health_connector_hc_android/src/mappers/measurement_unit_mappers.dart';
import 'package:health_connector_hc_android/src/pigeon/health_connector_platform_api.g.dart'
    show AggregateResponseDto, ReadRecordResponseDto, ReadRecordsResponseDto;
import 'package:meta/meta.dart' show internal;

/// Converts [ReadRecordsResponseDto] to [ReadRecordsResponse].
@internal
extension ReadRecordsResponseDtoToDomain on ReadRecordsResponseDto {
  ReadRecordsResponse<R> toDomain<R extends HealthRecord>(
    ReadRecordsRequest<R> originalRequest,
  ) {
    // Extract records from typed fields based on the request's data type
    // This ensures type safety: all records in the returned list are of type R
    final records = _extractRecordsFromResponse<R>(
      this,
      originalRequest.dataType,
    );

    // Create next page request if token is present and not empty
    final nextPageRequest = nextPageToken?.isNotEmpty ?? false
        ? originalRequest.copyWith(pageToken: nextPageToken)
        : null;

    return ReadRecordsResponse(
      records: records,
      nextPageRequest: nextPageRequest,
    );
  }

  /// Extracts multiple records from typed response DTO.
  List<R> _extractRecordsFromResponse<R extends HealthRecord>(
    ReadRecordsResponseDto responseDto,
    HealthDataType<R, MeasurementUnit> dataType,
  ) {
    switch (dataType) {
      case ActiveCaloriesBurnedHealthDataType _:
        final activeCaloriesBurnedRecords =
            responseDto.activeCaloriesBurnedRecords;
        if (activeCaloriesBurnedRecords == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected activeCaloriesBurnedRecords but got null in '
            'ReadRecordsResponseDto for dataType: $dataType',
          );
        }
        return activeCaloriesBurnedRecords
            .map((dto) => dto.toDomain())
            .cast<R>()
            .toList();

      case DistanceHealthDataType _:
        final distanceRecords = responseDto.distanceRecords;
        if (distanceRecords == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected distanceRecords but got null in '
            'ReadRecordsResponseDto for dataType: $dataType',
          );
        }
        return distanceRecords.map((dto) => dto.toDomain()).cast<R>().toList();

      case StepsHealthDataType _:
        final stepsRecords = responseDto.stepsRecords;
        if (stepsRecords == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected stepsRecords but got null in '
            'ReadRecordsResponseDto for dataType: $dataType',
          );
        }
        return stepsRecords.map((dto) => dto.toDomain()).cast<R>().toList();

      case WeightHealthDataType _:
        final weightRecords = responseDto.weightRecords;
        if (weightRecords == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected weightRecords but got null in '
            'ReadRecordsResponseDto for dataType: $dataType',
          );
        }
        return weightRecords.map((dto) => dto.toDomain()).cast<R>().toList();
    }
  }
}

/// Converts [AggregateResponseDto] to [AggregateResponse].
@internal
extension AggregateResponseDtoToDomain on AggregateResponseDto {
  AggregateResponse<R, U> toDomain<
    R extends HealthRecord,
    U extends MeasurementUnit
  >(HealthDataType<R, U> dataType) {
    // Extract value from typed fields based on the data type
    final extractedValue = _extractValueFromResponse<R, U>(dataType);

    if (extractedValue == null) {
      throw HealthConnectorException(
        HealthConnectorErrorCode.parsingError,
        'Cannot create AggregateResponse with null value for '
        'dataType: $dataType',
      );
    }

    return AggregateResponse(extractedValue);
  }

  /// Extracts aggregate value from typed response DTO.
  U? _extractValueFromResponse<
    R extends HealthRecord,
    U extends MeasurementUnit
  >(HealthDataType<R, U> dataType) {
    switch (dataType) {
      case ActiveCaloriesBurnedHealthDataType _:
        final value = activeCaloriesBurnedValue;
        if (value == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected activeCaloriesBurnedValue but got null in '
            'AggregateResponseDto for dataType: $dataType',
          );
        }
        return value.toDomain() as U;

      case DistanceHealthDataType _:
        final value = lengthValue;
        if (value == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected lengthValue but got null in '
            'AggregateResponseDto for dataType: $dataType',
          );
        }
        return value.toDomain() as U;

      case StepsHealthDataType _:
        final value = doubleValue;
        if (value == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected doubleValue but got null in '
            'AggregateResponseDto for dataType: $dataType',
          );
        }
        return Numeric(value) as U;

      case WeightHealthDataType _:
        final value = massValue;
        if (value == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected massValue but got null in '
            'AggregateResponseDto for dataType: $dataType',
          );
        }
        return value.toDomain() as U;
    }
  }
}

/// Converts [ReadRecordResponseDto] to [HealthRecord].
@internal
extension ReadRecordResponseDtoToDomain on ReadRecordResponseDto {
  R toDomain<R extends HealthRecord>(
    HealthDataType<R, MeasurementUnit> dataType,
  ) {
    switch (dataType) {
      case ActiveCaloriesBurnedHealthDataType _:
        final record = activeCaloriesBurnedRecord;
        if (record == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected activeCaloriesBurnedRecord but got null in '
            'ReadRecordResponseDto for dataType: $dataType',
          );
        }
        return record.toDomain() as R;

      case DistanceHealthDataType _:
        final record = distanceRecord;
        if (record == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected distanceRecord but got null in '
            'ReadRecordResponseDto for dataType: $dataType',
          );
        }
        return record.toDomain() as R;

      case StepsHealthDataType _:
        final record = stepsRecord;
        if (record == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected stepsRecord but got null in '
            'ReadRecordResponseDto for dataType: $dataType',
          );
        }
        return record.toDomain() as R;

      case WeightHealthDataType _:
        final record = weightRecord;
        if (record == null) {
          throw HealthConnectorException(
            HealthConnectorErrorCode.parsingError,
            'Expected weightRecord but got null in '
            'ReadRecordResponseDto for dataType: $dataType',
          );
        }
        return record.toDomain() as R;
    }
  }
}
