package com.phamtunglam.health_connector_hc_android.mappers

import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import com.phamtunglam.health_connector_hc_android.pigeon.StepRecordDto
import com.phamtunglam.health_connector_hc_android.pigeon.WeightRecordDto
import java.time.Instant
import java.time.ZoneOffset

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

