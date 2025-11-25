import 'package:flutter/material.dart';

/// Base state class that provides date/time range state management for pages
/// that need start and end date/time selection.
abstract class DateTimeRangePageState<T extends StatefulWidget>
    extends State<T> {
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  /// The selected start date (without time).
  DateTime? get startDate => _startDate;

  /// The selected start time (without date).
  TimeOfDay? get startTime => _startTime;

  /// The selected end date (without time).
  DateTime? get endDate => _endDate;

  /// The selected end time (without date).
  TimeOfDay? get endTime => _endTime;

  /// The combined start date and time as a DateTime object.
  /// Returns null if either start date or start time is not selected.
  DateTime? get startDateTime {
    if (_startDate == null || _startTime == null) {
      return null;
    }
    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  /// The combined end date and time as a DateTime object.
  /// Returns null if either end date or end time is not selected.
  DateTime? get endDateTime {
    if (_endDate == null || _endTime == null) {
      return null;
    }
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    _initializeDefaultRange();
  }

  /// Sets the start date.
  void setStartDate(DateTime? date) {
    setState(() {
      _startDate = date;
    });
  }

  /// Sets the start time.
  void setStartTime(TimeOfDay? time) {
    setState(() {
      _startTime = time;
    });
  }

  /// Sets the end date.
  void setEndDate(DateTime? date) {
    setState(() {
      _endDate = date;
    });
  }

  /// Sets the end time.
  void setEndTime(TimeOfDay? time) {
    setState(() {
      _endTime = time;
    });
  }

  /// Resets all date/time fields to null.
  void resetDateTimeRange() {
    setState(() {
      _startDate = null;
      _startTime = null;
      _endDate = null;
      _endTime = null;
    });
  }

  /// Initializes default date/time range values:
  /// - End date/time to current date/time
  /// - Start date/time to 1 month ago
  void _initializeDefaultRange() {
    final now = DateTime.now();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    setState(() {
      // Set end date/time to now
      _endDate = DateTime(now.year, now.month, now.day);
      _endTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Set start date/time to 1 month ago
      _startDate = DateTime(
        oneMonthAgo.year,
        oneMonthAgo.month,
        oneMonthAgo.day,
      );
      _startTime = TimeOfDay(
        hour: oneMonthAgo.hour,
        minute: oneMonthAgo.minute,
      );
    });
  }
}
