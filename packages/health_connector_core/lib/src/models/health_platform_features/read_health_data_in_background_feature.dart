part of 'health_platform_feature.dart';

/// Feature representing background health data reading capabilities.
@Since('0.1.0')
@immutable
final class HealthPlatformFeatureReadHealthDataInBackground
    extends HealthPlatformFeature {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthPlatformFeatureReadHealthDataInBackground &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'HealthPlatformFeatureReadHealthDataInBackground()';
}
