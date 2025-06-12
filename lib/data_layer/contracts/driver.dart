import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';

/// An interface all data layer drivers must implement.
abstract class Driver {
  /// Fetches multiple resources from a given [path], applying some [parameters].
  Future<dynamic> driverFetchMany(String path, JsonApiParameters parameters);

  /// Fetches the resource [identifier] from a given [path], applying some [parameters].
  Future<Map<String, dynamic>> driverFetchById(
      String path, String identifier, JsonApiParameters parameters);

  /// Creates a new [path] resource in the driver persistent storage using [data] as resource attributes.
  Future<Map<String, dynamic>> driverCreate(
      String resource, Map<String, dynamic> data);

  /// Updates the resource [identifier] from [path] in the driver persistent storage using [data] as resource attributes.
  Future<Map<String, dynamic>> driverUpdate(
      String path, String identifier, dynamic data);

  /// Removes the resource [identifier] from [path] from the driver persistent storage.
  Future<Map<String, dynamic>> driverDelete(String path, String identifier);
}
