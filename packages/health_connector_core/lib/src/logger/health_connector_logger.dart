import 'dart:developer' show log;

import 'package:meta/meta.dart' show internal, immutable;

/// A singleton logger that wraps the `log` function from `dart:developer`.
///
/// This logger provides a consistent logging interface with formatted messages
/// across the plugin.
///
/// ## Usage
///
/// ```dart
/// final logger = HealthConnectorLogger();
/// logger.info('INIT', 'Plugin initialized');
/// logger.error('API', 'Request failed', exception: e, stackTrace: st);
/// ```
///
/// ## Log Format
///
/// Log messages are formatted as:
/// `[{logger_name}][{level}][{tag}]: {datetime}: {message}`
///
/// Where logger_name, level, and tag are converted to uppercase.
@immutable
final class HealthConnectorLogger {
  /// Returns the singleton instance of [HealthConnectorLogger], creating it if
  /// necessary.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create logger
  /// final logger = HealthConnectorLogger();
  /// ```
  factory HealthConnectorLogger() {
    _instance ??= const HealthConnectorLogger._();
    return _instance!;
  }

  /// Private constructor for creating a [HealthConnectorLogger] instance.
  const HealthConnectorLogger._();

  /// The singleton instance of [HealthConnectorLogger].
  static HealthConnectorLogger? _instance;

  /// The logger name in uppercase.
  static const String _loggerName = 'HEALTH_CONNECTOR';

  /// Logs an informational message.
  ///
  /// Use this method for general informational messages that describe normal
  /// application flow.
  ///
  /// ## Parameters
  ///
  /// - [tag]: A tag for categorizing the log entry (converted to uppercase).
  /// - [message]: The log message to output.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Example
  ///
  /// ```dart
  /// logger.info('INIT', 'Plugin initialized successfully');
  /// ```
  void info(
    String tag,
    String message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      tag,
      message,
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
  /// - [message]: The log message to output.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Example
  ///
  /// ```dart
  /// logger.debug('CONFIG', 'Configuration loaded: $config');
  /// ```
  void debug(
    String tag,
    String message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      tag,
      message,
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
  /// - [message]: The log message to output.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Example
  ///
  /// ```dart
  /// logger.warning('NETWORK', 'Network latency detected');
  /// ```
  void warning(
    String tag,
    String message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      tag,
      message,
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
  /// - [message]: The log message to output.
  /// - [exception]: Optional exception object to include in the log.
  /// - [stackTrace]: Optional stack trace to include in the log.
  ///
  /// ## Example
  ///
  /// ```dart
  /// logger.error('DB', 'Failed to connect', exception: e, stackTrace: st);
  /// ```
  void error(
    String tag,
    String message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      tag,
      message,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  /// Internal method that formats and logs the message.
  ///
  /// Formats the message according to the specified format:
  /// `[{logger_name}][{level}][{tag}]: {datetime}: {message}`
  ///
  /// ## Parameters
  ///
  /// - [level]: The log level (DEBUG, INFO, WARNING, ERROR).
  /// - [tag]: The tag for categorizing the log entry.
  /// - [message]: The log message.
  /// - [exception]: Optional exception object.
  /// - [stackTrace]: Optional stack trace.
  void _log(
    LogLevel level,
    String tag,
    String message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    final formattedMessage =
        '[$_loggerName][${level.name}][${tag.toUpperCase()}]: '
        '${DateTime.now()}: $message';
    final logLevel = _getLogLevel(level);

    log(
      formattedMessage,
      name: _loggerName,
      level: logLevel,
      error: exception,
      stackTrace: stackTrace,
    );
  }

  /// Maps log level enum to integer values for `developer.log`.
  ///
  /// ## Parameters
  ///
  /// - [level]: The log level enum (DEBUG, INFO, WARNING, ERROR).
  ///
  /// ## Returns
  ///
  /// The integer log level value:
  /// - DEBUG: 500
  /// - INFO: 800
  /// - WARNING: 900
  /// - ERROR: 1000
  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}

/// Enum representing the different log levels.
///
/// Each level has a [name] field that contains the string representation
/// of the log level.
@internal
enum LogLevel {
  /// Debug level for detailed diagnostic information.
  debug('DEBUG'),

  /// Info level for general informational messages.
  info('INFO'),

  /// Warning level for potential problems or unexpected behavior.
  warning('WARNING'),

  /// Error level for serious problems.
  error('ERROR');

  /// The string name of the log level.
  final String name;

  /// Creates a [LogLevel] with the given [name].
  const LogLevel(this.name);
}
