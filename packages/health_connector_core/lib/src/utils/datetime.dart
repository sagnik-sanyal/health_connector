/// Converts start and end times to a formatted string representation.
///
/// ## Parameters
///
/// - [startTime]: The start time to format.
/// - [endTime]: The end time to format.
///
/// ## Returns
///
/// A string in the format:
/// `'${startTime.toIso8601String()} to ${endTime.toIso8601String()}'`
String formatTimeRange({
  required DateTime startTime,
  required DateTime endTime,
}) {
  return '${startTime.toIso8601String()} to ${endTime.toIso8601String()}';
}

