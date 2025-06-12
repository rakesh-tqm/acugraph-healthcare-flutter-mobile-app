import 'package:acugraph6/data_layer/contracts/model.dart';
import 'package:acugraph6/data_layer/drivers/http_json_api.dart';
import 'package:acugraph6/data_layer/drivers/sqlite.dart';
import 'package:acugraph6/data_layer/exceptions/model.dart';
import 'package:json_annotation/json_annotation.dart';

// Models use a generated code inside. Run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root if you are changing model properties
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries

/// A base model for json:api models
abstract class JsonApiModel with HttpJsonApi implements Model {
  String? id;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  DateTime? deletedAt;
  @JsonKey(name: 'last_edited_by')
  String? lastEditedBy;

  late String _resourceModel;

  JsonApiModel(String resource,
      {String? namespace = "",
      Map<String, Map<String, String>>? includable = const {}}) {
    if (namespace != "") {
      super.namespacePath = namespace!;
    }
    if (includable != null && includable.isNotEmpty) {
      super.possiblyIncludables = includable;
    }
    _resourceModel = resource;
  }

  /// Parses and prepares [data] to be used in [Driver.driverCreate] method, matching expected format.
  ///
  /// Updates attributes that were modified during driver manipulation.
  /// In case of json:api, it returns a new [id] and timestamps for [created_at] and [updated_at] attributes.
  /// Remove null values to avoid initializing attributes wrongly.
  @override
  Future<dynamic> createModel(dynamic data) async {
    data.removeWhere((key, value) => value == null);
    dynamic processedData = await super.driverCreate(_resourceModel, data);
    id = processedData['id'];
    createdAt = parseDate(processedData['created_at']);
    updatedAt = parseDate(processedData['updated_at']);
    return processedData;
  }

  /// Parses and prepares [data] to be used in [Driver.driverUpdate] method, matching expected format.
  ///
  /// Updates attributes that were modified during driver manipulation.
  /// In case of json:api, it returns an updated timestamp [updated_at] attribute.
  @override
  Future<dynamic> updateModel(dynamic data) async {
    validateIdentifier(id);
    dynamic processedData =
        await super.driverUpdate(_resourceModel, id ?? '', data);
    updatedAt = parseDate(processedData['updated_at']);
    return processedData;
  }

  /// Parses and prepares [data] to be used in [Driver.driverDelete] method, matching expected format.
  ///
  /// Updates attributes that were modified during driver manipulation.
  /// In case of json:api, it returns null, so we can't update values for timestamp [updated_at] and [deleted_at] attributes.
  @override
  Future<dynamic> deleteModel(dynamic data) async {
    validateIdentifier(id);
    dynamic processedData = await super.driverDelete(_resourceModel, id ?? '');

    return processedData;
  }

  void validateIdentifier(String? identifier) {
    if (identifier == null) {
      throw ModelIdentifierException(
          'identifier doesnt seem to be defined on this model.');
    }
  }

  /// Converts a String type [date] value to DateTime type.
  DateTime? parseDate(String? date) {
    return date == null ? null : DateTime.parse(date);
  }
}
