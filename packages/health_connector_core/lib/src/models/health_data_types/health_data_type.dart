import 'package:health_connector_annotation/health_connector_annotation.dart'
    show Since;
import 'package:health_connector_core/health_connector_core.dart'
    show Permission;
import 'package:health_connector_core/src/config/health_connector_config_constants.dart'
    show HealthConnectorConfigConstants;
import 'package:health_connector_core/src/models/health_data_types/avg_aggregateable_health_data_type.dart'
    show AvgAggregatableHealthDataType;
import 'package:health_connector_core/src/models/health_data_types/max_aggregateable_health_data_type.dart'
    show MaxAggregatableHealthDataType;
import 'package:health_connector_core/src/models/health_data_types/min_aggregateable_health_data_type.dart'
    show MinAggregatableHealthDataType;
import 'package:health_connector_core/src/models/health_data_types/readable_health_data_type.dart'
    show ReadableHealthDataType;
import 'package:health_connector_core/src/models/health_data_types/sum_aggregateable_health_data_type.dart'
    show SumAggregatableHealthDataType;
import 'package:health_connector_core/src/models/health_data_types/writeable_health_data_type.dart'
    show WriteableHealthDataType;
import 'package:health_connector_core/src/models/health_platform.dart'
    show HealthPlatform;
import 'package:health_connector_core/src/models/health_platform_data.dart'
    show HealthPlatformData;
import 'package:health_connector_core/src/models/health_records/health_record.dart'
    show
        ActiveCaloriesBurnedRecord,
        DistanceRecord,
        FloorsClimbedRecord,
        HealthRecord,
        HealthRecordId,
        StepRecord,
        WeightRecord,
        WheelchairPushesRecord;
import 'package:health_connector_core/src/models/measurement_units/measurement_unit.dart'
    show Energy, Length, Mass, MeasurementUnit, Numeric;
import 'package:health_connector_core/src/models/permissions/permission.dart'
    show HealthDataPermission, HealthDataPermissionAccessType;
import 'package:health_connector_core/src/models/requests/aggregate_request.dart'
    show AggregateRequest;
import 'package:health_connector_core/src/models/requests/aggregation_metric.dart'
    show AggregationMetric;
import 'package:health_connector_core/src/models/requests/read_record_request.dart'
    show ReadRecordRequest;
import 'package:health_connector_core/src/models/requests/read_records_request.dart'
    show ReadRecordsRequest;
import 'package:meta/meta.dart' show immutable, internal;

part 'active_calories_burned_health_data_type.dart';
part 'distance_health_data_type.dart';
part 'floors_climbed_health_data_type.dart';
part 'steps_health_data_type.dart';
part 'weight_health_data_type.dart';
part 'wheelchair_pushes_health_data_type.dart';

/// [HealthDataType] represents different kinds of health and fitness data
/// that can be read from or written to health platforms.
///
/// ## Type Parameters
///
/// - `R`: The [HealthRecord] type associated with this data type
/// - `U`: The unit type for aggregations (e.g., [Numeric], [Mass], [Energy])
///
/// ## Capability Model Design
///
/// This class uses **interface classes** instead of mixins to represent
/// capabilities reading, writing, aggregation).
///
/// ### Why Not Mixins?
///
/// Initially, capabilities were implemented using `base mixin`, but
/// this caused issues with Dart's switch-case exhaustiveness checking:
///
/// ```dart
/// // With base mixins, this switch is NOT exhaustive:
/// switch (dataType) {
///   case StepsHealthDataType(): // ...
///   case WeightHealthDataType(): // ...
///   // ERROR: Must also handle ReadableHealthDataType, WriteableHealthDataType,
///   // SumAggregatableHealthDataType, etc., even though all instances are
///   // already covered by the concrete types above!
/// }
/// ```
///
/// The problem is that `mixin` with `base` makes mixins part of the sealed
/// type hierarchy, causing the analyzer to require handling them as separate
/// cases, even when they're already covered by concrete implementations.
///
/// ### Why Interface Classes?
///
/// Using `abstract interface class` solves this problem, as interfaces don't
/// participate in sealed type exhaustiveness checking, so you only need to
/// handle concrete types:
/// ```dart
/// switch (dataType) {
///   case StepsHealthDataType(): // ...
///   case WeightHealthDataType(): // ...
///   // No need to handle interface types!
/// }
/// ```
///
/// ### Trade-offs
///
/// The main trade-off is code duplication: each concrete type must implement
/// all methods from the interfaces it supports.
/// However, this is acceptable because:
/// - The implementations are straightforward (mostly creating request objects)
/// - It eliminates the switch-case exhaustiveness problem
@Since('0.1.0')
@immutable
sealed class HealthDataType<R extends HealthRecord, U extends MeasurementUnit>
    implements HealthPlatformData {
  const HealthDataType();

  @override
  List<HealthPlatform> get supportedHealthPlatforms => HealthPlatform.values;

  /// The unique identifier for this data type.
  ///
  /// This identifier is used for platform communication, serialization,
  /// and distinguishing between different health data types.
  String get identifier;

  /// The list of aggregation metrics that support this health record.
  List<AggregationMetric> get supportedAggregationMetrics;

  /// The list of permissions for this health record.
  List<Permission> get permissions;

  /// Distance data type.
  ///
  /// Represents the distance traveled during activities such as walking,
  /// running, or cycling. Supports both reading existing distance data
  /// and writing new distance measurements.
  static const distance = DistanceHealthDataType();

  /// Step count data type.
  ///
  /// Represents the number of steps taken by the user. Supports both reading
  /// existing step count data and writing new step count entries.
  static const steps = StepsHealthDataType();

  /// Body weight data type.
  ///
  /// Represents the user's body weight measurements. Supports both reading
  /// existing weight data and writing new weight measurements.
  static const weight = WeightHealthDataType();

  /// Active calories burned data type.
  ///
  /// Represents the amount of energy (calories) burned during physical activity
  /// over a time interval. Active calories are those burned through exercise
  /// and movement, excluding basal metabolic rate. Supports both reading
  /// existing active calories data and writing new measurements.
  static const activeCaloriesBurned = ActiveCaloriesBurnedHealthDataType();

  /// Floors climbed data type.
  ///
  /// Represents the number of floors (flights of stairs) climbed during
  /// a time interval. A floor is typically defined as a vertical distance
  /// of approximately 3 meters (10 feet). Supports both reading existing
  /// floors climbed data and writing new measurements.
  static const floorsClimbed = FloorsClimbedHealthDataType();

  /// Wheelchair pushes data type.
  ///
  /// Represents the number of wheelchair pushes performed during
  /// a time interval. A push represents a single propulsion action
  /// used to move a wheelchair forward. Supports both reading existing
  /// wheelchair pushes data and writing new measurements.
  static const wheelchairPushes = WheelchairPushesHealthDataType();

  /// Returns a list of all available health data types.
  ///
  /// This list contains all data types currently supported by the plugin.
  /// As new data types are added, they will automatically appear in this list.
  static const List<HealthDataType<HealthRecord, MeasurementUnit>> values = [
    activeCaloriesBurned,
    distance,
    floorsClimbed,
    steps,
    weight,
    wheelchairPushes,
  ];
}
