import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:health_connector/health_connector.dart';
import 'package:health_connector_core/health_connector_core.dart'
    show
        AggregateRequest,
        AggregateResponse,
        HealthConnectorException,
        MeasurementUnit;

/// Manages state and operations for aggregating health data.
///
/// Handles aggregating health records (sum, average, min, max, count) over
/// a time range, tracking loading state, errors, and the aggregation result.
final class AggregateHealthDataChangeNotifier extends ChangeNotifier {
  final HealthConnector _healthConnector;

  AggregateHealthDataChangeNotifier(this._healthConnector);

  bool _isLoading = false;
  Exception? _error;
  AggregateResponse? _aggregateResponse;

  AggregateResponse? get aggregateResponse => _aggregateResponse;

  MeasurementUnit? get aggregationResult => _aggregateResponse?.value;

  bool get isLoading => _isLoading;

  Exception? get error => _error;

  /// Aggregates health data based on the provided request.
  ///
  /// Updates [aggregateResponse] with the aggregation result on success,
  /// or [error] on failure.
  Future<void> aggregateHealthData(AggregateRequest request) async {
    notify(() {
      _isLoading = true;
      _aggregateResponse = null;
    });

    try {
      final response = await _healthConnector.aggregate(request);
      notify(() {
        _aggregateResponse = response;
        _error = null;
      });
    } on HealthConnectorException catch (e) {
      notify(() {
        _error = e;
        _aggregateResponse = null;
      });
    } on Exception catch (e) {
      notify(() {
        _error = Exception('Error: $e');
        _aggregateResponse = null;
      });
    } finally {
      notify(() {
        _isLoading = false;
      });
    }
  }

  /// Clears the aggregation results and any errors.
  void clearResults() {
    notify(() {
      _aggregateResponse = null;
      _error = null;
    });
  }

  void notify(void Function() fn) {
    fn();
    notifyListeners();
  }
}
