import 'package:flutter/material.dart';
import 'package:health_connector/health_connector.dart' show Metadata;
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/theme/app_colors.dart';
import 'package:health_connector_toolbox/src/common/utils/date_format_utils.dart';

/// A reusable widget for displaying health record metadata information.
///
/// This widget shows all metadata fields including data origin, recording
/// method, timestamps, client identifiers, and device information in a
/// structured layout.
@immutable
final class HealthRecordMetadataInfo extends StatelessWidget {
  const HealthRecordMetadataInfo({required this.metadata, super.key});

  final Metadata metadata;

  @override
  Widget build(BuildContext context) {
    final device = metadata.device;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppTexts.metadata,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        _MetadataInfoRow(
          label: AppTexts.dataOrigin,
          value: metadata.dataOrigin.packageName,
        ),
        _MetadataInfoRow(
          label: AppTexts.recordingMethod,
          value: metadata.recordingMethod.name,
        ),
        _MetadataInfoRow(
          label: AppTexts.lastModified,
          value: metadata.lastModifiedTime != null
              ? DateFormatUtils.formatDateTime(metadata.lastModifiedTime)
              : AppTexts.nullValue,
        ),
        _MetadataInfoRow(
          label: AppTexts.clientRecordId,
          value: metadata.clientRecordId,
        ),
        _MetadataInfoRow(
          label: AppTexts.clientRecordVersion,
          value: metadata.clientRecordVersion,
        ),
        const SizedBox(height: 8),
        const Text(
          AppTexts.deviceLabel,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        if (device != null) ...[
          _MetadataInfoRow(label: AppTexts.type, value: device.type.name),
          _MetadataInfoRow(label: AppTexts.name, value: device.name),
          _MetadataInfoRow(
            label: AppTexts.manufacturer,
            value: device.manufacturer,
          ),
          _MetadataInfoRow(label: AppTexts.model, value: device.model),
          _MetadataInfoRow(
            label: AppTexts.hardwareVersion,
            value: device.hardwareVersion,
          ),
          _MetadataInfoRow(
            label: AppTexts.firmwareVersion,
            value: device.firmwareVersion,
          ),
          _MetadataInfoRow(
            label: AppTexts.softwareVersion,
            value: device.softwareVersion,
          ),
          _MetadataInfoRow(
            label: AppTexts.localIdentifier,
            value: device.localIdentifier,
          ),
          _MetadataInfoRow(
            label: AppTexts.udiDeviceId,
            value: device.udiDeviceIdentifier,
          ),
        ] else
          const _MetadataInfoRow(label: AppTexts.deviceLabel, value: null),
      ],
    );
  }
}

/// A private widget for displaying a single metadata field row.
///
/// Shows a label on the left and value on the right with appropriate styling.
/// Null values are displayed in gray italic text.
@immutable
final class _MetadataInfoRow extends StatelessWidget {
  const _MetadataInfoRow({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? AppTexts.nullValue,
              style: TextStyle(
                fontSize: 12,
                color: value == null ? AppColors.grey400 : AppColors.grey600,
                fontStyle: value == null ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
