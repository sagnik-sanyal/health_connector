import 'package:flutter/material.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show
        DataOrigin,
        Device,
        HealthConnectorErrorCode,
        HealthConnectorException,
        Mass,
        Metadata,
        RecordingMethod,
        WeightRecord;
import 'package:health_connector_toolbox/src/common/constants/app_icons.dart';
import 'package:health_connector_toolbox/src/common/constants/app_texts.dart';
import 'package:health_connector_toolbox/src/common/pages/start_date_time_page_state.dart';
import 'package:health_connector_toolbox/src/common/utils/show_snack_bar.dart';
import 'package:health_connector_toolbox/src/common/widgets/date_time_picker_row.dart';
import 'package:health_connector_toolbox/src/common/widgets/loading_overlay.dart';
import 'package:health_connector_toolbox/src/features/write_health_record/widgets/metadata_form_fields.dart';
import 'package:health_connector_toolbox/src/features/write_health_record/write_health_record_change_notifier.dart';
import 'package:provider/provider.dart' show Provider;

/// Page for writing weight records.
///
/// Allows users to enter weight in kilograms, select a timestamp, and
/// specify recording method and device type. Validates input and writes
/// the record to the health platform.
@immutable
final class WriteWeightRecordPage extends StatefulWidget {
  const WriteWeightRecordPage({super.key});

  @override
  State<WriteWeightRecordPage> createState() => _WriteWeightRecordPageState();
}

class _WriteWeightRecordPageState
    extends StartDateTimePageState<WriteWeightRecordPage> {
  late final WriteHealthRecordChangeNotifier _notifier =
      Provider.of<WriteHealthRecordChangeNotifier>(
        context,
        listen: false,
      );

  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  RecordingMethod _recordingMethod = RecordingMethod.unknown;
  Device? _device;
  Mass? _weight;
  bool _isWriting = false;

  @override
  void dispose() {
    _weightController.dispose();
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
      final notifier = Provider.of<WriteHealthRecordChangeNotifier>(
        context,
        listen: false,
      );

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

      final record = WeightRecord(
        time: startDateTime!,
        weight: _weight!,
        metadata: metadata,
      );

      await notifier.writeHealthRecord(record);

      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        SnackBarType.success,
        '${AppTexts.successfullyWroteRecord} '
        '${notifier.newRecordId?.value ?? 'unknown'}',
      );

      Navigator.of(context).pop();
    } on HealthConnectorException catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.code == HealthConnectorErrorCode.unsupportedHealthPlatformApi
          ? AppTexts.writePermissionDeniedWeight
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
        appBar: AppBar(title: const Text(AppTexts.insertWeight)),
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
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: AppTexts.weightValue,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(AppIcons.monitorWeight),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _weight = null;
                      } else {
                        final weightValue = double.tryParse(value);
                        if (weightValue != null && weightValue > 0) {
                          _weight = Mass.kilograms(weightValue);
                        } else {
                          _weight = null;
                        }
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppTexts.pleaseEnterWeight;
                    }
                    final weight = double.tryParse(value);
                    if (weight == null) {
                      return AppTexts.pleaseEnterValidNumber;
                    }
                    if (weight <= 0) {
                      return AppTexts.weightMustBeGreaterThanZero;
                    }
                    if (_weight == null) {
                      return AppTexts.pleaseEnterWeight;
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
