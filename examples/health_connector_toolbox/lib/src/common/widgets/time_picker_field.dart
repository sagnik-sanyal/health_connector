import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/utils/date_format_utils.dart';

/// A form field widget for selecting a time (without date).
///
/// Displays a read-only text field that opens a time picker when tapped.
/// The selected time is formatted and displayed in the field.
@immutable
final class TimePickerField extends StatefulWidget {
  const TimePickerField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue,
    this.validator,
  });

  final String label;
  final TimeOfDay? initialValue;
  final ValueChanged<TimeOfDay> onChanged;
  final String? Function(TimeOfDay?)? validator;

  @override
  State<TimePickerField> createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  late final TextEditingController _controller;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialValue;
    _controller = TextEditingController(
      text: DateFormatUtils.formatTime(_selectedTime),
    );
  }

  @override
  void didUpdateWidget(TimePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedTime = widget.initialValue;
      _controller.text = DateFormatUtils.formatTime(_selectedTime);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: const Icon(AppIcons.accessTime),
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () => _selectTime(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${AppTexts.pleaseSelect} ${widget.label}';
        }
        if (widget.validator != null) {
          return widget.validator!(_selectedTime);
        }
        return null;
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final initialTime = _selectedTime ?? widget.initialValue ?? now;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedTime = pickedTime;
      _controller.text = DateFormatUtils.formatTime(pickedTime);
    });

    widget.onChanged(pickedTime);
  }
}
