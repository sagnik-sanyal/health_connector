package com.phamtunglam.health_connector_hc_android.mappers

import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.DistanceRecord
import androidx.health.connect.client.records.FloorsClimbedRecord
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import com.phamtunglam.health_connector_hc_android.pigeon.ActiveCaloriesBurnedRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.DistanceRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.FloorsClimbedRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.StepRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.WeightRecordDto
import java.time.Instant
import java.time.ZoneOffset

/**
 * Converts an [ActiveCaloriesBurnedRecordDto] to a Health Connect [ActiveCaloriesBurnedRecord] object.
 */
internal fun ActiveCaloriesBurnedRecordDto.toHealthConnect(): ActiveCaloriesBurnedRecord {
    return ActiveCaloriesBurnedRecord(
        energy = energy.toHealthConnect(),
        startTime = Instant.ofEpochMilli(startTime),
        endTime = Instant.ofEpochMilli(endTime),
        startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        metadata = metadata.toHealthConnect(),
    )
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
 * Converts a [DistanceRecordDto] to a Health Connect [DistanceRecord] object.
 */
internal fun DistanceRecordDto.toHealthConnect(): DistanceRecord {
    return DistanceRecord(
        distance = distance.toHealthConnect(),
        startTime = Instant.ofEpochMilli(startTime),
        endTime = Instant.ofEpochMilli(endTime),
        startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        metadata = metadata.toHealthConnect(),
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
 * Converts a [FloorsClimbedRecordDto] to a Health Connect [FloorsClimbedRecord] object.
 */
internal fun FloorsClimbedRecordDto.toHealthConnect(): FloorsClimbedRecord {
    return FloorsClimbedRecord(
        floors = floors.value,
        startTime = Instant.ofEpochMilli(startTime),
        endTime = Instant.ofEpochMilli(endTime),
        startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        metadata = metadata.toHealthConnect(),
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
 * Converts a [StepRecordDto] to a Health Connect [StepsRecord] object.
 */
internal fun StepRecordDto.toHealthConnect(): StepsRecord {
    return StepsRecord(
        count = count.toLong(),
        startTime = Instant.ofEpochMilli(startTime),
        endTime = Instant.ofEpochMilli(endTime),
        startZoneOffset = startZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        endZoneOffset = endZoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        metadata = metadata.toHealthConnect(),
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
 * Converts a [WeightRecordDto] to a Health Connect [WeightRecord] object.
 */
internal fun WeightRecordDto.toHealthConnect(): WeightRecord {
    return WeightRecord(
        weight = weight.toHealthConnect(),
        time = Instant.ofEpochMilli(time),
        zoneOffset = zoneOffsetSeconds?.let { ZoneOffset.ofTotalSeconds(it.toInt()) },
        metadata = metadata.toHealthConnect(),
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

