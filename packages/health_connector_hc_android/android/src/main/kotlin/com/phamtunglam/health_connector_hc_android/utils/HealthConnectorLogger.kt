package com.phamtunglam.health_connector_hc_android.utils

import android.util.Log
import java.util.Locale

/**
 * A singleton logger that wraps Android's [Log] class.
 *
 * This logger provides a consistent structured logging interface with
 * formatted messages across the plugin. It supports structured logging with
 * operation, phase, optional message, and context.
 */
internal object HealthConnectorLogger {
    /**
     * Whether logging is enabled.
     *
     * When set to `false`, all logging methods will return immediately without
     * logging any messages. Defaults to `true`.
     */
    var isEnabled: Boolean = true
        private set

    /**
     * Sets whether logging is enabled.
     *
     * When set to `false`, all logging methods will return immediately without
     * logging any messages.
     *
     * @param enabled Whether to enable logging.
     */
    fun setEnabled(enabled: Boolean) {
        isEnabled = enabled
    }

    /**
     * Indentation for top-level fields.
     */
    private const val INDENT_LEVEL_1 = "  "

    /**
     * Indentation for nested fields (exception, context).
     */
    private const val INDENT_LEVEL_2 = "    "

    /**
     * Formats a structured log message in JSON-like format.
     *
     * Creates a formatted message with indentation, including
     * only non-null fields.
     *
     * @param operation The operation being performed (e.g., 'readRecords').
     * @param phase The phase of the operation (e.g., 'entry', 'completed').
     * @param message Optional message to include in the log.
     * @param context Optional map of contextual information.
     * @param exception Optional exception object.
     * @param stackTrace Optional stack trace.
     * @return A formatted string in JSON-like format with indentation.
     */
    private fun formatStructuredMessage(
        operation: String,
        phase: String,
        message: String? = null,
        context: Map<String, Any?>? = null,
        exception: Throwable? = null,
        stackTrace: Array<StackTraceElement>? = null,
    ): String {
        val buffer = StringBuilder()
        val fields = mutableListOf<String>()

        // Always include operation and phase
        fields.add("$INDENT_LEVEL_1 operation: $operation,")
        fields.add("$INDENT_LEVEL_1 phase: $phase,")

        // Include message if provided
        if (message != null) {
            fields.add("$INDENT_LEVEL_1 message: $message,")
        }

        // Include exception block if exception or stackTrace is provided
        if (exception != null || stackTrace != null) {
            val exceptionFields = mutableListOf<String>()
            if (exception != null) {
                exceptionFields.add("$INDENT_LEVEL_2 cause: $exception,")
            }
            if (stackTrace != null) {
                val stackTraceString = stackTrace.joinToString("\n") { it.toString() }
                exceptionFields.add("$INDENT_LEVEL_2 stack_trace: $stackTraceString,")
            }
            fields.add("$INDENT_LEVEL_1 exception: {")
            fields.addAll(exceptionFields)
            fields.add("$INDENT_LEVEL_1},")
        }

        // Include context if provided and not empty
        if (context != null && context.isNotEmpty()) {
            fields.add("$INDENT_LEVEL_1 context: {")
            for ((key, value) in context) {
                fields.add("$INDENT_LEVEL_2$key: $value,")
            }
            fields.add("$INDENT_LEVEL_1},")
        }

        // Build the final message
        buffer.appendLine("{")
        buffer.append(fields.joinToString("\n"))
        buffer.append("\n}")

        return buffer.toString()
    }

    /**
     * Internal method that formats and logs the message.
     *
     * Handles all logging logic including enabled check, message formatting,
     * and output. Formats the message according to the specified format:
     * ```
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
     * Note: DateTime and log level are provided by Android's Log class
     * and are not included in the message.
     *
     * @param level The log level (DEBUG, INFO, WARNING, ERROR).
     * @param tag The tag for categorizing the log entry (converted to uppercase).
     * @param operation The operation being performed.
     * @param phase The phase of the operation.
     * @param message Optional message to include in the log.
     * @param context Optional contextual information.
     * @param exception Optional exception object.
     */
    private fun log(
        level: LogLevel,
        tag: String,
        operation: String,
        phase: String,
        message: String? = null,
        context: Map<String, Any?>? = null,
        exception: Throwable? = null,
    ) {
        if (!isEnabled) {
            return
        }

        val stackTrace = exception?.stackTrace
        val structuredMessage = formatStructuredMessage(
            operation = operation,
            phase = phase,
            message = message,
            context = context,
            exception = exception,
            stackTrace = stackTrace,
        )

        val uppercaseTag = tag.uppercase(Locale.US)

        // Use Android Log with exception parameter when exception is provided
        when (level) {
            LogLevel.DEBUG -> {
                if (exception != null) {
                    Log.d(uppercaseTag, structuredMessage, exception)
                } else {
                    Log.d(uppercaseTag, structuredMessage)
                }
            }

            LogLevel.INFO -> {
                if (exception != null) {
                    Log.i(uppercaseTag, structuredMessage, exception)
                } else {
                    Log.i(uppercaseTag, structuredMessage)
                }
            }

            LogLevel.WARNING -> {
                if (exception != null) {
                    Log.w(uppercaseTag, structuredMessage, exception)
                } else {
                    Log.w(uppercaseTag, structuredMessage)
                }
            }

            LogLevel.ERROR -> {
                if (exception != null) {
                    Log.e(uppercaseTag, structuredMessage, exception)
                } else {
                    Log.e(uppercaseTag, structuredMessage)
                }
            }
        }
    }

    /**
     * Logs a debug message.
     *
     * Use this method for detailed diagnostic information that is typically
     * only of interest when diagnosing problems.
     *
     * @param tag A tag for categorizing the log entry (converted to uppercase).
     * @param operation The operation being performed.
     * @param phase The phase of the operation.
     * @param message Optional message to include in the log.
     * @param context Optional contextual information.
     * @param exception Optional exception object to include in the log.
     */
    fun debug(
        tag: String,
        operation: String,
        phase: String,
        message: String? = null,
        context: Map<String, Any?>? = null,
        exception: Throwable? = null,
    ) {
        log(
            level = LogLevel.DEBUG,
            tag = tag,
            operation = operation,
            phase = phase,
            message = message,
            context = context,
            exception = exception,
        )
    }

    /**
     * Logs an informational message.
     *
     * Use this method for general informational messages that describe normal
     * application flow.
     *
     * @param tag A tag for categorizing the log entry (converted to uppercase).
     * @param operation The operation being performed.
     * @param phase The phase of the operation.
     * @param message Optional message to include in the log.
     * @param context Optional contextual information.
     * @param exception Optional exception object to include in the log.
     */
    fun info(
        tag: String,
        operation: String,
        phase: String,
        message: String? = null,
        context: Map<String, Any?>? = null,
        exception: Throwable? = null,
    ) {
        log(
            level = LogLevel.INFO,
            tag = tag,
            operation = operation,
            phase = phase,
            message = message,
            context = context,
            exception = exception,
        )
    }

    /**
     * Logs a warning message.
     *
     * Use this method for warning messages that indicate potential problems or
     * unexpected behavior that doesn't prevent the application from functioning.
     *
     * @param tag A tag for categorizing the log entry (converted to uppercase).
     * @param operation The operation being performed.
     * @param phase The phase of the operation.
     * @param message Optional message to include in the log.
     * @param context Optional contextual information.
     * @param exception Optional exception object to include in the log.
     */
    fun warning(
        tag: String,
        operation: String,
        phase: String,
        message: String? = null,
        context: Map<String, Any?>? = null,
        exception: Throwable? = null,
    ) {
        log(
            level = LogLevel.WARNING,
            tag = tag,
            operation = operation,
            phase = phase,
            message = message,
            context = context,
            exception = exception,
        )
    }

    /**
     * Logs an error message.
     *
     * Use this method for error messages that indicate serious problems that
     * may prevent the application from functioning correctly.
     *
     * @param tag A tag for categorizing the log entry (converted to uppercase).
     * @param operation The operation being performed.
     * @param phase The phase of the operation.
     * @param message Optional message to include in the log.
     * @param context Optional contextual information.
     * @param exception Optional exception object to include in the log.
     */
    fun error(
        tag: String,
        operation: String,
        phase: String,
        message: String? = null,
        context: Map<String, Any?>? = null,
        exception: Throwable? = null,
    ) {
        log(
            level = LogLevel.ERROR,
            tag = tag,
            operation = operation,
            phase = phase,
            message = message,
            context = context,
            exception = exception,
        )
    }

    /**
     * Enum representing the different log levels.
     *
     * Each level uses the built-in [name] property from [Enum] which contains
     * the string representation of the log level.
     */
    private enum class LogLevel {
        /**
         * Debug level for detailed diagnostic information.
         */
        DEBUG,

        /**
         * Info level for general informational messages.
         */
        INFO,

        /**
         * Warning level for potential problems or unexpected behavior.
         */
        WARNING,

        /**
         * Error level for serious problems.
         */
        ERROR,
    }
}

