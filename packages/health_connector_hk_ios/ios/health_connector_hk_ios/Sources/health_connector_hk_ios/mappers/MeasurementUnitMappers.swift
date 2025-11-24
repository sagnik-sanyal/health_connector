import Foundation
import HealthKit

// ==================== MASS MAPPERS ====================

extension MassDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .kilograms:
            unit = .gramUnit(with: .kilo)
        case .grams:
            unit = .gram()
        case .pounds:
            unit = .pound()
        case .ounces:
            unit = .ounce()
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `MassDto`.
     *
     * Uses kilograms as the transfer unit for consistency.
     */
    func toMassDto() -> MassDto {
        let kilograms = doubleValue(for: .gramUnit(with: .kilo))
        return MassDto(unit: .kilograms, value: kilograms)
    }
}

// ==================== ENERGY MAPPERS ====================

extension EnergyDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .kilocalories:
            unit = .kilocalorie()
        case .kilojoules:
            unit = .jouleUnit(with: .kilo)
        case .calories:
            unit = .smallCalorie()
        case .joules:
            unit = .joule()
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to an `EnergyDto`.
     *
     * Uses kilocalories as the transfer unit for consistency.
     */
    func toEnergyDto() -> EnergyDto {
        let kilocalories = doubleValue(for: .kilocalorie())
        return EnergyDto(unit: .kilocalories, value: kilocalories)
    }
}

// ==================== LENGTH MAPPERS ====================

extension LengthDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .meters:
            unit = .meter()
        case .kilometers:
            unit = .meterUnit(with: .kilo)
        case .miles:
            unit = .mile()
        case .feet:
            unit = .foot()
        case .inches:
            unit = .inch()
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `LengthDto`.
     *
     * Uses meters as the transfer unit for consistency.
     */
    func toLengthDto() -> LengthDto {
        let meters = doubleValue(for: .meter())
        return LengthDto(unit: .meters, value: meters)
    }
}

// ==================== TEMPERATURE MAPPERS ====================

extension TemperatureDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .celsius:
            unit = .degreeCelsius()
        case .fahrenheit:
            unit = .degreeFahrenheit()
        case .kelvin:
            unit = .kelvin()
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `TemperatureDto`.
     *
     * Uses celsius as the transfer unit for consistency.
     */
    func toTemperatureDto() -> TemperatureDto {
        let celsius = doubleValue(for: .degreeCelsius())
        return TemperatureDto(unit: .celsius, value: celsius)
    }
}

// ==================== PRESSURE MAPPERS ====================

extension PressureDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .millimetersOfMercury:
            unit = .millimeterOfMercury()
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `PressureDto`.
     *
     * Uses millimeters of mercury as the transfer unit.
     */
    func toPressureDto() -> PressureDto {
        let mmHg = doubleValue(for: .millimeterOfMercury())
        return PressureDto(unit: .millimetersOfMercury, value: mmHg)
    }
}

// ==================== VELOCITY MAPPERS ====================

extension VelocityDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .metersPerSecond:
            unit = .meter().unitDivided(by: .second())
        case .kilometersPerHour:
            unit = .meterUnit(with: .kilo).unitDivided(by: .hour())
        case .milesPerHour:
            unit = .mile().unitDivided(by: .hour())
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `VelocityDto`.
     *
     * Uses meters per second as the transfer unit for consistency.
     */
    func toVelocityDto() -> VelocityDto {
        let metersPerSecond = doubleValue(for: .meter().unitDivided(by: .second()))
        return VelocityDto(unit: .metersPerSecond, value: metersPerSecond)
    }
}

// ==================== VOLUME MAPPERS ====================

extension VolumeDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .liters:
            unit = .liter()
        case .milliliters:
            unit = .literUnit(with: .milli)
        case .fluidOuncesUs:
            unit = .fluidOunceUS()
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `VolumeDto`.
     *
     * Uses liters as the transfer unit for consistency.
     */
    func toVolumeDto() -> VolumeDto {
        let liters = doubleValue(for: .liter())
        return VolumeDto(unit: .liters, value: liters)
    }
}

// ==================== POWER MAPPERS ====================

extension PowerDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    @available(iOS 16.0, *)
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .watts:
            unit = .watt()
        case .kilowatts:
            unit = .wattUnit(with: .kilo)
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `PowerDto`.
     *
     * Uses watts as the transfer unit for consistency.
     */
    @available(iOS 16.0, *)
    func toPowerDto() -> PowerDto {
        let watts = doubleValue(for: .watt())
        return PowerDto(unit: .watts, value: watts)
    }
}

// ==================== BLOOD GLUCOSE MAPPERS ====================

extension BloodGlucoseDto {
    /**
     * Converts this DTO to a HealthKit `HKQuantity`.
     */
    func toHealthKit() -> HKQuantity {
        let unit: HKUnit
        switch self.unit {
        case .millimolesPerLiter:
            // Molar mass of glucose is 180.16 g/mol
            unit = HKUnit.moleUnit(with: .milli, molarMass: 180.16)
                .unitDivided(by: .liter())
        case .milligramsPerDeciliter:
            unit = HKUnit.gramUnit(with: .milli)
                .unitDivided(by: HKUnit.literUnit(with: .deci))
        }
        return HKQuantity(unit: unit, doubleValue: value)
    }
}

extension HKQuantity {
    /**
     * Converts this HealthKit quantity to a `BloodGlucoseDto`.
     *
     * Uses millimoles per liter as the transfer unit for consistency.
     */
    func toBloodGlucoseDto() -> BloodGlucoseDto {
        // Molar mass of glucose is 180.16 g/mol
        let mmolPerL = doubleValue(for: HKUnit.moleUnit(with: .milli, molarMass: 180.16)
            .unitDivided(by: .liter()))
        return BloodGlucoseDto(unit: .millimolesPerLiter, value: mmolPerL)
    }
}

// ==================== NUMERIC MAPPERS ====================

extension NumericDto {
    /**
     * Converts this DTO to an Int64 value (for step counts).
     */
    func toInt64() -> Int64 {
        return Int64(value)
    }
}

extension Int64 {
    /**
     * Converts an Int64 value (for step counts) to a `NumericDto`.
     *
     * Uses numeric unit for consistency.
     */
    func toNumericDto() -> NumericDto {
        return NumericDto(unit: .numeric, value: Double(self))
    }
}

