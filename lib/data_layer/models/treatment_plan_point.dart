import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:acugraph6/data_layer/models/base/json_api_model.dart';
import 'package:acugraph6/data_layer/models/treatment_plan.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate this, run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'generated/treatment_plan_point.g.dart';

@JsonSerializable()
class TreatmentPlanPoint extends JsonApiModel {
  @JsonKey(name: 'item_id')
  int? itemId;
  @JsonKey(name: 'item_type')
  String? itemType;
  @JsonKey(name: 'item_name')
  String? itemName;
  @JsonKey(name: 'item_abbreviation')
  String? itemAbbreviation;
  bool? left = false;
  bool? right = false;
  @JsonKey(name: 'treatment_modality')
  String? treatmentModality;
  @JsonKey(name: 'item_reason')
  String? itemReason;
  @JsonKey(name: 'treat_at_home')
  bool? treatAtHome = false;
  @JsonKey(name: 'treated_in_office')
  bool? treatedInOffice = true;
  @JsonKey(name: 'sort_order')
  int? sortOrder;
  @JsonKey(name: 'divergent_sort_order')
  int? dirvergentSortOrder;

  TreatmentPlan? plan;

  @override
  // ignore: overridden_fields
  bool isCacheable = true;

  static const String resource = 'treatment-plan-points';
  static const String foreignId = 'treatment_plan_point_uuid';

  static const Map<String, Map<String, String>> includableResources = {
    'plan': {
      'resource': TreatmentPlan.resource,
      'type': 'belongsTo',
      'foreignId': 'treatment_plan_uuid'
    },
  };

  TreatmentPlanPoint() : super(resource, includable: includableResources);

  Future<TreatmentPlanPoint> fetchById(String identifier,
      {List include = const [], Map<String, String> fields = const {}}) async {
    final JsonApiParameters parameters = JsonApiParameters(
      include: include,
      includableResources: includableResources,
      fields: fields,
    );
    dynamic data =
        await super.driverFetchById(resource, identifier, parameters);
    return TreatmentPlanPoint.fromJson(data);
  }

  Future<SearchResult<TreatmentPlanPoint>> fetchMany({
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
    SearchResult<TreatmentPlanPoint> list =
        SearchResult<TreatmentPlanPoint>.fromJson(data['meta']);
    list.resources = data['items']
        .map<TreatmentPlanPoint>((json) => TreatmentPlanPoint.fromJson(json))
        .toList();
    return list;
  }

  Future<void> create() async {
    final attributes = await super.createModel(toJson());
    itemId = attributes['item_id'];
  }

  Future<void> update() async {
    await super.updateModel(toJson());
  }

  Future<void> delete() async {
    await super.deleteModel(toJson());
  }

  factory TreatmentPlanPoint.fromJson(Map<String, dynamic> json) =>
      _$TreatmentPlanPointFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentPlanPointToJson(this);
}
