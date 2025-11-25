import Foundation
import OSLog

/**
 * A singleton logger that wraps Apple's OSLog framework.
 *
 * This logger provides a consistent structured logging interface with
 * formatted messages across the plugin. It supports structured logging with
 * operation, phase, optional message, and context.
 */
internal enum HealthConnectorLogger {
    /**
     * OSLog subsystem identifier for Health Connector iOS plugin.
     */
    private static let subsystem = "com.phamtunglam.health_connector_hk_ios"
    
    /**
     * Whether logging is enabled.
     *
     * When set to `false`, all logging methods will return immediately without
     * logging any messages. Defaults to `true`.
     */
    private static var _isEnabled: Bool = true
    
    /**
     * Whether logging is enabled.
     *
     * When set to `false`, all logging methods will return immediately without
     * logging any messages. Defaults to `true`.
     */
    static var isEnabled: Bool {
        get { _isEnabled }
        set { _isEnabled = newValue }
    }
    
    /**
     * Sets whether logging is enabled.
     *
     * When set to `false`, all logging methods will return immediately without
     * logging any messages.
     *
     * - Parameter enabled: Whether to enable logging.
     */
    static func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
    }
    
    /**
     * Indentation for top-level fields.
     */
    private static let indentLevel1 = "   "
    
    /**
     * Indentation for nested fields (exception, context).
     */
    private static let indentLevel2 = "     "
    
    /**
     * Date formatter for timestamps: day-month-year hour:minute:second.millisecond
     */
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    /**
     * Formats a structured log message in JSON-like format.
     *
     * Creates a formatted message with indentation, including
     * only non-nil fields.
     *
     * - Parameters:
     *   - operation: The operation being performed (e.g., 'readRecords').
     *   - phase: The phase of the operation (e.g., 'entry', 'completed').
     *   - message: Optional message to include in the log.
     *   - context: Optional dictionary of contextual information.
     *   - exception: Optional error object.
     *   - stackTrace: Optional stack trace string.
     * - Returns: A formatted string in JSON-like format with indentation.
     */
    private static func formatStructuredMessage(
        operation: String,
        phase: String,
        message: String? = nil,
        context: [String: Any?]? = nil,
        exception: Error? = nil,
        stackTrace: String? = nil
    ) -> String {
        var fields: [String] = []
        
        // Always include operation and phase
        fields.append("\(indentLevel1)operation: \(operation),")
        fields.append("\(indentLevel1)phase: \(phase),")
        
        // Include message if provided
        if let message = message {
            fields.append("\(indentLevel1)message: \(message),")
        }
        
        // Include exception block if exception or stackTrace is provided
        if exception != nil || stackTrace != nil {
            var exceptionFields: [String] = []
            if let exception = exception {
                exceptionFields.append("\(indentLevel2)cause: \(String(describing: exception)),")
            }
            if let stackTrace = stackTrace {
                exceptionFields.append("\(indentLevel2)stack_trace: \(stackTrace),")
            }
            fields.append("\(indentLevel1)exception: {")
            fields.append(contentsOf: exceptionFields)
            fields.append("\(indentLevel1)},")
        }
        
        // Include context if provided and not empty
        if let context = context, !context.isEmpty {
            fields.append("\(indentLevel1)context: {")
            for (key, value) in context {
                fields.append("\(indentLevel2)\(key): \(String(describing: value)),")
            }
            fields.append("\(indentLevel1)},")
        }
        
        // Build the final message
        return "{\n" + fields.joined(separator: "\n") + "\n}"
    }
    
    /**
     * Formats a Date to the log format:
     * `day-month-year hour:minute:second.millisecond`.
     *
     * - Parameter date: The date to format.
     * - Returns: A formatted string in the format
     * `day-month-year hour:minute:second.millisecond`.
     */
    private static func formatDateTime(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    /**
     * Internal method that formats and logs the message.
     *
     * Handles all logging logic including enabled check, message formatting,
     * and output. Formats the message according to the specified format:
     * ```
     * [{datetime}][{level}]:
     * {
     *    operation: {operation},
     *    phase: {phase},
     *    message: {message},
     *    exception: {
     *      cause: {exception},
     *      stack_trace: {stackTrace},
     *    },
     *    context: {
     *      key1: value1,
     *    },
     * }
     * ```
     *
     * - Parameters:
     *   - level: The log level (DEBUG, INFO, WARNING, ERROR).
     *   - tag: The tag for categorizing the log entry (converted to uppercase).
     *   - operation: The operation being performed.
     *   - phase: The phase of the operation.
     *   - message: Optional message to include in the log.
     *   - context: Optional contextual information.
     *   - exception: Optional error object.
     */
    private static func log(
        level: OSLogType,
        tag: String,
        operation: String,
        phase: String,
        message: String? = nil,
        context: [String: Any?]? = nil,
        exception: Error? = nil
    ) {
        guard isEnabled else {
            return
        }
        
        // Extract stack trace from exception if available
        let stackTrace: String?
        if exception != nil {
            stackTrace = Thread.callStackSymbols.joined(separator: "\n")
        } else {
            stackTrace = nil
        }
        
        let structuredMessage = formatStructuredMessage(
            operation: operation,
            phase: phase,
            message: message,
            context: context,
            exception: exception,
            stackTrace: stackTrace
        )
        
        let now = Date()
        let formattedDateTime = formatDateTime(now)
        let levelName = levelName(for: level)
        let formattedMessage = "[\(formattedDateTime)][\(levelName)]: \n\(structuredMessage)"
        
        let uppercaseTag = tag.uppercased()
        let logger = Logger(subsystem: subsystem, category: uppercaseTag)
        
        // Use OSLog with appropriate level
        switch level {
        case .debug:
            logger.debug("\(formattedMessage)")
        case .info:
            logger.info("\(formattedMessage)")
        case .default:
            logger.log("\(formattedMessage)")
        case .error, .fault:
            logger.error("\(formattedMessage)")
        default:
            logger.log("\(formattedMessage)")
        }
    }
    
    /**
     * Gets the string name for a log level.
     *
     * - Parameter level: The OSLog level.
     * - Returns: The string representation of the level.
     */
    private static func levelName(for level: OSLogType) -> String {
        switch level {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .default:
            return "WARNING"
        case .error, .fault:
            return "ERROR"
        default:
            return "UNKNOWN"
        }
    }
    
    /**
     * Logs a debug message.
     *
     * Use this method for detailed diagnostic information that is typically
     * only of interest when diagnosing problems.
     *
     * - Parameters:
     *   - tag: A tag for categorizing the log entry (converted to uppercase).
     *   - operation: The operation being performed.
     *   - phase: The phase of the operation.
     *   - message: Optional message to include in the log.
     *   - context: Optional contextual information.
     *   - exception: Optional error object to include in the log.
     */
    static func debug(
        tag: String,
        operation: String,
        phase: String,
        message: String? = nil,
        context: [String: Any?]? = nil,
        exception: Error? = nil
    ) {
        log(
            level: .debug,
            tag: tag,
            operation: operation,
            phase: phase,
            message: message,
            context: context,
            exception: exception
        )
    }
    
    /**
     * Logs an informational message.
     *
     * Use this method for general informational messages that describe normal
     * application flow.
     *
     * - Parameters:
     *   - tag: A tag for categorizing the log entry (converted to uppercase).
     *   - operation: The operation being performed.
     *   - phase: The phase of the operation.
     *   - message: Optional message to include in the log.
     *   - context: Optional contextual information.
     *   - exception: Optional error object to include in the log.
     */
    static func info(
        tag: String,
        operation: String,
        phase: String,
        message: String? = nil,
        context: [String: Any?]? = nil,
        exception: Error? = nil
    ) {
        log(
            level: .info,
            tag: tag,
            operation: operation,
            phase: phase,
            message: message,
            context: context,
            exception: exception
        )
    }
    
    /**
     * Logs a warning message.
     *
     * Use this method for warning messages that indicate potential problems or
     * unexpected behavior that doesn't prevent the application from functioning.
     *
     * - Parameters:
     *   - tag: A tag for categorizing the log entry (converted to uppercase).
     *   - operation: The operation being performed.
     *   - phase: The phase of the operation.
     *   - message: Optional message to include in the log.
     *   - context: Optional contextual information.
     *   - exception: Optional error object to include in the log.
     */
    static func warning(
        tag: String,
        operation: String,
        phase: String,
        message: String? = nil,
        context: [String: Any?]? = nil,
        exception: Error? = nil
    ) {
        log(
            level: .default,
            tag: tag,
            operation: operation,
            phase: phase,
            message: message,
            context: context,
            exception: exception
        )
    }
    
    /**
     * Logs an error message.
     *
     * Use this method for error messages that indicate serious problems that
     * may prevent the application from functioning correctly.
     *
     * - Parameters:
     *   - tag: A tag for categorizing the log entry (converted to uppercase).
     *   - operation: The operation being performed.
     *   - phase: The phase of the operation.
     *   - message: Optional message to include in the log.
     *   - context: Optional contextual information.
     *   - exception: Optional error object to include in the log.
     */
    static func error(
        tag: String,
        operation: String,
        phase: String,
        message: String? = nil,
        context: [String: Any?]? = nil,
        exception: Error? = nil
    ) {
        log(
            level: .error,
            tag: tag,
            operation: operation,
            phase: phase,
            message: message,
            context: context,
            exception: exception
        )
    }
}


