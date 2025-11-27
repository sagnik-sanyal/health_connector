import 'package:health_connector_core/health_connector_core.dart'
    show
        ActiveCaloriesBurnedRecord,
        DistanceRecord,
        FloorsClimbedRecord,
        HealthRecordId,
        StepRecord,
        WeightRecord,
        WheelchairPushesRecord;
import 'package:health_connector_hk_ios/src/mappers/measurement_unit_mappers.dart';
import 'package:health_connector_hk_ios/src/mappers/metadata_mappers.dart';
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show
        ActiveCaloriesBurnedRecordDto,
        DistanceRecordDto,
        FloorsClimbedRecordDto,
        StepRecordDto,
        WeightRecordDto,
        WheelchairPushesRecordDto;
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

/// Converts [ActiveCaloriesBurnedRecord] to [ActiveCaloriesBurnedRecordDto].
@internal
extension ActiveCaloriesBurnedRecordDtoMapper on ActiveCaloriesBurnedRecord {
  ActiveCaloriesBurnedRecordDto toDto() {
    return ActiveCaloriesBurnedRecordDto(
      id: id.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDto(),
      energy: energy.toDto(),
    );
  }
}

/// Converts [ActiveCaloriesBurnedRecordDto] to [ActiveCaloriesBurnedRecord].
@internal
extension ActiveCaloriesBurnedRecordDtoToDomain
    on ActiveCaloriesBurnedRecordDto {
  ActiveCaloriesBurnedRecord toDomain() {
    return ActiveCaloriesBurnedRecord(
      id: id.toHealthRecordId(),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDomain(),
      energy: energy.toDomain(),
    );
  }
}

/// Converts [DistanceRecord] to [DistanceRecordDto].
@internal
extension DistanceRecordDtoMapper on DistanceRecord {
  DistanceRecordDto toDto() {
    return DistanceRecordDto(
      id: id.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDto(),
      distance: distance.toDto(),
    );
  }
}

/// Converts [DistanceRecordDto] to [DistanceRecord].
@internal
extension DistanceRecordDtoToDomain on DistanceRecordDto {
  DistanceRecord toDomain() {
    return DistanceRecord(
      id: id.toHealthRecordId(),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDomain(),
      distance: distance.toDomain(),
    );
  }
}

/// Converts [FloorsClimbedRecord] to [FloorsClimbedRecordDto].
@internal
extension FloorsClimbedRecordDtoMapper on FloorsClimbedRecord {
  FloorsClimbedRecordDto toDto() {
    return FloorsClimbedRecordDto(
      id: id.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDto(),
      floors: floors.toDto(),
    );
  }
}

/// Converts [FloorsClimbedRecordDto] to [FloorsClimbedRecord].
@internal
extension FloorsClimbedRecordDtoToDomain on FloorsClimbedRecordDto {
  FloorsClimbedRecord toDomain() {
    return FloorsClimbedRecord(
      id: id.toHealthRecordId(),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDomain(),
      floors: floors.toDomain(),
    );
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

/// Converts [WheelchairPushesRecord] to [WheelchairPushesRecordDto].
@internal
extension WheelchairPushesRecordDtoMapper on WheelchairPushesRecord {
  WheelchairPushesRecordDto toDto() {
    return WheelchairPushesRecordDto(
      id: id.toDto(),
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDto(),
      pushes: pushes.toDto(),
    );
  }
}

/// Converts [WheelchairPushesRecordDto] to [WheelchairPushesRecord].
@internal
extension WheelchairPushesRecordDtoToDomain on WheelchairPushesRecordDto {
  WheelchairPushesRecord toDomain() {
    return WheelchairPushesRecord(
      id: id.toHealthRecordId(),
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      startZoneOffsetSeconds: startZoneOffsetSeconds,
      endZoneOffsetSeconds: endZoneOffsetSeconds,
      metadata: metadata.toDomain(),
      pushes: pushes.toDomain(),
    );
  }
}
