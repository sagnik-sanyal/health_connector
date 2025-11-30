import 'package:health_connector_core/health_connector_core.dart'
    show RecordingMethod, DeviceType, Device, DataOrigin, Metadata;
import 'package:health_connector_hk_ios/src/pigeon/health_connector_platform_api.g.dart'
    show DeviceDto, MetadataDto;
import 'package:meta/meta.dart' show internal;

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

/// Converts [Metadata] to [MetadataDto].
@internal
extension MetadataDtoMapper on Metadata {
  MetadataDto toDto() {
    return MetadataDto(
      dataOrigin: dataOrigin.packageName,
      isManualEntry: recordingMethod == RecordingMethod.manualEntry,
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
      recordingMethod: isManualEntry
          ? RecordingMethod.manualEntry
          : RecordingMethod.unknown,
      clientRecordId: clientRecordId,
      clientRecordVersion: clientRecordVersion,
      device: device?.toDomain(),
    );
  }
}
