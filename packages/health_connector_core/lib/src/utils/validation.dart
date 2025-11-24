/// Validates that a condition holds for a function argument.
///
/// ## Parameters
///
/// - [condition]: Boolean expression specifying the requirement to validate.
/// - [message]: String describing the failed requirement in the exception.
///
/// ## Throws
///
/// - [ArgumentError] if [condition] is false, using [message]
// ignore: avoid_positional_boolean_parameters
void require(bool condition, String message) {
  if (!condition) {
    throw ArgumentError(message);
  }
}

/// Validates that [endTime] is strictly after [startTime].
///
/// ## Parameters
///
/// - [startTime]: The expected starting point of the time interval.
/// - [endTime]: The expected ending point of the time interval.
///
/// ## Throws
///
/// - [ArgumentError] if [endTime] is not strictly after [startTime].
void requireEndTimeAfterStartTime({
  required DateTime startTime,
  required DateTime endTime,
}) {
  require(
    endTime.isAfter(startTime),
    'endTime must be after startTime. '
    'Got startTime=$startTime, endTime=$endTime',
  );
}
