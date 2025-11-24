import 'package:health_connector_core/health_connector_core.dart'
    show
        HealthRecord,
        AggregateRequest,
        ReadRecordRequest,
        ReadRecordsRequest,
        MeasurementUnit,
        StepRecord,
        WeightRecord;
import 'package:health_connector_hk_ios/src/mappers/aggregation_metric_mappers.dart';
import 'package:health_connector_hk_ios/src/mappers/health_data_mappers.dart';
import 'package:health_connector_hk_ios/src/mappers/health_record_mappers.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show
        ReadRecordRequestDto,
        ReadRecordsRequestDto,
        AggregateRequestDto,
        WriteRecordRequestDto,
        UpdateRecordRequestDto,
        WriteRecordsRequestDto,
        HealthDataTypeDto;
import 'package:meta/meta.dart' show internal;

/// Converts [ReadRecordRequest] to [ReadRecordRequestDto].
@internal
extension ReadRecordRequestDtoMapper<R extends HealthRecord>
    on ReadRecordRequest<R> {
  ReadRecordRequestDto toDto() {
    return ReadRecordRequestDto(
      dataType: dataType.toDto(),
      recordId: id.toDto(),
    );
  }
}

/// Converts [ReadRecordsRequest] to [ReadRecordsRequestDto].
@internal
extension ReadRecordsRequestDtoMapper<R extends HealthRecord>
    on ReadRecordsRequest<R> {
  ReadRecordsRequestDto toDto() {
    return ReadRecordsRequestDto(
      dataType: dataType.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      pageSize: pageSize,
      pageToken: pageToken,
      dataOriginPackageNames: dataOrigins
          .map((origin) => origin.packageName)
          .toList(),
    );
  }
}

/// Converts [AggregateRequest] to [AggregateRequestDto].
@internal
extension AggregateRequestDtoMapper<
  R extends HealthRecord,
  U extends MeasurementUnit
>
    on AggregateRequest<R, U> {
  AggregateRequestDto toDto() {
    return AggregateRequestDto(
      dataType: dataType.toDto(),
      aggregationMetric: aggregationMetric.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
    );
  }
}

/// Converts [HealthRecord] to [WriteRecordRequestDto].
@internal
extension HealthRecordToWriteRequestDto on HealthRecord {
  WriteRecordRequestDto toWriteRecordRequestDto() {
    switch (this) {
      case final StepRecord record:
        return WriteRecordRequestDto(
          dataType: HealthDataTypeDto.steps,
          stepsRecord: record.toDto(),
        );
      case final WeightRecord record:
        return WriteRecordRequestDto(
          dataType: HealthDataTypeDto.weight,
          weightRecord: record.toDto(),
        );
    }
  }
}

/// Converts [HealthRecord] to [UpdateRecordRequestDto].
@internal
extension HealthRecordToUpdateRequestDto on HealthRecord {
  UpdateRecordRequestDto toUpdateRecordRequestDto() {
    switch (this) {
      case final StepRecord record:
        return UpdateRecordRequestDto(
          dataType: HealthDataTypeDto.steps,
          stepsRecord: record.toDto(),
        );
      case final WeightRecord record:
        return UpdateRecordRequestDto(
          dataType: HealthDataTypeDto.weight,
          weightRecord: record.toDto(),
        );
    }
  }
}

/// Converts list of domain [HealthRecord] to [WriteRecordsRequestDto].
@internal
extension HealthRecordListToWriteRequestDto on List<HealthRecord> {
  WriteRecordsRequestDto toWriteRecordsRequestDto() {
    if (isEmpty) {
      throw ArgumentError('Cannot create write request from empty record list');
    }

    // Group records by type
    final stepRecords = <StepRecord>[];
    final weightRecords = <WeightRecord>[];
    final dataTypes = <HealthDataTypeDto>[];

    for (final record in this) {
      switch (record) {
        case final StepRecord stepRecord:
          stepRecords.add(stepRecord);
          if (!dataTypes.contains(HealthDataTypeDto.steps)) {
            dataTypes.add(HealthDataTypeDto.steps);
          }
        case final WeightRecord weightRecord:
          weightRecords.add(weightRecord);
          if (!dataTypes.contains(HealthDataTypeDto.weight)) {
            dataTypes.add(HealthDataTypeDto.weight);
          }
      }
    }

    return WriteRecordsRequestDto(
      dataTypes: dataTypes,
      stepsRecords: stepRecords.isEmpty
          ? null
          : stepRecords.map((r) => r.toDto()).toList(),
      weightRecords: weightRecords.isEmpty
          ? null
          : weightRecords.map((r) => r.toDto()).toList(),
    );
  }
}
