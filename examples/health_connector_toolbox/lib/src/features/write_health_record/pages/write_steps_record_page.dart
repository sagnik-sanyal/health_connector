import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show
        DataOrigin,
        Device,
        HealthConnectorErrorCode,
        HealthConnectorException,
        Metadata,
        Numeric,
        RecordingMethod,
        StepRecord;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/pages/start_date_time_with_duration_page_state.dart';
import 'package:health_connector_toolbox/src/common/utils/show_snack_bar.dart';
import 'package:health_connector_toolbox/src/common/widgets/date_time_picker_row.dart';
import 'package:health_connector_toolbox/src/common/widgets/loading_overlay.dart';
import 'package:health_connector_toolbox/src/features/write_health_record/widgets/duration_picker_field.dart';
import 'package:health_connector_toolbox/src/features/write_health_record/widgets/metadata_form_fields.dart';
import 'package:health_connector_toolbox/src/features/write_health_record/write_health_record_change_notifier.dart';
import 'package:provider/provider.dart' show Provider;

/// Page for writing step count records.
///
/// Allows users to enter step count, select start time and duration, and
/// specify recording method and device type. Validates input and writes
/// the record to the health platform.
@immutable
final class WriteStepsRecordPage extends StatefulWidget {
  const WriteStepsRecordPage({super.key});

  @override
  State<WriteStepsRecordPage> createState() => _WriteStepsRecordPageState();
}

class _WriteStepsRecordPageState
    extends StartDateTimeWithDurationPageState<WriteStepsRecordPage> {
  late final WriteHealthRecordChangeNotifier _notifier =
      Provider.of<WriteHealthRecordChangeNotifier>(
        context,
        listen: false,
      );

  final _formKey = GlobalKey<FormState>();
  final _countController = TextEditingController();
  RecordingMethod _recordingMethod = RecordingMethod.unknown;
  Device? _device;
  Numeric? _stepsCount;
  bool _isWriting = false;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate device is present when required
    if ((_recordingMethod == RecordingMethod.automaticallyRecorded ||
            _recordingMethod == RecordingMethod.activelyRecorded) &&
        _device == null) {
      return;
    }

    setState(() {
      _isWriting = true;
    });

    try {
      // Use a simple package name - in production this should come from
      // app config
      const dataOrigin = DataOrigin('com.example.health_connector_toolbox');
      final metadata = switch (_recordingMethod) {
        RecordingMethod.manualEntry => Metadata.manualEntry(
          dataOrigin: dataOrigin,
        ),
        RecordingMethod.automaticallyRecorded => Metadata.automaticallyRecorded(
          dataOrigin: dataOrigin,
          device: _device!,
        ),
        RecordingMethod.activelyRecorded => Metadata.activelyRecorded(
          dataOrigin: dataOrigin,
          device: _device!,
        ),
        RecordingMethod.unknown => Metadata.unknownRecordingMethod(
          dataOrigin: dataOrigin,
          device: _device,
        ),
      };

      final record = StepRecord(
        startTime: startDateTime!,
        endTime: endDateTime!,
        count: _stepsCount!,
        metadata: metadata,
      );

      await _notifier.writeHealthRecord(record);

      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        SnackBarType.success,
        '${AppTexts.successfullyWroteRecord} '
        '${_notifier.newRecordId?.value ?? 'unknown'}',
      );

      Navigator.of(context).pop();
    } on HealthConnectorException catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.code == HealthConnectorErrorCode.unsupportedHealthPlatformApi
          ? AppTexts.writePermissionDeniedSteps
          : e.message;
      showAppSnackBar(context, SnackBarType.error, message);
    } on Exception catch (e) {
      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        SnackBarType.error,
        '${AppTexts.errorPrefixColon} $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isWriting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isWriting,
      message: AppTexts.save,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppTexts.insertSteps)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DateTimePickerRow(
                  startDate: startDate,
                  startTime: startTime,
                  onDateChanged: setDate,
                  onTimeChanged: setTime,
                ),
                const SizedBox(height: 16),
                DurationPickerField(
                  label: 'Duration (HH:MM)',
                  initialValue: duration,
                  onChanged: setDuration,
                  validator: durationValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _countController,
                  decoration: const InputDecoration(
                    labelText: AppTexts.stepCount,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(AppIcons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _stepsCount = null;
                      } else {
                        final count = int.tryParse(value);
                        if (count != null && count >= 0) {
                          _stepsCount = Numeric(count);
                        } else {
                          _stepsCount = null;
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTexts.pleaseEnterStepCount;
                    }
                    final count = int.tryParse(value);
                    if (count == null) {
                      return AppTexts.pleaseEnterValidNumber;
                    }
                    if (count < 0) {
                      return AppTexts.countMustBeNonNegative;
                    }
                    if (_stepsCount == null) {
                      return AppTexts.pleaseEnterStepCount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                MetadataFormFields(
                  healthPlatform: _notifier.healthPlatform,
                  initialRecordingMethod: _recordingMethod,
                  initialDevice: _device,
                  onRecordingMethodChanged: (method) {
                    setState(() {
                      _recordingMethod = method ?? RecordingMethod.unknown;
                    });
                  },
                  onDeviceChanged: (device) {
                    setState(() {
                      _device = device;
                    });
                  },
                  recordingMethodValidator: (value) {
                    if (value == null) {
                      return AppTexts.pleaseSelectRecordingMethod;
                    }
                    return null;
                  },
                  deviceTypeValidator: (value) {
                    if (value == null) {
                      return AppTexts.pleaseSelectDeviceType;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isWriting ? null : _submitRecord,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                  ),
                  child: const Text(AppTexts.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
