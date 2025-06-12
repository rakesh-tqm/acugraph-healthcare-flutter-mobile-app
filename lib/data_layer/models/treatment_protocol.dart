import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:acugraph6/data_layer/models/base/json_api_model.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate this, run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'generated/treatment_protocol.g.dart';

@JsonSerializable()
class TreatmentProtocol extends JsonApiModel {
  late final String? condition;
  @JsonKey(name: 'primary_point')
  late final String? primaryPoint;
  @JsonKey(name: 'secondary_point')
  late final String? secondaryPoint;
  @JsonKey(name: 'conditional_point')
  late final String? conditionalPoint;

  @override
  // ignore: overridden_fields
  bool isCacheable = true;

  static const String resource = 'treatment-protocols';

  static const Map<String, Map<String, String>> includableResources = {};

  TreatmentProtocol()
      : super(resource,
            includable: includableResources, namespace: 'api/landlord');

  Future<TreatmentProtocol> fetchById(String identifier,
      {List include = const [], Map<String, String> fields = const {}}) async {
    final JsonApiParameters parameters = JsonApiParameters(
      include: include,
      includableResources: includableResources,
      fields: fields,
    );
    dynamic data =
        await super.driverFetchById(resource, identifier, parameters);
    return TreatmentProtocol.fromJson(data);
  }

  Future<SearchResult<TreatmentProtocol>> fetchMany({
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
    SearchResult<TreatmentProtocol> list =
        SearchResult<TreatmentProtocol>.fromJson(data['meta']);
    list.resources = data['items']
        .map<TreatmentProtocol>((json) => TreatmentProtocol.fromJson(json))
        .toList();
    return list;
  }

  /// Reference resources are read-only. They don't implement mutation methods!
  Future<void> create() async {}
  Future<void> update() async {}
  Future<void> delete() async {}

  factory TreatmentProtocol.fromJson(Map<String, dynamic> json) =>
      _$TreatmentProtocolFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentProtocolToJson(this);
}
