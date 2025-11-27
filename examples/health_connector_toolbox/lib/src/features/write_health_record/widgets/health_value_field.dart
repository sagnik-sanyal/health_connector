import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show
        ActiveCaloriesBurnedHealthDataType,
        DistanceHealthDataType,
        Energy,
        FloorsClimbedHealthDataType,
        HealthDataType,
        Length,
        Mass,
        MeasurementUnit,
        Numeric,
        StepsHealthDataType,
        WeightHealthDataType;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';

/// A widget that renders the appropriate value input field based on
/// the health data type.
///
/// This widget handles the data-type-specific input requirements:
/// - Integer input for step count (Numeric)
/// - Decimal input for weight (Mass in kg)
/// - Decimal input for distance (Length in meters)
@immutable
final class HealthValueField extends StatefulWidget {
  const HealthValueField({
    required this.dataType,
    required this.onChanged,
    super.key,
    this.validator,
  });

  /// The health data type that determines which input field to render.
  final HealthDataType dataType;

  /// Callback when the value changes.
  ///
  /// Provides a [MeasurementUnit] object (e.g., [Numeric], [Mass]) or null
  /// if the input is invalid or empty.
  final ValueChanged<MeasurementUnit?> onChanged;

  /// Validator for the value field.
  final String? Function(MeasurementUnit?)? validator;

  @override
  State<HealthValueField> createState() => _HealthValueFieldState();
}

class _HealthValueFieldState extends State<HealthValueField> {
  late final TextEditingController _controller;
  MeasurementUnit? _value;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _value = null;
      } else {
        _value = switch (widget.dataType) {
          StepsHealthDataType() => _parseNumeric(value),
          WeightHealthDataType() => _parseMass(value),
          DistanceHealthDataType() => _parseLength(value),
          ActiveCaloriesBurnedHealthDataType() => _parseEnergy(value),
          FloorsClimbedHealthDataType() => _parseNumeric(value),
        };
      }
    });
    widget.onChanged(_value);
  }

  Numeric? _parseNumeric(String value) {
    final count = int.tryParse(value);
    if (count != null && count >= 0) {
      return Numeric(count);
    }
    return null;
  }

  Mass? _parseMass(String value) {
    final weightValue = double.tryParse(value);
    if (weightValue != null && weightValue > 0) {
      return Mass.kilograms(weightValue);
    }
    return null;
  }

  Length? _parseLength(String value) {
    final distanceValue = double.tryParse(value);
    if (distanceValue != null && distanceValue > 0) {
      return Length.meters(distanceValue);
    }
    return null;
  }

  Energy? _parseEnergy(String value) {
    final energyValue = double.tryParse(value);
    if (energyValue != null && energyValue > 0) {
      return Energy.kilocalories(energyValue);
    }
    return null;
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return switch (widget.dataType) {
        StepsHealthDataType() => AppTexts.pleaseEnterStepCount,
        WeightHealthDataType() => AppTexts.pleaseEnterWeight,
        DistanceHealthDataType() => AppTexts.pleaseEnterDistance,
        ActiveCaloriesBurnedHealthDataType() =>
          AppTexts.pleaseEnterActiveCaloriesBurned,
        FloorsClimbedHealthDataType() => AppTexts.pleaseEnterFloorsClimbed,
      };
    }

    final parsed = switch (widget.dataType) {
      StepsHealthDataType() => int.tryParse(value),
      WeightHealthDataType() => double.tryParse(value),
      DistanceHealthDataType() => double.tryParse(value),
      ActiveCaloriesBurnedHealthDataType() => double.tryParse(value),
      FloorsClimbedHealthDataType() => int.tryParse(value),
    };

    if (parsed == null) {
      return AppTexts.pleaseEnterValidNumber;
    }

    if (widget.dataType is StepsHealthDataType ||
        widget.dataType is FloorsClimbedHealthDataType) {
      if (parsed as int < 0) {
        return widget.dataType is StepsHealthDataType
            ? AppTexts.countMustBeNonNegative
            : AppTexts.floorsClimbedMustBeNonNegative;
      }
    } else if (widget.dataType is WeightHealthDataType) {
      if (parsed as double <= 0) {
        return AppTexts.weightMustBeGreaterThanZero;
      }
    } else if (widget.dataType is DistanceHealthDataType) {
      if (parsed as double <= 0) {
        return AppTexts.distanceMustBeGreaterThanZero;
      }
    } else if (widget.dataType is ActiveCaloriesBurnedHealthDataType) {
      if (parsed as double <= 0) {
        return AppTexts.activeCaloriesBurnedMustBeGreaterThanZero;
      }
    }

    if (_value == null) {
      return switch (widget.dataType) {
        StepsHealthDataType() => AppTexts.pleaseEnterStepCount,
        WeightHealthDataType() => AppTexts.pleaseEnterWeight,
        DistanceHealthDataType() => AppTexts.pleaseEnterDistance,
        ActiveCaloriesBurnedHealthDataType() =>
          AppTexts.pleaseEnterActiveCaloriesBurned,
        FloorsClimbedHealthDataType() => AppTexts.pleaseEnterFloorsClimbed,
      };
    }

    if (widget.validator != null) {
      return widget.validator!(_value);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.dataType) {
      StepsHealthDataType() => TextFormField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: AppTexts.stepCount,
          border: OutlineInputBorder(),
          prefixIcon: Icon(AppIcons.numbers),
        ),
        keyboardType: TextInputType.number,
        onChanged: _onChanged,
        validator: _validate,
      ),
      WeightHealthDataType() => TextFormField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: AppTexts.weightValue,
          border: OutlineInputBorder(),
          prefixIcon: Icon(AppIcons.monitorWeight),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: _onChanged,
        validator: _validate,
      ),
      DistanceHealthDataType() => TextFormField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: AppTexts.distanceValue,
          border: OutlineInputBorder(),
          prefixIcon: Icon(AppIcons.straighten),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: _onChanged,
        validator: _validate,
      ),
      ActiveCaloriesBurnedHealthDataType() => TextFormField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: AppTexts.activeCaloriesBurnedValue,
          border: OutlineInputBorder(),
          prefixIcon: Icon(AppIcons.localFireDepartment),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: _onChanged,
        validator: _validate,
      ),
      FloorsClimbedHealthDataType() => TextFormField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: AppTexts.floorsClimbedValue,
          border: OutlineInputBorder(),
          prefixIcon: Icon(AppIcons.stairs),
        ),
        keyboardType: TextInputType.number,
        onChanged: _onChanged,
        validator: _validate,
      ),
    };
  }
}
