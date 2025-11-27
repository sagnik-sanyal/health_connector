/// Helper function to parse datetime string from format DD-MM-YYYY HH:MM:SS.mmm
DateTime parseDateTime(String dateTimeString) {
  final parts = dateTimeString.split(' ');
  final dateParts = parts[0].split('-');
  final timeParts = parts[1].split(':');
  final secondParts = timeParts[2].split('.');

  return DateTime(
    int.parse(dateParts[2]),
    // year
    int.parse(dateParts[1]),
    // month
    int.parse(dateParts[0]),
    // day
    int.parse(timeParts[0]),
    // hour
    int.parse(timeParts[1]),
    // minute
    int.parse(secondParts[0]),
    // second
    int.parse(secondParts[1]), // millisecond
  );
}
