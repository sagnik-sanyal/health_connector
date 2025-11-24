part of 'health_platform_feature.dart';

/// Feature representing historical health data reading capabilities.
@Since('0.1.0')
@immutable
final class HealthPlatformFeatureReadHealthDataHistory
    extends HealthPlatformFeature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthPlatformFeatureReadHealthDataHistory &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'HealthPlatformFeatureReadHealthDataHistory()';
}
