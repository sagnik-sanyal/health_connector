import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show HealthConnectorException, HealthRecord, HealthRecordId, HealthPlatform;

/// Manages state and operations for writing health records.
///
/// Handles writing health records to the health platform, tracking loading
/// state, errors, and the ID of newly created records.
final class WriteHealthRecordChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;

  WriteHealthRecordChangeNotifier(this._healthConnector);

  bool _isLoading = false;

  HealthRecordId? _newRecordId;
  Exception? _error;

  HealthRecordId? get newRecordId => _newRecordId;

  HealthPlatform get healthPlatform => _healthConnector.healthPlatform;

  bool get isLoading => _isLoading;

  Exception? get error => _error;

  /// Writes a health record to the health platform.
  ///
  /// Sets loading state and updates [newRecordId] on success or
  /// [error] on failure.
  Future<void> writeHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      _newRecordId = await _healthConnector.writeRecord(record);
      _error = null;
    } on HealthConnectorException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
