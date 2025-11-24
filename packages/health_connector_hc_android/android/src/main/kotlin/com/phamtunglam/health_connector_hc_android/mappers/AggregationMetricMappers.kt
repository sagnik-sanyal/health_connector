package com.phamtunglam.health_connector_hc_android.mappers

import androidx.health.connect.client.aggregate.AggregateMetric
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.WeightRecord
import com.phamtunglam.health_connector_hc_android.pigeon.AggregationMetricDto
import com.phamtunglam.health_connector_hc_android.pigeon.HealthDataTypeDto

/**
 * Converts an [AggregationMetricDto] to a Health Connect aggregation metric.
 *
 * @receiver The [AggregationMetricDto] to convert
 * @param dataType The health data type for which to get the aggregation metric
 * @return The Health Connect aggregation metric as [AggregateMetric]
 * @throws IllegalArgumentException if the metric cannot use AggregateRequest directly
 */
internal fun AggregationMetricDto.toHealthConnectMetric(dataType: HealthDataTypeDto): AggregateMetric<*> {
    return when (dataType) {
        HealthDataTypeDto.STEPS -> {
            when (this) {
                AggregationMetricDto.SUM -> StepsRecord.COUNT_TOTAL
                AggregationMetricDto.AVG,
                AggregationMetricDto.MIN,
                AggregationMetricDto.MAX,
                AggregationMetricDto.COUNT -> throw IllegalArgumentException("${this.name} not directly supported for steps in Health Connect.")
            }
        }

        HealthDataTypeDto.WEIGHT -> {
            when (this) {
                AggregationMetricDto.AVG -> WeightRecord.WEIGHT_AVG
                AggregationMetricDto.MIN -> WeightRecord.WEIGHT_MIN
                AggregationMetricDto.MAX -> WeightRecord.WEIGHT_MAX
                AggregationMetricDto.SUM,
                AggregationMetricDto.COUNT -> throw IllegalArgumentException("${this.name} not directly supported for weight in Health Connect.")
            }
        }
    }
}

