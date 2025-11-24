import 'package:health_connector_core/src/annotations/health_connector_annotations.dart'
    show Since;

/// Defines the type of aggregation to perform on health data.
///
/// Each aggregation type computes a different metric over a set of health
/// records within a specified time range.
@Since('0.1.0')
enum AggregationMetric {
  /// Sum of all values in the time range.
  ///
  /// Only meaningful for cumulative data types like steps, distance, or
  /// calories burned.
  sum,

  /// Average (mean) value across all data points.
  ///
  /// Meaningful for both cumulative and measurement data types.
  avg,

  /// Minimum value in the dataset.
  ///
  /// Useful for finding the lowest recorded value in a time range.
  min,

  /// Maximum value in the dataset.
  ///
  /// Useful for finding the highest recorded value in a time range.
  max,

  /// Count of data points (records) in the dataset.
  ///
  /// Returns the number of health records that exist within the specified
  /// time range, regardless of their values.
  count,
}
