import 'package:acugraph6/data_layer/custom/json_api_parameters.dart';
import 'package:acugraph6/data_layer/custom/search_result.dart';
import 'package:acugraph6/data_layer/models/base/json_api_model.dart';
import 'package:acugraph6/data_layer/models/note.dart';
import 'package:acugraph6/data_layer/models/patient.dart';
import 'package:acugraph6/data_layer/models/treatment_plan_point.dart';
import 'package:acugraph6/data_layer/models/treatment_plan_recommendation.dart';
import 'package:json_annotation/json_annotation.dart';

// To generate this, run: "flutter pub run build_runner watch --delete-conflicting-outputs" in project root
// https://docs.flutter.dev/development/data-and-backend/json#serializing-json-using-code-generation-libraries
part 'generated/treatment_plan.g.dart';

@JsonSerializable()
class TreatmentPlan extends JsonApiModel {
  bool? locked = false;

  Note? note;
  Patient? patient;
  List<TreatmentPlanPoint>? points;
  List<TreatmentPlanRecommendation>? recommendations;

  @override
  // ignore: overridden_fields
  bool isCacheable = true;

  static const String resource = 'treatment-plans';
  static const String foreignId = 'treatment_plan_uuid';

  static const Map<String, Map<String, String>> includableResources = {
    'note': {
      'resource': Note.resource,
      'type': 'belongsTo',
      'foreignId': 'note_uuid'
    },
    'patient': {
      'resource': Patient.resource,
      'type': 'belongsTo',
      'foreignId': 'patient_uuid'
    },
    'points': {
      'resource': TreatmentPlanPoint.resource,
      'type': 'hasMany',
      'foreignId': TreatmentPlanPoint.foreignId
    },
    'recommendations': {
      'resource': TreatmentPlanRecommendation.resource,
      'type': TreatmentPlanRecommendation.foreignId
    },
  };

  TreatmentPlan() : super(resource, includable: includableResources);

  Future<TreatmentPlan> fetchById(String identifier,
      {List include = const [], Map<String, String> fields = const {}}) async {
    final JsonApiParameters parameters = JsonApiParameters(
      include: include,
      includableResources: includableResources,
      fields: fields,
    );
    dynamic data =
        await super.driverFetchById(resource, identifier, parameters);
    return TreatmentPlan.fromJson(data);
  }

  Future<SearchResult<TreatmentPlan>> fetchMany({
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
    SearchResult<TreatmentPlan> list =
        SearchResult<TreatmentPlan>.fromJson(data['meta']);
    list.resources = data['items']
        .map<TreatmentPlan>((json) => TreatmentPlan.fromJson(json))
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

  Future<dynamic> updateRecommendation(
      {required String libraryItemSnapshotUuid,
      bool? treatAtHome,
      bool? treatedInOffice}) async {
    validateIdentifier(id);
    validateIdentifier(libraryItemSnapshotUuid);

    Map<String, dynamic> data = {
      "id": id,
      "library_item_snapshot_uuid": libraryItemSnapshotUuid,
    };

    if (treatAtHome != null) data['treat_at_home'] = treatAtHome;
    if (treatedInOffice != null) data['treated_in_office'] = treatedInOffice;

    dynamic processedData = await super.driverUpdate(
        'treatment-plans', '$id/ag-actions/update-recommendation', data);

    return processedData;
  }

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) =>
      _$TreatmentPlanFromJson(json);

  Map<String, dynamic> toJson() => _$TreatmentPlanToJson(this);
}
