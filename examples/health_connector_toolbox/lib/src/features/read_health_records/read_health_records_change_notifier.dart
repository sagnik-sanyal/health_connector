import 'dart:collection';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show
        HealthDataType,
        HealthConnectorException,
        HealthRecord,
        MeasurementUnit,
        ReadRecordsRequest;

/// Manages state and operations for reading health records.
///
/// Handles reading health records with pagination support, loading additional
/// pages, and deleting individual records. Tracks loading state, errors, and
/// the current list of records.
final class ReadHealthRecordsChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;

  ReadHealthRecordsChangeNotifier(this._healthConnector);

  bool _isLoading = false;
  Exception? _error;
  ReadRecordsRequest? _nextPageRequest;
  UnmodifiableListView<HealthRecord> _healthRecords = UnmodifiableListView([]);
  bool _hasQueriedRecords = false;

  UnmodifiableListView<HealthRecord> get healthRecords => _healthRecords;

  bool get isLoading => _isLoading;

  Exception? get error => _error;

  ReadRecordsRequest? get nextPageRequest => _nextPageRequest;

  bool get hasQueriedRecords => _hasQueriedRecords;

  /// Reads health records based on the provided request.
  ///
  /// Resets the current records list and loads the first page of results.
  /// Updates [healthRecords], [nextPageRequest], and [hasQueriedRecords].
  Future<void> readHealthRecords(ReadRecordsRequest request) async {
    notify(() {
      _isLoading = true;
      _healthRecords = UnmodifiableListView([]);
      _nextPageRequest = null;
      _hasQueriedRecords = false;
    });

    try {
      final response = await _healthConnector.readRecords(request);

      notify(() {
        _healthRecords = UnmodifiableListView(response.records);
        _nextPageRequest = response.nextPageRequest;
        _hasQueriedRecords = true;
        _error = null;
      });
    } on HealthConnectorException catch (e) {
      notify(() {
        _error = e;
        _healthRecords = UnmodifiableListView([]);
        _nextPageRequest = null;
      });
    } on Exception catch (e) {
      notify(() {
        _error = Exception('Error: $e');
        _healthRecords = UnmodifiableListView([]);
        _nextPageRequest = null;
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  /// Loads the next page of health records if available.
  ///
  /// Appends the new records to the existing [healthRecords] list.
  /// Does nothing if [nextPageRequest] is null.
  Future<void> loadNextPage() async {
    final nextPageRequest = _nextPageRequest;
    if (nextPageRequest == null) {
      return;
    }

    notify(() {
      _isLoading = true;
    });

    try {
      final nextResponse = await _healthConnector.readRecords(nextPageRequest);

      notify(() {
        final updatedHealthRecords = [
          ..._healthRecords,
          ...nextResponse.records,
        ];
        _healthRecords = UnmodifiableListView(updatedHealthRecords);
        _nextPageRequest = nextResponse.nextPageRequest;
        _error = null;
      });
    } on HealthConnectorException catch (e) {
      notify(() {
        _error = e;
      });
    } on Exception catch (e) {
      notify(() {
        _error = Exception('Error: $e');
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  /// Deletes a health record by its ID.
  ///
  /// Removes the record from [healthRecords] on success.
  Future<void> deleteRecord(
    HealthRecord record,
    HealthDataType<HealthRecord, MeasurementUnit> dataType,
  ) async {
    notify(() {
      _isLoading = true;
    });

    try {
      await _healthConnector.deleteRecordsByIds(
        dataType: dataType,
        recordIds: [record.id],
      );

      notify(() {
        final updatedHealthRecords = _healthRecords
            .where((r) => r.id != record.id)
            .toList();
        _healthRecords = UnmodifiableListView(updatedHealthRecords);
        _error = null;
      });
    } on HealthConnectorException catch (e) {
      notify(() {
        _error = e;
      });
    } on Exception catch (e) {
      notify(() {
        _error = Exception('Error: $e');
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  /// Resets the state by clearing all records and pagination information.
  void reset() {
    notify(() {
      _healthRecords = UnmodifiableListView([]);
      _nextPageRequest = null;
      _hasQueriedRecords = false;
    });
  }

  void notify(void Function() fn) {
    fn();
    notifyListeners();
  }
}
