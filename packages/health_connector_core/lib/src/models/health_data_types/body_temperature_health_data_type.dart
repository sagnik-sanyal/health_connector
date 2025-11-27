part of 'health_data_type.dart';

/// Health data type for body temperature information.
@Since('0.1.0')
@immutable
final class BodyTemperatureHealthDataType
    extends HealthDataType<BodyTemperatureRecord, Temperature>
    implements
        ReadableHealthDataType<BodyTemperatureRecord>,
        WriteableHealthDataType,
        AvgAggregatableHealthDataType<BodyTemperatureRecord, Temperature>,
        MinAggregatableHealthDataType<BodyTemperatureRecord, Temperature>,
        MaxAggregatableHealthDataType<BodyTemperatureRecord, Temperature> {
  @internal
  const BodyTemperatureHealthDataType();

  @override
  String get identifier => 'bodyTemperature';

  @override
  String get name => identifier;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyTemperatureHealthDataType &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() => 'body_temperature_data_type';

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
  ReadRecordRequest<BodyTemperatureRecord> readRecord(HealthRecordId id) {
    return ReadRecordRequest(dataType: this, id: id);
  }

  @override
  ReadRecordsRequest<BodyTemperatureRecord> readRecords({
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
  AggregateRequest<BodyTemperatureRecord, Temperature> aggregateAverage({
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
  AggregateRequest<BodyTemperatureRecord, Temperature> aggregateMin({
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
  AggregateRequest<BodyTemperatureRecord, Temperature> aggregateMax({
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

