import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:acugraph6/data_layer/models/attachment.dart';
import 'package:acugraph6/data_layer/models/base/json_api_model.dart';
import 'package:acugraph6/data_layer/models/library_item_snapshot.dart';
import 'package:acugraph6/data_layer/models/treatment_plan.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate this, run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'generated/treatment_plan_recommendation.g.dart';

@JsonSerializable()
class TreatmentPlanRecommendation extends JsonApiModel {
  String? category;
  String? title;
  String? channel;
  String? imbalance;
  String? description;
  @JsonKey(name: 'treat_at_home')
  bool? treatAtHome;
  @JsonKey(name: 'treated_in_office')
  bool? treatedInOffice;

  Attachment? attachment;
  TreatmentPlan? plan;
  LibraryItemSnapshot? snapshot;

  @override
  // ignore: overridden_fields
  bool isCacheable = true;

  static const String resource = 'treatment-plan-recommendations';
  static const String foreignId = 'treatment_plan_recommendation_uuid';

  static const Map<String, Map<String, String>> includableResources = {
    'attachment': {
      'resource': Attachment.resource,
      'type': 'belongsTo',
      'foreignId': 'attachment_uuid'
    },
    'plan': {
      'resource': TreatmentPlan.resource,
      'type': 'belongsTo',
      'foreignId': 'treatment_plan_uuid'
    },
    'snapshot': {
      'resource': LibraryItemSnapshot.resource,
      'type': 'belongsTo',
      'foreignId': 'library_item_snapshot_uuid'
    },
  };

  TreatmentPlanRecommendation()
      : super(resource, includable: includableResources);

  Future<TreatmentPlanRecommendation> fetchById(String identifier,
      {List include = const [], Map<String, String> fields = const {}}) async {
    final JsonApiParameters parameters = JsonApiParameters(
      include: include,
      includableResources: includableResources,
      fields: fields,
    );
    dynamic data =
        await super.driverFetchById(resource, identifier, parameters);
    return TreatmentPlanRecommendation.fromJson(data);
  }

  Future<SearchResult<TreatmentPlanRecommendation>> fetchMany({
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
    SearchResult<TreatmentPlanRecommendation> list =
        SearchResult<TreatmentPlanRecommendation>.fromJson(data['meta']);
    list.resources = data['items']
        .map<TreatmentPlanRecommendation>(
            (json) => TreatmentPlanRecommendation.fromJson(json))
        .toList();
    return list;
  }

  /// Treatment plan recommendations are read-only. They don't implement mutation methods!
  Future<void> create() async {}
  Future<void> update() async {}
  Future<void> delete() async {}

  factory TreatmentPlanRecommendation.fromJson(Map<String, dynamic> json) =>
      _$TreatmentPlanRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentPlanRecommendationToJson(this);
}
