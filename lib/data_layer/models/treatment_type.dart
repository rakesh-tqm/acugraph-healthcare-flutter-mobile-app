import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:acugraph6/data_layer/models/base/json_api_model.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate this, run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'generated/treatment_type.g.dart';

@JsonSerializable()
class TreatmentType extends JsonApiModel {
  String? name;
  @JsonKey(name: 'treatment_type')
  String? treatmentType;

  @override
  // ignore: overridden_fields
  bool isCacheable = true;

  static const String resource = 'treatment-types';

  static const Map<String, Map<String, String>> includableResources = {};

  TreatmentType() : super(resource, includable: includableResources);

  Future<TreatmentType> fetchById(String identifier,
      {List include = const [], Map<String, String> fields = const {}}) async {
    final JsonApiParameters parameters = JsonApiParameters(
      include: include,
      includableResources: includableResources,
      fields: fields,
    );
    dynamic data =
        await super.driverFetchById(resource, identifier, parameters);
    return TreatmentType.fromJson(data);
  }

  Future<SearchResult<TreatmentType>> fetchMany({
    List include = const [],
    int? page,
    int? pageSize,
    String? sort,
    Map<String, dynamic> filters = const {},
    Map<String, String> fields = const {},
    bool? withTrashed = false,
    bool? onlyTrashed = false,
  }) async {
    final JsonApiParameters parameters = JsonApiParameters(
      page: page,
      pageSize: pageSize,
      sortBy: sort,
      include: include,
      includableResources: includableResources,
      filters: filters,
      fields: fields,
      withTrashed: withTrashed,
      onlyTrashed: onlyTrashed,
    );
    dynamic data = await super.driverFetchMany(resource, parameters);
    data['meta']['parameters'] = parameters.toJson();
    SearchResult<TreatmentType> list =
        SearchResult<TreatmentType>.fromJson(data['meta']);
    list.resources = data['items']
        .map<TreatmentType>((json) => TreatmentType.fromJson(json))
        .toList();
    return list;
  }

  Future<void> create() async {
    await super.createModel(toJson());
  }

  Future<void> update() async {
    await super.updateModel(toJson());
  }

  Future<void> delete() async {
    await super.deleteModel(toJson());
  }

  factory TreatmentType.fromJson(Map<String, dynamic> json) =>
      _$TreatmentTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentTypeToJson(this);
}
