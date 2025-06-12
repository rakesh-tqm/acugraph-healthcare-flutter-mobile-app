import 'package:acugraph6/data_layer/contracts/driver.dart';

/// An interface all data layer models must implement.
///
/// Models must use a [Driver] mixin, which implements all logic for manipulating elements in a persistent storage.
abstract class Model with Driver {
  /// Parses and prepares [data] to be used in [Driver.driverCreate] method, matching expected format.
  Future<dynamic> createModel(dynamic data);

  /// Parses and prepares [data] to be used in [Driver.driverUpdate] method, matching expected format.
  Future<dynamic> updateModel(dynamic data);

  /// Parses and prepares [data] to be used in [Driver.driverDelete] method, matching expected format.
  Future<dynamic> deleteModel(dynamic data);
}
