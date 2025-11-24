import 'package:health_connector_core/health_connector_core.dart'
    show HealthRecordId, StepRecord, WeightRecord;
import 'package:health_connector_hk_ios/src/mappers/measurement_unit_mappers.dart';
import 'package:health_connector_hk_ios/src/mappers/metadata_mappers.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show StepRecordDto, WeightRecordDto;
import 'package:meta/meta.dart' show internal;

/// Converts [HealthRecordId] to [String] for DTO transfer.
@internal
extension HealthRecordIdToString on HealthRecordId {
  String toDto() => value;
}

/// Converts [String] to [HealthRecordId].
@internal
extension StringToHealthRecordId on String {
  HealthRecordId toHealthRecordId() {
    if (this == HealthRecordId.none.value) {
      return HealthRecordId.none;
    }
    return HealthRecordId(this);
  }
}

/// Converts [StepRecord] to [StepRecordDto].
@internal
extension StepRecordDtoMapper on StepRecord {
  StepRecordDto toDto() {
    return StepRecordDto(
      id: id.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDto(),
      count: count.toDto(),
    );
  }
}

/// Converts [StepRecordDto] to [StepRecord].
@internal
extension StepRecordDtoToDomain on StepRecordDto {
  StepRecord toDomain() {
    return StepRecord(
      id: id.toHealthRecordId(),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDomain(),
      count: count.toDomain(),
    );
  }
}

/// Converts [WeightRecord] to [WeightRecordDto].
@internal
extension WeightRecordDtoMapper on WeightRecord {
  WeightRecordDto toDto() {
    return WeightRecordDto(
      id: id.toDto(),
      time: time.millisecondsSinceEpoch,
      zoneOffsetSeconds: zoneOffsetSeconds,
      metadata: metadata.toDto(),
      weight: weight.toDto(),
    );
  }
}

/// Converts [WeightRecordDto] to [WeightRecord].
@internal
extension WeightRecordDtoToDomain on WeightRecordDto {
  WeightRecord toDomain() {
    return WeightRecord(
      id: id.toHealthRecordId(),
      time: DateTime.fromMillisecondsSinceEpoch(time),
      zoneOffsetSeconds: zoneOffsetSeconds,
      metadata: metadata.toDomain(),
      weight: weight.toDomain(),
    );
  }
}
