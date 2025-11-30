package com.phamtunglam.health_connector_hc_android.mappers

import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.BodyFatRecord
import androidx.health.connect.client.records.BodyTemperatureRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.FloorsClimbedRecord
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.HeightRecord
import androidx.health.connect.client.records.HydrationRecord
import androidx.health.connect.client.records.LeanBodyMassRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.WheelchairPushesRecord
import androidx.health.connect.client.units.Temperature
import com.phamtunglam.health_connector_hc_android.pigeon.ActiveCaloriesBurnedRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.BodyFatPercentageRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.BodyTemperatureRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.DistanceRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.FloorsClimbedRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.HeartRateMeasurementDto
import com.phamtunglam.health_connector_hc_android.pigeon.HeartRateSeriesRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.HeightRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.HydrationRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.LeanBodyMassRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.SleepSessionRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.SleepStageDto
import com.phamtunglam.health_connector_hc_android.pigeon.SleepStageTypeDto
import com.phamtunglam.health_connector_hc_android.pigeon.StepRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.WeightRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.WheelchairPushesRecordDto
import java.time.Instant
import java.time.ZoneOffset

/**
 * Extension property to get the ID from a [HealthRecordDto].
 *
 * This extension is needed due to a Pigeon limitation where sealed classes cannot have
 * any fields. Since [HealthRecordDto] is a sealed class, we cannot define a common `id`
 * field at the sealed class level. Instead, each subclass has its own `id` field, and
 * this extension provides a unified way to access the ID across all record types.
 *
 * @return The platform-assigned unique identifier for the record, or `null` if the
 * record doesn't have an ID (e.g., for new records being written).
 */
internal val HealthRecordDto.id: String?
    get() = when (this) {
        is ActiveCaloriesBurnedRecordDto -> id
        is DistanceRecordDto -> id
        is FloorsClimbedRecordDto -> id
        is StepRecordDto -> id
        is HeightRecordDto -> id
        is HydrationRecordDto -> id
        is BodyFatPercentageRecordDto -> id
        is BodyTemperatureRecordDto -> id
        is WeightRecordDto -> id
        is LeanBodyMassRecordDto -> id
        is WheelchairPushesRecordDto -> id
        is HeartRateSeriesRecordDto -> id
        is SleepSessionRecordDto -> id
    }

/**
 * Converts a Health Connect [ActiveCaloriesBurnedRecord] object to an [ActiveCaloriesBurnedRecordDto].
 */
internal fun ActiveCaloriesBurnedRecord.toDto(): ActiveCaloriesBurnedRecordDto {
    return ActiveCaloriesBurnedRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        energy = energy.toDto()
    )
}

/**
 * Converts a Health Connect [DistanceRecord] object to a [DistanceRecordDto].
 */
internal fun DistanceRecord.toDto(): DistanceRecordDto {
    return DistanceRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        distance = distance.toDto()
    )
}

/**
 * Converts a Health Connect [FloorsClimbedRecord] object to a [FloorsClimbedRecordDto].
 */
internal fun FloorsClimbedRecord.toDto(): FloorsClimbedRecordDto {
    return FloorsClimbedRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        floors = floors.toNumericDto()
    )
}

/**
 * Converts a Health Connect [StepsRecord] object to a [StepRecordDto].
 */
internal fun StepsRecord.toDto(): StepRecordDto {
    return StepRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        count = count.toNumericDto()
    )
}

/**
 * Converts a Health Connect [WeightRecord] object to a [WeightRecordDto].
 */
internal fun WeightRecord.toDto(): WeightRecordDto {
    return WeightRecordDto(
        id = metadata.id,
        time = time.toEpochMilli(),
        zoneOffsetSeconds = zoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        weight = weight.toDto()
    )
}

/**
 * Converts a Health Connect [LeanBodyMassRecord] object to a [LeanBodyMassRecordDto].
 */
internal fun LeanBodyMassRecord.toDto(): LeanBodyMassRecordDto {
    return LeanBodyMassRecordDto(
        id = metadata.id,
        time = time.toEpochMilli(),
        zoneOffsetSeconds = zoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        mass = mass.toDto()
    )
}

/**
 * Converts a Health Connect [HeightRecord] object to a [HeightRecordDto].
 */
internal fun HeightRecord.toDto(): HeightRecordDto {
    return HeightRecordDto(
        id = metadata.id,
        time = time.toEpochMilli(),
        zoneOffsetSeconds = zoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        height = height.toDto()
    )
}

/**
 * Converts a Health Connect [BodyFatRecord] object to a [BodyFatPercentageRecordDto].
 */
internal fun BodyFatRecord.toDto(): BodyFatPercentageRecordDto {
    return BodyFatPercentageRecordDto(
        id = metadata.id,
        time = time.toEpochMilli(),
        zoneOffsetSeconds = zoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        percentage = percentage.toDto()
    )
}

/**
 * Converts a Health Connect [BodyTemperatureRecord] object to a [BodyTemperatureRecordDto].
 */
internal fun BodyTemperatureRecord.toDto(): BodyTemperatureRecordDto {
    return BodyTemperatureRecordDto(
        id = metadata.id,
        time = time.toEpochMilli(),
        zoneOffsetSeconds = zoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        temperature = temperature.inCelsius.toTemperatureDto()
    )
}

/**
 * Converts a Health Connect [WheelchairPushesRecord] object to a [WheelchairPushesRecordDto].
 */
internal fun WheelchairPushesRecord.toDto(): WheelchairPushesRecordDto {
    return WheelchairPushesRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        pushes = count.toNumericDto()
    )
}

/**
 * Converts a Health Connect [HydrationRecord] object to a [HydrationRecordDto].
 */
internal fun HydrationRecord.toDto(): HydrationRecordDto {
    return HydrationRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        volume = volume.toDto()
    )
}

/**
 * Converts a Health Connect [HeartRateRecord] object to a [HeartRateSeriesRecordDto].
 */
internal fun HeartRateRecord.toDto(): HeartRateSeriesRecordDto {
    return HeartRateSeriesRecordDto(
        id = metadata.id,
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        metadata = metadata.toDto(),
        samples = samples.map { sample ->
            HeartRateMeasurementDto(
                time = sample.time.toEpochMilli(),
                beatsPerMinute = sample.beatsPerMinute.toNumericDto()
            )
        }
    )
}

internal fun SleepStageTypeDto.toHealthConnect(): Int {
    return when (this) {
        SleepStageTypeDto.UNKNOWN -> SleepSessionRecord.STAGE_TYPE_UNKNOWN
        SleepStageTypeDto.AWAKE -> SleepSessionRecord.STAGE_TYPE_AWAKE
        SleepStageTypeDto.SLEEPING -> SleepSessionRecord.STAGE_TYPE_SLEEPING
        SleepStageTypeDto.OUT_OF_BED -> SleepSessionRecord.STAGE_TYPE_OUT_OF_BED
        SleepStageTypeDto.LIGHT -> SleepSessionRecord.STAGE_TYPE_LIGHT
        SleepStageTypeDto.DEEP -> SleepSessionRecord.STAGE_TYPE_DEEP
        SleepStageTypeDto.REM -> SleepSessionRecord.STAGE_TYPE_REM
        SleepStageTypeDto.IN_BED -> SleepSessionRecord.STAGE_TYPE_AWAKE_IN_BED
    }
}

internal fun Int.toSleepStageTypeDto(): SleepStageTypeDto {
    return when (this) {
        SleepSessionRecord.STAGE_TYPE_UNKNOWN -> SleepStageTypeDto.UNKNOWN
        SleepSessionRecord.STAGE_TYPE_AWAKE -> SleepStageTypeDto.AWAKE
        SleepSessionRecord.STAGE_TYPE_SLEEPING -> SleepStageTypeDto.SLEEPING
        SleepSessionRecord.STAGE_TYPE_OUT_OF_BED -> SleepStageTypeDto.OUT_OF_BED
        SleepSessionRecord.STAGE_TYPE_LIGHT -> SleepStageTypeDto.LIGHT
        SleepSessionRecord.STAGE_TYPE_DEEP -> SleepStageTypeDto.DEEP
        SleepSessionRecord.STAGE_TYPE_REM -> SleepStageTypeDto.REM
        SleepSessionRecord.STAGE_TYPE_AWAKE_IN_BED -> SleepStageTypeDto.IN_BED
        else -> SleepStageTypeDto.UNKNOWN
    }
}

internal fun SleepStageDto.toHealthConnect(): SleepSessionRecord.Stage {
    return SleepSessionRecord.Stage(
        startTime = Instant.ofEpochMilli(startTime),
        endTime = Instant.ofEpochMilli(endTime),
        stage = stage.toHealthConnect()
    )
}

internal fun SleepSessionRecord.Stage.toDto(): SleepStageDto {
    return SleepStageDto(
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        stage = stage.toSleepStageTypeDto()
    )
}

internal fun SleepSessionRecord.toDto(): SleepSessionRecordDto {
    return SleepSessionRecordDto(
        id = metadata.id,
        metadata = metadata.toDto(),
        startTime = startTime.toEpochMilli(),
        endTime = endTime.toEpochMilli(),
        startZoneOffsetSeconds = startZoneOffset?.totalSeconds?.toLong(),
        endZoneOffsetSeconds = endZoneOffset?.totalSeconds?.toLong(),
        title = title,
        notes = notes,
        stages = stages.map { it.toDto() }
    )
}

/**
 * Converts a [HealthRecordDto] to a Health Connect [Record] object.
 *
 * This extension uses pattern matching on the sealed class to convert
 * each record type to its corresponding Health Connect record.
 */
internal fun HealthRecordDto.toHealthConnect(): Record {
    return when (this) {
        is ActiveCaloriesBurnedRecordDto -> ActiveCaloriesBurnedRecord(
            energy = energy.toHealthConnect(),
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is DistanceRecordDto -> DistanceRecord(
            distance = distance.toHealthConnect(),
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is FloorsClimbedRecordDto -> FloorsClimbedRecord(
            floors = floors.value,
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is StepRecordDto -> StepsRecord(
            count = count.toLong(),
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is HeightRecordDto -> HeightRecord(
            height = height.toHealthConnect(),
            time = Instant.ofEpochMilli(time),
            zoneOffset = zoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is HydrationRecordDto -> HydrationRecord(
            volume = volume.toHealthConnect(),
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is BodyFatPercentageRecordDto -> BodyFatRecord(
            percentage = percentage.toHealthConnect(),
            time = Instant.ofEpochMilli(time),
            zoneOffset = zoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is BodyTemperatureRecordDto -> BodyTemperatureRecord(
            temperature = Temperature.celsius(temperature.value),
            time = Instant.ofEpochMilli(time),
            zoneOffset = zoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is WeightRecordDto -> WeightRecord(
            weight = weight.toHealthConnect(),
            time = Instant.ofEpochMilli(time),
            zoneOffset = zoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is LeanBodyMassRecordDto -> LeanBodyMassRecord(
            mass = mass.toHealthConnect(),
            time = Instant.ofEpochMilli(time),
            zoneOffset = zoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is WheelchairPushesRecordDto -> WheelchairPushesRecord(
            count = pushes.value.toLong(),
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is HeartRateSeriesRecordDto -> HeartRateRecord(
            samples = samples.map { sample ->
                HeartRateRecord.Sample(
                    time = Instant.ofEpochMilli(sample.time),
                    beatsPerMinute = sample.beatsPerMinute.value.toLong()
                )
            },
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
            metadata = metadata.toHealthConnect(),
        )

        is SleepSessionRecordDto -> SleepSessionRecord(
            startTime = Instant.ofEpochMilli(startTime),
            endTime = Instant.ofEpochMilli(endTime),
            startZoneOffset = startZoneOffsetSeconds?.let {
                ZoneOffset.ofTotalSeconds(it.toInt())
            } ?: ZoneOffset.UTC,
            endZoneOffset = endZoneOffsetSeconds?.let {
                ZoneOffset.ofTotalSeconds(it.toInt())
            } ?: ZoneOffset.UTC,
            title = title,
            notes = notes,
            stages = stages.map { it.toHealthConnect() },
            metadata = metadata.toHealthConnect()
        )
    }
}
