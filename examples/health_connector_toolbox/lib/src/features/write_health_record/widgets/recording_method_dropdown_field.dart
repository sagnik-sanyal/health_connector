import 'package:flutter/material.dart';
import 'package:health_connector/health_connector.dart' show RecordingMethod;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/utils/health_connector_model_ui_extensions.dart';

/// A dropdown form field widget for selecting a recording method.
///
/// Displays all available recording methods (manual entry, automatically
/// recorded, actively recorded) with their display names.
@immutable
final class RecordingMethodDropdownField extends StatelessWidget {
  const RecordingMethodDropdownField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue = RecordingMethod.unknown,
    this.validator,
  });

  final String label;
  final RecordingMethod initialValue;
  final ValueChanged<RecordingMethod?> onChanged;
  final String? Function(RecordingMethod?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<RecordingMethod>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(AppIcons.settings),
      ),
      items: RecordingMethod.values.map((method) {
        return DropdownMenuItem(value: method, child: Text(method.displayName));
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
