import 'package:flutter/material.dart';
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/utils/date_format_utils.dart';

/// A form field widget for selecting a date (without time).
///
/// Displays a read-only text field that opens a date picker when tapped.
/// The selected date is formatted and displayed in the field.
@immutable
final class DatePickerField extends StatefulWidget {
  const DatePickerField({
    required this.label,
    required this.onChanged,
    super.key,
    this.initialValue,
    this.validator,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? initialValue;
  final ValueChanged<DateTime> onChanged;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late final TextEditingController _controller;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
    _controller = TextEditingController(
      text: DateFormatUtils.formatDate(_selectedDate),
    );
  }

  @override
  void didUpdateWidget(DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedDate = widget.initialValue;
      _controller.text = DateFormatUtils.formatDate(_selectedDate);
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
        suffixIcon: const Icon(AppIcons.calendarToday),
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${AppTexts.pleaseSelect} ${widget.label}';
        }
        if (widget.validator != null) {
          return widget.validator!(_selectedDate);
        }
        return null;
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? widget.initialValue ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.firstDate ?? DateTime(2000),
      lastDate: widget.lastDate ?? DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    // Preserve time from initial value if it exists, otherwise set to 00:00:00
    final selectedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      _selectedDate?.hour ?? 0,
      _selectedDate?.minute ?? 0,
    );

    setState(() {
      _selectedDate = selectedDateTime;
      _controller.text = DateFormatUtils.formatDate(selectedDateTime);
    });

    widget.onChanged(selectedDateTime);
  }
}
