import Foundation
import HealthKit

// ==================== METADATA MAPPERS ====================

extension MetadataDto {
    /**
     * Converts this DTO to a HealthKit metadata dictionary.
     *
     * Uses standard HealthKit metadata keys where available:
     * - `HKMetadataKeySyncIdentifier` for clientRecordId
     * - `HKMetadataKeySyncVersion` for clientRecordVersion
     * - `HKMetadataKeyWasUserEntered` for manual entry detection
     * - `HKMetadataKeyDeviceName` for device name (redundancy with HKDevice.name)
     * - `HKMetadataKeyTimeZone` for timezone identifier (if provided)
     *
     * - Parameter timeZone: Optional timezone to store in metadata. If nil, uses device's current timezone.
     */
    func toHealthKitMetadata(timeZone: TimeZone? = nil) -> [String: Any] {
        var metadata: [String: Any] = [:]

        // Use standard HealthKit keys for sync identifiers
        if let clientRecordId = clientRecordId {
            metadata[HKMetadataKeySyncIdentifier] = clientRecordId
        }
        if let clientRecordVersion = clientRecordVersion {
            metadata[HKMetadataKeySyncVersion] = NSNumber(value: clientRecordVersion)
        }

        // Map isManualEntry to HKMetadataKeyWasUserEntered
        metadata[HKMetadataKeyWasUserEntered] = isManualEntry

        // Store device name in metadata for redundancy (also stored in HKDevice.name)
        let deviceName = deviceName ?? deviceModel
        if let deviceName = deviceName {
            metadata[HKMetadataKeyDeviceName] = deviceName
        }

        // Store timezone identifier in metadata using standard HealthKit key
        // Use provided timezone or fallback to device's current timezone
        let timeZoneToStore = timeZone ?? TimeZone.current
        metadata[HKMetadataKeyTimeZone] = timeZoneToStore.identifier

        return metadata
    }

    /**
     * Extracts the device from this DTO for HealthKit sample creation.
     *
     * Uses `deviceModel` value for `name` if `deviceName` is null, as per HealthKit best practices.
     * Returns `nil` if all device fields are null.
     *
     * **Important:** HealthKit requires at least one non-nil field when creating an `HKDevice`.
     * If all fields are nil, HealthKit will throw:
     * ```
     * NSInvalidArgumentException: 'At least one field of the device must be non-nil.'
     * ```
     * This method prevents this exception by returning `nil` when no device information is available.
     *
     * - Returns: An `HKDevice` instance if at least one field is non-nil, otherwise `nil`
     */
    func toHealthKitDevice() -> HKDevice? {
        // Check if at least one field is non-nil (HealthKit requirement)
        let deviceName = deviceName ?? deviceModel
        let hasAnyField = deviceName != nil ||
                          deviceManufacturer != nil ||
                          deviceHardwareVersion != nil ||
                          deviceFirmwareVersion != nil ||
                          deviceSoftwareVersion != nil ||
                          deviceLocalIdentifier != nil ||
                          deviceUdiDeviceIdentifier != nil
        
        guard hasAnyField else {
            return nil
        }
        
        return HKDevice(
            name: deviceName,
            manufacturer: deviceManufacturer,
            model: deviceModel,
            hardwareVersion: deviceHardwareVersion,
            firmwareVersion: deviceFirmwareVersion,
            softwareVersion: deviceSoftwareVersion,
            localIdentifier: deviceLocalIdentifier,
            udiDeviceIdentifier: deviceUdiDeviceIdentifier
        )
    }
}

extension Dictionary where Key == String, Value == Any {
    /**
     * Converts HealthKit metadata dictionary to a `MetadataDto`.
     *
     * Reads from standard HealthKit metadata keys:
     * - `HKMetadataKeySyncIdentifier` -> clientRecordId
     * - `HKMetadataKeySyncVersion` -> clientRecordVersion
     * - `HKMetadataKeyWasUserEntered` -> isManualEntry
     * - `HKMetadataKeyDeviceName` -> device name (if not in HKDevice)
     */
    func toMetadataDto(source: HKSource, device: HKDevice?) -> MetadataDto {
        // Extract sync identifier from standard HealthKit key
        let clientRecordId = self[HKMetadataKeySyncIdentifier] as? String

        // Extract sync version from standard HealthKit key
        let clientRecordVersion: Int64?
        if let versionNumber = self[HKMetadataKeySyncVersion] as? NSNumber {
            clientRecordVersion = versionNumber.int64Value
        } else {
            clientRecordVersion = nil
        }

        // Extract isManualEntry from HKMetadataKeyWasUserEntered
        // Default to false if not present (unknown/not manual entry)
        let isManualEntry = self[HKMetadataKeyWasUserEntered] as? Bool ?? false

        // Extract device information from HKDevice
        // Device name is extracted from HKDevice.name
        // HKMetadataKeyDeviceName in metadata is for redundancy but we prefer HKDevice.name

        return MetadataDto(
            clientRecordId: clientRecordId,
            clientRecordVersion: clientRecordVersion,
            dataOrigin: source.bundleIdentifier,
            deviceName: device?.name,
            deviceManufacturer: device?.manufacturer,
            deviceModel: device?.model,
            deviceHardwareVersion: device?.hardwareVersion,
            deviceFirmwareVersion: device?.firmwareVersion,
            deviceSoftwareVersion: device?.softwareVersion,
            deviceLocalIdentifier: device?.localIdentifier,
            deviceUdiDeviceIdentifier: device?.udiDeviceIdentifier,
            isManualEntry: isManualEntry
        )
    }

    /**
     * Extracts timezone offset in seconds from GMT from the metadata dictionary.
     *
     * Reads the timezone identifier from `HKMetadataKeyTimeZone` and calculates the offset
     * for the given date (important because timezone offsets vary due to daylight saving time).
     *
     * - Parameter date: The date to calculate the timezone offset for
     * - Returns: The timezone offset in seconds from GMT, or `nil` if timezone information is not available
     */
    func extractTimeZoneOffset(for date: Date) -> Int64? {
        // Read the timezone string from sample metadata
        guard let timeZoneString = self[HKMetadataKeyTimeZone] as? String,
              let timeZone = TimeZone(identifier: timeZoneString) else {
            return nil
        }

        // Get seconds offset from GMT for the given date
        // This is important because timezone offsets vary due to daylight saving time
        let secondsFromGMT = timeZone.secondsFromGMT(for: date)

        return Int64(secondsFromGMT)
    }
}

