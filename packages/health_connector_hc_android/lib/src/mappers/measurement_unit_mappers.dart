import 'package:health_connector_core/health_connector_core.dart'
    show
        Mass,
        Energy,
        Length,
        Temperature,
        Pressure,
        Velocity,
        Volume,
        Power,
        BloodGlucose,
        Numeric;
import 'package:health_connector_hc_android/src/pigeon/health_connector_platform_api.g.dart'
    show
        MassDto,
        MassUnitDto,
        EnergyDto,
        LengthDto,
        TemperatureDto,
        PressureDto,
        VelocityDto,
        VolumeDto,
        PowerDto,
        BloodGlucoseDto,
        NumericDto,
        EnergyUnitDto,
        LengthUnitDto,
        TemperatureUnitDto,
        PressureUnitDto,
        VelocityUnitDto,
        VolumeUnitDto,
        PowerUnitDto,
        BloodGlucoseUnitDto,
        NumericUnitDto;
import 'package:meta/meta.dart' show internal;

/// Converts [Mass] to [MassDto].
@internal
extension MassDtoMapper on Mass {
  MassDto toDto() {
    // Uses kilograms as the transfer unit for consistency.
    return MassDto(value: inKilograms, unit: MassUnitDto.kilograms);
  }
}

/// Converts [MassDto] to [Mass].
@internal
extension MassDtoToDomain on MassDto {
  Mass toDomain() {
    switch (unit) {
      case MassUnitDto.kilograms:
        return Mass.kilograms(value);
      case MassUnitDto.grams:
        return Mass.grams(value);
      case MassUnitDto.pounds:
        return Mass.pounds(value);
      case MassUnitDto.ounces:
        return Mass.ounces(value);
    }
  }
}

/// Converts [Energy] to [EnergyDto].
@internal
extension EnergyDtoMapper on Energy {
  EnergyDto toDto() {
    // Uses kilocalories as the transfer unit for consistency.
    return EnergyDto(value: inKilocalories, unit: EnergyUnitDto.kilocalories);
  }
}

/// Converts [EnergyDto] to [Energy].
@internal
extension EnergyDtoToDomain on EnergyDto {
  Energy toDomain() {
    switch (unit) {
      case EnergyUnitDto.kilocalories:
        return Energy.kilocalories(value);
      case EnergyUnitDto.kilojoules:
        return Energy.kilojoules(value);
      case EnergyUnitDto.calories:
        return Energy.calories(value);
      case EnergyUnitDto.joules:
        return Energy.joules(value);
    }
  }
}

/// Converts [Length] to [LengthDto].
@internal
extension LengthDtoMapper on Length {
  LengthDto toDto() {
    // Uses meters as the transfer unit for consistency.
    return LengthDto(value: inMeters, unit: LengthUnitDto.meters);
  }
}

/// Converts [LengthDto] to [Length].
@internal
extension LengthDtoToDomain on LengthDto {
  /// Converts DTO to domain Length.
  Length toDomain() {
    switch (unit) {
      case LengthUnitDto.meters:
        return Length.meters(value);
      case LengthUnitDto.kilometers:
        return Length.kilometers(value);
      case LengthUnitDto.miles:
        return Length.miles(value);
      case LengthUnitDto.feet:
        return Length.feet(value);
      case LengthUnitDto.inches:
        return Length.inches(value);
    }
  }
}

/// Converts [Temperature] to [TemperatureDto].
@internal
extension TemperatureDtoMapper on Temperature {
  TemperatureDto toDto() {
    // Uses celsius as the transfer unit for consistency.
    return TemperatureDto(value: inCelsius, unit: TemperatureUnitDto.celsius);
  }
}

/// Converts [TemperatureDto] to [Temperature].
@internal
extension TemperatureDtoToDomain on TemperatureDto {
  Temperature toDomain() {
    switch (unit) {
      case TemperatureUnitDto.celsius:
        return Temperature.celsius(value);
      case TemperatureUnitDto.fahrenheit:
        return Temperature.fahrenheit(value);
      case TemperatureUnitDto.kelvin:
        return Temperature.kelvin(value);
    }
  }
}

/// Converts [Pressure] to [PressureDto].
@internal
extension PressureDtoMapper on Pressure {
  PressureDto toDto() {
    // Uses millimeters of mercury as the transfer unit.
    return PressureDto(
      value: inMillimetersOfMercury,
      unit: PressureUnitDto.millimetersOfMercury,
    );
  }
}

/// Converts [PressureDto] to [Pressure].
@internal
extension PressureDtoToDomain on PressureDto {
  Pressure toDomain() {
    switch (unit) {
      case PressureUnitDto.millimetersOfMercury:
        return Pressure.millimetersOfMercury(value);
    }
  }
}

/// Converts [Velocity] to [VelocityDto].
@internal
extension VelocityDtoMapper on Velocity {
  VelocityDto toDto() {
    // Uses meters per second as the transfer unit for consistency.
    return VelocityDto(
      value: inMetersPerSecond,
      unit: VelocityUnitDto.metersPerSecond,
    );
  }
}

/// Converts [VelocityDto] to [Velocity].
@internal
extension VelocityDtoToDomain on VelocityDto {
  Velocity toDomain() {
    switch (unit) {
      case VelocityUnitDto.metersPerSecond:
        return Velocity.metersPerSecond(value);
      case VelocityUnitDto.kilometersPerHour:
        return Velocity.kilometersPerHour(value);
      case VelocityUnitDto.milesPerHour:
        return Velocity.milesPerHour(value);
    }
  }
}

/// Converts [Volume] to [VolumeDto].
@internal
extension VolumeDtoMapper on Volume {
  VolumeDto toDto() {
    // Uses liters as the transfer unit for consistency.
    return VolumeDto(value: inLiters, unit: VolumeUnitDto.liters);
  }
}

/// Converts [VolumeDto] to [Volume].
@internal
extension VolumeDtoToDomain on VolumeDto {
  Volume toDomain() {
    switch (unit) {
      case VolumeUnitDto.liters:
        return Volume.liters(value);
      case VolumeUnitDto.milliliters:
        return Volume.milliliters(value);
      case VolumeUnitDto.fluidOuncesUs:
        return Volume.fluidOuncesUs(value);
    }
  }
}

/// Converts [Power] to [PowerDto].
@internal
extension PowerDtoMapper on Power {
  PowerDto toDto() {
    // Uses watts as the transfer unit for consistency.
    return PowerDto(value: inWatts, unit: PowerUnitDto.watts);
  }
}

/// Converts [PowerDto] to [Power].
@internal
extension PowerDtoToDomain on PowerDto {
  Power toDomain() {
    switch (unit) {
      case PowerUnitDto.watts:
        return Power.watts(value);
      case PowerUnitDto.kilowatts:
        return Power.kilowatts(value);
    }
  }
}

/// Converts [BloodGlucose] to [BloodGlucoseDto].
@internal
extension BloodGlucoseDtoMapper on BloodGlucose {
  BloodGlucoseDto toDto() {
    // Uses millimoles per liter as the transfer unit for consistency.
    return BloodGlucoseDto(
      value: inMillimolesPerLiter,
      unit: BloodGlucoseUnitDto.millimolesPerLiter,
    );
  }
}

/// Converts [BloodGlucoseDto] to [BloodGlucose].
@internal
extension BloodGlucoseDtoToDomain on BloodGlucoseDto {
  BloodGlucose toDomain() {
    switch (unit) {
      case BloodGlucoseUnitDto.millimolesPerLiter:
        return BloodGlucose.millimolesPerLiter(value);
      case BloodGlucoseUnitDto.milligramsPerDeciliter:
        return BloodGlucose.milligramsPerDeciliter(value);
    }
  }
}

/// Converts [Numeric] to [NumericDto].
@internal
extension NumericDtoMapper on Numeric {
  NumericDto toDto() {
    return NumericDto(value: value.toDouble(), unit: NumericUnitDto.numeric);
  }
}

/// Converts [NumericDto] to [Numeric].
@internal
extension NumericDtoToDomain on NumericDto {
  Numeric toDomain() {
    return Numeric(value);
  }
}
