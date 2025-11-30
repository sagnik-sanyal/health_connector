import 'package:health_connector_core/health_connector_core.dart'
    show RecordingMethod, DeviceType, Device, DataOrigin, Metadata;
import 'package:health_connector_hc_android/src/pigeon/health_connector_platform_api.g.dart'
    show RecordingMethodDto, DeviceTypeDto, DeviceDto, MetadataDto;
import 'package:meta/meta.dart' show internal;

/// Converts [RecordingMethod] to [RecordingMethodDto].
@internal
extension RecordingMethodDtoMapper on RecordingMethod {
  RecordingMethodDto toDto() {
    switch (this) {
      case RecordingMethod.unknown:
        return RecordingMethodDto.unknown;
      case RecordingMethod.manualEntry:
        return RecordingMethodDto.manualEntry;
      case RecordingMethod.automaticallyRecorded:
        return RecordingMethodDto.automaticallyRecorded;
      case RecordingMethod.activelyRecorded:
        return RecordingMethodDto.activelyRecorded;
    }
  }
}

/// Converts [RecordingMethodDto] to [RecordingMethod].
@internal
extension RecordingMethodDtoToDomain on RecordingMethodDto {
  RecordingMethod toDomain() {
    switch (this) {
      case RecordingMethodDto.unknown:
        return RecordingMethod.unknown;
      case RecordingMethodDto.manualEntry:
        return RecordingMethod.manualEntry;
      case RecordingMethodDto.automaticallyRecorded:
        return RecordingMethod.automaticallyRecorded;
      case RecordingMethodDto.activelyRecorded:
        return RecordingMethod.activelyRecorded;
    }
  }
}

/// Converts [DeviceType] to [DeviceTypeDto].
@internal
extension DeviceTypeDtoMapper on DeviceType {
  DeviceTypeDto toDto() {
    switch (this) {
      case DeviceType.unknown:
        return DeviceTypeDto.unknown;
      case DeviceType.watch:
        return DeviceTypeDto.watch;
      case DeviceType.phone:
        return DeviceTypeDto.phone;
      case DeviceType.scale:
        return DeviceTypeDto.scale;
      case DeviceType.ring:
        return DeviceTypeDto.ring;
      case DeviceType.fitnessBand:
        return DeviceTypeDto.fitnessBand;
      case DeviceType.chestStrap:
        return DeviceTypeDto.chestStrap;
      case DeviceType.headMounted:
        return DeviceTypeDto.headMounted;
      case DeviceType.smartDisplay:
        return DeviceTypeDto.smartDisplay;
    }
  }
}

/// Converts [DeviceTypeDto] to [DeviceType].
@internal
extension DeviceTypeDtoToDomain on DeviceTypeDto {
  DeviceType toDomain() {
    switch (this) {
      case DeviceTypeDto.unknown:
        return DeviceType.unknown;
      case DeviceTypeDto.watch:
        return DeviceType.watch;
      case DeviceTypeDto.phone:
        return DeviceType.phone;
      case DeviceTypeDto.scale:
        return DeviceType.scale;
      case DeviceTypeDto.ring:
        return DeviceType.ring;
      case DeviceTypeDto.fitnessBand:
        return DeviceType.fitnessBand;
      case DeviceTypeDto.chestStrap:
        return DeviceType.chestStrap;
      case DeviceTypeDto.headMounted:
        return DeviceType.headMounted;
      case DeviceTypeDto.smartDisplay:
        return DeviceType.smartDisplay;
    }
  }
}

/// Converts [Device] to [DeviceDto].
@internal
extension DeviceDtoMapper on Device {
  DeviceDto toDto() {
    return DeviceDto(
      type: type.toDto(),
      manufacturer: manufacturer,
      model: model,
    );
  }
}

/// Converts [DeviceDto] to [Device].
@internal
extension DeviceDtoToDomain on DeviceDto {
  Device toDomain() {
    return Device(
      type: type.toDomain(),
      manufacturer: manufacturer,
      model: model,
    );
  }
}

/// Converts [Metadata] to [MetadataDto].
@internal
extension MetadataDtoMapper on Metadata {
  MetadataDto toDto() {
    return MetadataDto(
      dataOrigin: dataOrigin.packageName,
      recordingMethod: recordingMethod.toDto(),
      lastModifiedTime: lastModifiedTime?.millisecondsSinceEpoch,
      clientRecordId: clientRecordId,
      clientRecordVersion: clientRecordVersion,
      device: device?.toDto(),
    );
  }
}

/// Converts [MetadataDto] to [Metadata].
@internal
extension MetadataDtoToDomain on MetadataDto {
  Metadata toDomain() {
    return Metadata(
      dataOrigin: DataOrigin(dataOrigin),
      recordingMethod: recordingMethod.toDomain(),
      lastModifiedTime: lastModifiedTime != null
          ? DateTime.fromMillisecondsSinceEpoch(lastModifiedTime!)
          : null,
      clientRecordId: clientRecordId,
      clientRecordVersion: clientRecordVersion,
      device: device?.toDomain(),
    );
  }
}
