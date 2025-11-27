part of 'health_data_type.dart';

/// Health data type for lean body mass information.
@Since('0.1.0')
@immutable
final class LeanBodyMassHealthDataType
    extends HealthDataType<LeanBodyMassRecord, Mass>
    implements
        ReadableHealthDataType<LeanBodyMassRecord>,
        WriteableHealthDataType,
        AvgAggregatableHealthDataType<LeanBodyMassRecord, Mass>,
        MinAggregatableHealthDataType<LeanBodyMassRecord, Mass>,
        MaxAggregatableHealthDataType<LeanBodyMassRecord, Mass> {
  @internal
  const LeanBodyMassHealthDataType();

  @override
  String get identifier => 'lean_body_mass';

  @override
  String get name => identifier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeanBodyMassHealthDataType &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'lean_body_mass_data_type';

  @override
  List<AggregationMetric> get supportedAggregationMetrics => [
    AggregationMetric.avg,
    AggregationMetric.min,
    AggregationMetric.max,
  ];

  // ReadableHealthDataType implementation
  @override
  HealthDataPermission get readPermission => HealthDataPermission(
    dataType: this,
    accessType: HealthDataPermissionAccessType.read,
  );

  @override
  ReadRecordRequest<LeanBodyMassRecord> readRecord(HealthRecordId id) {
    return ReadRecordRequest(dataType: this, id: id);
  }

  @override
  ReadRecordsRequest<LeanBodyMassRecord> readRecords({
    required DateTime startTime,
    required DateTime endTime,
    int pageSize = HealthConnectorConfigConstants.defaultPageSize,
  }) {
    return ReadRecordsRequest(
      dataType: this,
      startTime: startTime,
      endTime: endTime,
      pageSize: pageSize,
    );
  }

  // WriteableHealthDataType implementation
  @override
  HealthDataPermission get writePermission => HealthDataPermission(
    dataType: this,
    accessType: HealthDataPermissionAccessType.write,
  );

  // AvgAggregatableHealthDataType implementation
  @override
  AggregateRequest<LeanBodyMassRecord, Mass> aggregateAverage({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return AggregateRequest(
      dataType: this,
      aggregationMetric: AggregationMetric.avg,
      startTime: startTime,
      endTime: endTime,
    );
  }

  // MinAggregatableHealthDataType implementation
  @override
  AggregateRequest<LeanBodyMassRecord, Mass> aggregateMin({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return AggregateRequest(
      dataType: this,
      aggregationMetric: AggregationMetric.min,
      startTime: startTime,
      endTime: endTime,
    );
  }

  // MaxAggregatableHealthDataType implementation
  @override
  AggregateRequest<LeanBodyMassRecord, Mass> aggregateMax({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return AggregateRequest(
      dataType: this,
      aggregationMetric: AggregationMetric.max,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  List<Permission> get permissions => [readPermission, writePermission];
}
