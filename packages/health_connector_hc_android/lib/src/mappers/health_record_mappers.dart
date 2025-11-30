import 'package:health_connector_core/health_connector_core.dart'
    show
        ActiveCaloriesBurnedRecord,
        BodyFatPercentageRecord,
        BodyTemperatureRecord,
        DistanceRecord,
        Energy,
        FloorsClimbedRecord,
        HealthRecord,
        HealthRecordId,
        HeartRateMeasurement,
        HeartRateMeasurementRecord,
        HeartRateSeriesRecord,
        HeightRecord,
        Length,
        Mass,
        Numeric,
        Percentage,
        SleepSessionRecord,
        HydrationRecord,
        LeanBodyMassRecord,
        StepRecord,
        Temperature,
        Volume,
        WeightRecord,
        WheelchairPushesRecord,
        SleepStageRecord,
        SleepStageType,
        SleepStage;
import 'package:health_connector_hc_android/src/mappers/'
    'measurement_unit_mappers.dart';
import 'package:health_connector_hc_android/src/mappers/metadata_mappers.dart';
import 'package:health_connector_hc_android/src/pigeon/health_connector_platform_api.g.dart'
    show
        ActiveCaloriesBurnedRecordDto,
        BodyFatPercentageRecordDto,
        BodyTemperatureRecordDto,
        DistanceRecordDto,
        EnergyDto,
        FloorsClimbedRecordDto,
        HealthRecordDto,
        HeartRateMeasurementDto,
        HeartRateSeriesRecordDto,
        HeightRecordDto,
        LengthDto,
        MassDto,
        NumericDto,
        PercentageDto,
        SleepSessionRecordDto,
        HydrationRecordDto,
        LeanBodyMassRecordDto,
        StepRecordDto,
        TemperatureDto,
        VolumeDto,
        WeightRecordDto,
        WheelchairPushesRecordDto,
        SleepStageTypeDto,
        SleepStageDto;
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

/// Converts [HealthRecord] to [HealthRecordDto].
@internal
extension HealthRecordToDto on HealthRecord {
  HealthRecordDto toDto() {
    switch (this) {
      case final ActiveCaloriesBurnedRecord record:
        return ActiveCaloriesBurnedRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          energy: record.energy.toDto() as EnergyDto,
        );
      case final DistanceRecord record:
        return DistanceRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          distance: record.distance.toDto() as LengthDto,
        );
      case final FloorsClimbedRecord record:
        return FloorsClimbedRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          floors: record.floors.toDto() as NumericDto,
        );
      case final HeightRecord record:
        return HeightRecordDto(
          id: record.id.toDto(),
          time: record.time.millisecondsSinceEpoch,
          zoneOffsetSeconds: record.zoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          height: record.height.toDto() as LengthDto,
        );
      case final HydrationRecord record:
        return HydrationRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          volume: record.volume.toDto() as VolumeDto,
        );
      case final LeanBodyMassRecord record:
        return LeanBodyMassRecordDto(
          id: record.id.toDto(),
          time: record.time.millisecondsSinceEpoch,
          zoneOffsetSeconds: record.zoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          mass: record.mass.toDto() as MassDto,
        );
      case final BodyFatPercentageRecord record:
        return BodyFatPercentageRecordDto(
          id: record.id.toDto(),
          time: record.time.millisecondsSinceEpoch,
          zoneOffsetSeconds: record.zoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          percentage: record.percentage.toDto() as PercentageDto,
        );
      case final BodyTemperatureRecord record:
        return BodyTemperatureRecordDto(
          id: record.id.toDto(),
          time: record.time.millisecondsSinceEpoch,
          zoneOffsetSeconds: record.zoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          temperature: record.temperature.toDto() as TemperatureDto,
        );
      case final StepRecord record:
        return StepRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          count: record.count.toDto() as NumericDto,
        );
      case final WeightRecord record:
        return WeightRecordDto(
          id: record.id.toDto(),
          time: record.time.millisecondsSinceEpoch,
          zoneOffsetSeconds: record.zoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          weight: record.weight.toDto() as MassDto,
        );
      case final WheelchairPushesRecord record:
        return WheelchairPushesRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          pushes: record.pushes.toDto() as NumericDto,
        );
      case final HeartRateSeriesRecord record:
        return HeartRateSeriesRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          samples: record.samples.map((s) => s.toDto()).toList(),
        );
      case final SleepSessionRecord record:
        return SleepSessionRecordDto(
          id: record.id.toDto(),
          startTime: record.startTime.millisecondsSinceEpoch,
          endTime: record.endTime.millisecondsSinceEpoch,
          startZoneOffsetSeconds: record.startZoneOffsetSeconds,
          endZoneOffsetSeconds: record.endZoneOffsetSeconds,
          metadata: record.metadata.toDto(),
          title: record.title,
          notes: record.notes,
          stages: record.samples.map((s) => s.toDto()).toList(),
        );
      case final SleepStageRecord _:
        throw UnsupportedError(
          '$SleepStageRecord is not supported on Android. '
          'Use $SleepSessionRecord instead.',
        );
      case final HeartRateMeasurementRecord _:
        throw UnsupportedError(
          '$HeartRateMeasurementRecord is not supported on Android. '
          'Use $HeartRateSeriesRecord instead.',
        );
    }
  }
}

/// Converts [HealthRecordDto] to [HealthRecord].
@internal
extension HealthRecordDtoToDomain on HealthRecordDto {
  HealthRecord toDomain() {
    switch (this) {
      case final ActiveCaloriesBurnedRecordDto dto:
        return ActiveCaloriesBurnedRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          energy: dto.energy.toDomain() as Energy,
        );
      case final DistanceRecordDto dto:
        return DistanceRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          distance: dto.distance.toDomain() as Length,
        );
      case final FloorsClimbedRecordDto dto:
        return FloorsClimbedRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          floors: dto.floors.toDomain() as Numeric,
        );
      case final HeightRecordDto dto:
        return HeightRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          time: DateTime.fromMillisecondsSinceEpoch(dto.time),
          zoneOffsetSeconds: dto.zoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          height: dto.height.toDomain() as Length,
        );
      case final HydrationRecordDto dto:
        return HydrationRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          volume: dto.volume.toDomain() as Volume,
        );
      case final LeanBodyMassRecordDto dto:
        return LeanBodyMassRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          time: DateTime.fromMillisecondsSinceEpoch(dto.time),
          zoneOffsetSeconds: dto.zoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          mass: dto.mass.toDomain() as Mass,
        );
      case final BodyFatPercentageRecordDto dto:
        return BodyFatPercentageRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          time: DateTime.fromMillisecondsSinceEpoch(dto.time),
          zoneOffsetSeconds: dto.zoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          percentage: dto.percentage.toDomain() as Percentage,
        );
      case final BodyTemperatureRecordDto dto:
        return BodyTemperatureRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          time: DateTime.fromMillisecondsSinceEpoch(dto.time),
          zoneOffsetSeconds: dto.zoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          temperature: dto.temperature.toDomain() as Temperature,
        );
      case final StepRecordDto dto:
        return StepRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          count: dto.count.toDomain() as Numeric,
        );
      case final WeightRecordDto dto:
        return WeightRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          time: DateTime.fromMillisecondsSinceEpoch(dto.time),
          zoneOffsetSeconds: dto.zoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          weight: dto.weight.toDomain() as Mass,
        );
      case final WheelchairPushesRecordDto dto:
        return WheelchairPushesRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          pushes: dto.pushes.toDomain() as Numeric,
        );
      case final HeartRateSeriesRecordDto dto:
        return HeartRateSeriesRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          samples: dto.samples.map((s) => s.toDomain()).toList(),
        );
      case final SleepSessionRecordDto dto:
        return SleepSessionRecord(
          id: dto.id?.toHealthRecordId() ?? HealthRecordId.none,
          startTime: DateTime.fromMillisecondsSinceEpoch(dto.startTime),
          endTime: DateTime.fromMillisecondsSinceEpoch(dto.endTime),
          startZoneOffsetSeconds: dto.startZoneOffsetSeconds,
          endZoneOffsetSeconds: dto.endZoneOffsetSeconds,
          metadata: dto.metadata.toDomain(),
          samples: dto.stages.map((s) => s.toDomain()).toList(),
          title: dto.title,
          notes: dto.notes,
        );
    }
  }
}

/// Converts [HeartRateMeasurement] to [HeartRateMeasurementDto].
@internal
extension HeartRateMeasurementDtoMapper on HeartRateMeasurement {
  HeartRateMeasurementDto toDto() {
    return HeartRateMeasurementDto(
      time: time.millisecondsSinceEpoch,
      beatsPerMinute: beatsPerMinute.toDto() as NumericDto,
    );
  }
}

/// Converts [HeartRateMeasurementDto] to [HeartRateMeasurement].
@internal
extension HeartRateMeasurementDtoToDomain on HeartRateMeasurementDto {
  HeartRateMeasurement toDomain() {
    return HeartRateMeasurement(
      time: DateTime.fromMillisecondsSinceEpoch(time),
      beatsPerMinute: beatsPerMinute.toDomain() as Numeric,
    );
  }
}

extension SleepStageTypeDomainToDto on SleepStageType {
  SleepStageTypeDto toDto() {
    return switch (this) {
      SleepStageType.unknown => SleepStageTypeDto.unknown,
      SleepStageType.awake => SleepStageTypeDto.awake,
      SleepStageType.sleeping => SleepStageTypeDto.sleeping,
      SleepStageType.outOfBed => SleepStageTypeDto.outOfBed,
      SleepStageType.light => SleepStageTypeDto.light,
      SleepStageType.deep => SleepStageTypeDto.deep,
      SleepStageType.rem => SleepStageTypeDto.rem,
      SleepStageType.inBed => SleepStageTypeDto.inBed,
    };
  }
}

extension SleepStageTypeDtoToDomain on SleepStageTypeDto {
  SleepStageType toDomain() {
    return switch (this) {
      SleepStageTypeDto.unknown => SleepStageType.unknown,
      SleepStageTypeDto.awake => SleepStageType.awake,
      SleepStageTypeDto.sleeping => SleepStageType.sleeping,
      SleepStageTypeDto.outOfBed => SleepStageType.outOfBed,
      SleepStageTypeDto.light => SleepStageType.light,
      SleepStageTypeDto.deep => SleepStageType.deep,
      SleepStageTypeDto.rem => SleepStageType.rem,
      SleepStageTypeDto.inBed => SleepStageType.inBed,
    };
  }
}

extension SleepStageDomainToDto on SleepStage {
  SleepStageDto toDto() {
    return SleepStageDto(
      startTime: startTime.millisecondsSinceEpoch,
      endTime: endTime.millisecondsSinceEpoch,
      stage: stageType.toDto(),
    );
  }
}

extension SleepStageDtoToDomain on SleepStageDto {
  SleepStage toDomain() {
    return SleepStage(
      startTime: DateTime.fromMillisecondsSinceEpoch(startTime),
      endTime: DateTime.fromMillisecondsSinceEpoch(endTime),
      stageType: stage.toDomain(),
    );
  }
}
