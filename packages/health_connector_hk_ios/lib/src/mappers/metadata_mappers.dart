import 'package:health_connector_core/health_connector_core.dart'
    show RecordingMethod, DeviceType, Device, DataOrigin, Metadata;
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show RecordingMethodDto, DeviceDto, DataOriginDto, MetadataDto;
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

/// Converts [Device] to [DeviceDto].
@internal
extension DeviceDtoMapper on Device {
  DeviceDto toDto() {
    return DeviceDto(
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
      type: DeviceType.unknown,
      manufacturer: manufacturer,
      model: model,
    );
  }
}

/// Converts [DataOrigin] to [DataOriginDto].
@internal
extension DataOriginDtoMapper on DataOrigin {
  DataOriginDto toDto() {
    return DataOriginDto(packageName: packageName);
  }
}

/// Converts [DataOriginDto] to [DataOrigin].
@internal
extension DataOriginDtoToDomain on DataOriginDto {
  DataOrigin toDomain() {
    return DataOrigin(packageName);
  }
}

/// Converts [Metadata] to [MetadataDto].
@internal
extension MetadataDtoMapper on Metadata {
  MetadataDto toDto() {
    return MetadataDto(
      dataOrigin: dataOrigin.toDto(),
      recordingMethod: recordingMethod.toDto(),
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
      dataOrigin: dataOrigin.toDomain(),
      recordingMethod: recordingMethod.toDomain(),
      clientRecordId: clientRecordId,
      clientRecordVersion: clientRecordVersion,
      device: device?.toDomain(),
    );
  }
}
