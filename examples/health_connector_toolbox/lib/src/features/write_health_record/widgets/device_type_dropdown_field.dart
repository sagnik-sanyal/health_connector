import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show DeviceType;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/utils/health_connector_model_ui_extensions.dart';

/// A dropdown form field widget for selecting a device type.
///
/// Displays all available device types (phone, watch, scale, etc.) with
/// their display names and icons.
@immutable
final class DeviceTypeDropdownField extends StatelessWidget {
  const DeviceTypeDropdownField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue,
    this.validator,
  });

  final String label;
  final DeviceType? initialValue;
  final ValueChanged<DeviceType?> onChanged;
  final String? Function(DeviceType?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DeviceType>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(AppIcons.devices),
      ),
      items: DeviceType.values.map((deviceType) {
        return DropdownMenuItem(
          value: deviceType,
          child: Text(deviceType.displayName),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
