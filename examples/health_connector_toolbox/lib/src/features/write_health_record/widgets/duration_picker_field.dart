import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';

/// A form field widget for selecting a duration using a time picker.
///
/// Uses TimeOfDay to represent duration in hours and minutes (HH:MM format).
/// Displays a read-only text field that opens a time picker when tapped.
@immutable
final class DurationPickerField extends StatefulWidget {
  const DurationPickerField({
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
  State<DurationPickerField> createState() => _DurationPickerFieldState();
}

class _DurationPickerFieldState extends State<DurationPickerField> {
  late final TextEditingController _controller;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialValue;
    _controller = TextEditingController(text: _formatTime(_selectedTime));
  }

  @override
  void didUpdateWidget(DurationPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedTime = widget.initialValue;
      _controller.text = _formatTime(_selectedTime);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      _controller.text = _formatTime(pickedTime);
    });

    widget.onChanged(pickedTime);
  }
}
