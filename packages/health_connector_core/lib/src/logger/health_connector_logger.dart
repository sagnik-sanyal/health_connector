import 'dart:developer' show log;

/// A singleton logger that wraps the `log` function from `dart:developer`.
///
/// This logger provides a consistent structured logging interface with
/// formatted messages across the plugin. It supports structured logging with
/// operation, optional phase, optional message, and context.
abstract final class HealthConnectorLogger {
  /// Private constructor to prevent instantiation.
  const HealthConnectorLogger._();

  /// Whether logging is enabled.
  ///
  /// When set to `false`, all logging methods will return immediately without
  /// logging any messages. Defaults to `true`.
  static bool isEnabled = true;

  /// Indentation for top-level fields.
  static const String _indentLevel1 = '   ';

  /// Indentation for nested fields (exception, context).
  static const String _indentLevel2 = '     ';

  /// Formats a structured log message in JSON-like format.
  ///
  /// Creates a formatted message with indentation, including
  /// only non-null fields.
  ///
  /// ## Parameters
  ///
  /// - [operation]: The operation being performed (e.g., 'readRecords').
  /// - [phase]: Optional phase of the operation (e.g., 'entry', 'completed').
  /// - [message]: Optional message to include in the log.
  /// - [context]: Optional map of contextual information.
  /// - [exception]: Optional exception object.
  /// - [stackTrace]: Optional stack trace.
  ///
  /// ## Returns
  ///
  /// A formatted string in JSON-like format with indentation.
  static String _formatStructuredMessage({
    required String operation,
    String? phase,
    String? message,
    Map<String, dynamic>? context,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    final fields = <String>[];

    // Always include operation
    fields.add('${_indentLevel1}operation: $operation,');

    // Include phase if provided
    if (phase != null) {
      fields.add('${_indentLevel1}phase: $phase,');
    }

    // Include message if provided
    if (message != null) {
      fields.add('${_indentLevel1}message: $message,');
    }

    // Include exception block if exception or stackTrace is provided
    if (exception != null || stackTrace != null) {
      final exceptionFields = <String>[];
      if (exception != null) {
        exceptionFields.add('${_indentLevel2}cause: $exception,');
      }
      if (stackTrace != null) {
        exceptionFields.add('${_indentLevel2}stack_trace: $stackTrace,');
      }
      fields.add('${_indentLevel1}exception: {');
      fields.addAll(exceptionFields);
      fields.add('$_indentLevel1},');
    }

    // Include context if provided and not empty
    if (context != null && context.isNotEmpty) {
      fields.add('${_indentLevel1}context: {');
      for (final entry in context.entries) {
        fields.add('$_indentLevel2${entry.key}: ${entry.value},');
      }
      fields.add('$_indentLevel1},');
    }

    // Build the final message
    buffer.writeln('{');
    buffer.writeAll(fields, '\n');
    buffer.write('\n}');

    return buffer.toString();
  }

  /// Logs an informational message.
  ///
  /// Use this method for general informational messages that describe normal
  /// application flow.
  ///
  /// ## Parameters
  ///
  /// - [tag]: A tag for categorizing the log entry (converted to uppercase).
  /// - [operation]: The operation being performed.
  /// - [phase]: Optional phase of the operation.
  /// - [message]: Optional message to include in the log.
  /// - [context]: Optional contextual information.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// HealthConnectorLogger.info(
  ///   'API',
  ///   operation: 'readRecords',
  ///   phase: 'succeeded',
  ///   message: 'Successfully read records',
  ///   context: {'recordCount': 42, 'duration': '123ms'},
  /// );
  /// ```
  static void info(
    String tag, {
    required String operation,
    String? phase,
    String? message,
    Map<String, dynamic>? context,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      _LogLevel.info,
      tag,
      operation: operation,
      phase: phase,
      message: message,
      context: context,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Logs a debug message.
  ///
  /// Use this method for detailed diagnostic information that is typically
  /// only of interest when diagnosing problems.
  ///
  /// ## Parameters
  ///
  /// - [tag]: A tag for categorizing the log entry (converted to uppercase).
  /// - [operation]: The operation being performed.
  /// - [phase]: Optional phase of the operation.
  /// - [message]: Optional message to include in the log.
  /// - [context]: Optional contextual information.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// HealthConnectorLogger.debug(
  ///   'API',
  ///   operation: 'readRecords',
  ///   phase: 'entry',
  ///   message: 'Starting to read records',
  ///   context: {'dataType': 'StepsRecord', 'pageSize': 100},
  /// );
  /// ```
  static void debug(
    String tag, {
    required String operation,
    String? phase,
    String? message,
    Map<String, dynamic>? context,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      _LogLevel.debug,
      tag,
      operation: operation,
      phase: phase,
      message: message,
      context: context,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Logs a warning message.
  ///
  /// Use this method for warning messages that indicate potential problems or
  /// unexpected behavior that doesn't prevent the application from functioning.
  ///
  /// ## Parameters
  ///
  /// - [tag]: A tag for categorizing the log entry (converted to uppercase).
  /// - [operation]: The operation being performed.
  /// - [phase]: Optional phase of the operation.
  /// - [message]: Optional message to include in the log.
  /// - [context]: Optional contextual information.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// HealthConnectorLogger.warning(
  ///   'API',
  ///   operation: 'readRecords',
  ///   phase: 'slow operation detected',
  ///   message: 'Operation exceeded threshold',
  ///   context: {'duration': '6234ms', 'threshold': '5000ms'},
  /// );
  /// ```
  static void warning(
    String tag, {
    required String operation,
    String? phase,
    String? message,
    Map<String, dynamic>? context,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      _LogLevel.warning,
      tag,
      operation: operation,
      phase: phase,
      message: message,
      context: context,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Logs an error message.
  ///
  /// Use this method for error messages that indicate serious problems that
  /// may prevent the application from functioning correctly.
  ///
  /// ## Parameters
  ///
  /// - [tag]: A tag for categorizing the log entry (converted to uppercase).
  /// - [operation]: The operation being performed.
  /// - [phase]: Optional phase of the operation.
  /// - [message]: Optional message to include in the log.
  /// - [context]: Optional contextual information.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Examples
  ///
  /// ```dart
  /// HealthConnectorLogger.error(
  ///   'API',
  ///   operation: 'readRecords',
  ///   phase: 'failed',
  ///   message: 'Failed to read records',
  ///   context: {'dataType': 'StepsRecord', 'duration': '123ms'},
  ///   exception: e,
  ///   stackTrace: st,
  /// );
  /// ```
  static void error(
    String tag, {
    required String operation,
    String? phase,
    String? message,
    Map<String, dynamic>? context,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      _LogLevel.error,
      tag,
      operation: operation,
      phase: phase,
      message: message,
      context: context,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Formats a [DateTime] to the log format:
  /// `day-month-year hour:minute:second.millisecond`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final dt = DateTime(2025, 9, 22, 15, 35, 55, 678);
  /// final formatted = HealthConnectorLogger._formatDateTime(dt);
  /// print(formatted); // '22-09-2025 15:35:55.678'
  /// ```
  ///
  /// ## Parameters
  ///
  /// - [dateTime]: The datetime to format.
  ///
  /// ## Returns
  ///
  /// A formatted string in the format
  /// `day-month-year hour:minute:second.millisecond`.
  static String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final millisecond = dateTime.millisecond.toString().padLeft(3, '0');

    return '$day-$month-$year $hour:$minute:$second.$millisecond';
  }

  /// Internal method that formats and logs the message.
  ///
  /// Handles all logging logic including enabled check, message formatting,
  /// and output. Formats the message according to the specified format:
  /// ```
  /// [{datetime}][{level}]:
  /// {
  ///    operation: {operation},
  ///    phase: {phase},  // Optional, only included if provided
  ///    message: {message},
  ///    exception: {
  ///      cause: {exception},
  ///      stack_trace: {stackTrace},
  ///    },
  ///    context: {
  ///      key1: value1,
  ///    },
  /// }
  /// ```
  ///
  /// ## Parameters
  ///
  /// - [level]: The log level (DEBUG, INFO, WARNING, ERROR).
  /// - [tag]: The tag for categorizing the log entry.
  /// - [operation]: The operation being performed.
  /// - [phase]: Optional phase of the operation.
  /// - [message]: Optional message to include in the log.
  /// - [context]: Optional contextual information.
  /// - [exception]: Optional exception object.
  /// - [stackTrace]: Optional stack trace.
  static void _log(
    _LogLevel level,
    String tag, {
    required String operation,
    String? phase,
    String? message,
    Map<String, dynamic>? context,
    Object? exception,
    StackTrace? stackTrace,
  }) {
    if (!isEnabled) {
      return;
    }

    final structuredMessage = _formatStructuredMessage(
      operation: operation,
      phase: phase,
      message: message,
      context: context,
      exception: exception,
      stackTrace: stackTrace,
    );

    final now = DateTime.now();
    final formattedDateTime = _formatDateTime(now);
    final formattedMessage =
        '[$formattedDateTime][${level.name}]: \n$structuredMessage';

    log(
      formattedMessage,
      name: tag,
      level: level.value,
    );
  }
}

/// Enum representing the different log levels.
///
/// Each level has a [name] field that contains the string representation
/// of the log level and a [value] field that contains the integer value
/// for `dart:developer.log`.
enum _LogLevel {
  /// Debug level for detailed diagnostic information.
  debug('DEBUG', 500),

  /// Info level for general informational messages.
  info('INFO', 800),

  /// Warning level for potential problems or unexpected behavior.
  warning('WARNING', 900),

  /// Error level for serious problems.
  error('ERROR', 1000);

  /// The string name of the log level.
  final String name;

  /// The integer value for `dart:developer.log`.
  final int value;

  /// Creates a [_LogLevel] with the given [name] and [value].
  const _LogLevel(this.name, this.value);
}
